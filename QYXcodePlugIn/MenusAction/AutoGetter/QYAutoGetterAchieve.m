//
//  AutoGetterAchieve.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/18.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//


#import "QYAutoGetterAchieve.h"
#import "QYCategoryAutoGetterSetterAchieve.h"
#import "MHXcodeDocumentNavigator.h"
#import "NSString+Extensions.h"
#import "QYClangFormat.h"
#import "QYIDENotificationHandler.h"
#import "QYPreferencesController.h"
#import <AppKit/AppKit.h>


//@"@property\\s*\\(.+?\\)\\s*(\\w+)?\\s*\\*{1}\\s*(\\w+)\\s*;{1}";
static NSInteger const groupBaseCount = 3;
@interface QYAutoGetterAchieve ()

@property (nonatomic,retain) LAFIDESourceCodeEditor *editor;

/**
 *  设置
 */
@property (nonatomic, retain) NSDictionary *configDic;

@end

@implementation QYAutoGetterAchieve

- (void)dealloc { NSLog(@"===AutoGetterAchieve=======dealloc="); }


- (void)getterAction
{
    //Category
    if ([[[MHXcodeDocumentNavigator currentFilePath] currentFileName] isCategoryFilePath]) {
        QYCategoryAutoGetterSetterAchieve *cgsAchieve =  [[QYCategoryAutoGetterSetterAchieve alloc] init];
        [cgsAchieve createCategoryGetterSetterAction];
        return;
    }
    
    //AutoGeter
    PMKPromise *cfGetterPromise = [self promiseClangFormateGetterStr];
    PMKPromise *cfSelectePromise = [QYClangFormat promiseClangFormatSourceCode:self.editor.selectedText];
    PMKPromise *insertLocPromise = [QYAutoGetterAchieve promiseInsertLoction];
    NSDictionary *promiseDic = @{
                                     @"cfGp":cfGetterPromise,
                                     @"cfSp":cfSelectePromise,
                                     @"insertLoc":insertLocPromise
                                 };
    
    [PMKPromise when:promiseDic].thenOn(dispatch_get_main_queue(),^(NSDictionary *resulte){
        //插入allGetterStr
        NSValue  * rangValue = resulte[@"insertLoc"];
        NSRange replaceRang = [rangValue rangeValue];
        [self.editor.view insertText:resulte[@"cfGp"] replacementRange:replaceRang];
        
        //替换选择内容
        [self.editor insertOnCaret:resulte[@"cfSp"]];
    }).catch(^(NSError *err){
        NSString *dominStr = dominWithError(err);
        [LAFIDESourceCodeEditor showAboveCaret:dominStr color:[NSColor yellowColor]];
    });
    
}


#pragma mark - PMKPromise Task

/**
 *  根据选择内容获取所有生成getterStr
 *
 *  @return return value description
 */
-(PMKPromise *)promiseClangFormateGetterStr{
    
    PMKPromise *cfAllGetterStr =
    
    dispatch_promise_on(dispatch_get_main_queue(),^id(){
        return PMKManifold(self.editor.selectedText,self.editor.view.textStorage.string);
    }).thenOn(dispatch_get_global_queue(0, 0),^id(NSString *selectedText,NSString *implementationContent){
        if (IsEmpty(selectedText))
            return error(@"选中内容为空。。。", 0, nil);
        //解析选中property
        NSError *matchError;
        NSArray *propertyArr = [QYAutoGetterAchieve MatcheSelectText:selectedText error:&matchError];
        if (matchError)
            return  matchError;
        
        //过滤已存在的
        propertyArr = [self matchePropertyMethodOnCurrentEditor:propertyArr andCurrentEdiorContent:implementationContent];
        if (ArrIsEmpty(propertyArr))
            return  error(@"选中属性Getter方法已存在。。..", 0, nil);
        
        //拼接方法
        NSString *allMethodsStr = [self AppendMethodesStrWithPropertyArr:propertyArr];
        //匹配 mark
        NSString *regexPragma = @"#pragma\\s*mark\\s*-\\s*AutoGetter";
        NSArray *pragmaMatches = [implementationContent matcheStrWith:regexPragma error:&matchError];
        if (matchError)
            return  matchError;
        
        if (ArrIsEmpty(pragmaMatches)) {
            allMethodsStr = [NSString stringWithFormat:@"%@\n\n%@",@"#pragma  mark -  AutoGetter",allMethodsStr];
        }

        return [QYClangFormat  promiseClangFormatSourceCode:allMethodsStr];
    });
    return cfAllGetterStr;
}



#pragma mark - public method

/**
 *  解析选中内容，返回类型和变量名的dic
 *
 *  @param sourceStr sourceStr description
 *
 *  @return return value description
 */
+ (NSArray *)MatcheSelectText:(NSString *)sourceStr error:(NSError **)error
{
    NSMutableArray *propertyArr = [NSMutableArray arrayWithCapacity:0];
    NSRange range = [sourceStr rangeOfString:@"@end"];
    if (!RangIsNotFound(range))
        return propertyArr;
    
    NSArray *mathcheArr = [sourceStr matcheGroupWith:propertyMatcheStr error:error];
    if (ArrIsEmpty(mathcheArr))
        return propertyArr;
    
    NSInteger groupCount = [mathcheArr count] / groupBaseCount;
    
    for (int i = 0; i < groupCount; i++) {
        NSInteger keyIndex = i * groupBaseCount + 1;
        NSInteger valueIndex = keyIndex + 1;
        
        NSString *key = mathcheArr[keyIndex];
        NSString *value = mathcheArr[valueIndex];
        [propertyArr addObject:@{key : value}];
    }
    return propertyArr;
}

/**
 *  确定插入代码位置
 *
 *  @return
 */
+ (PMKPromise *)promiseInsertLoction{
    
    PMKPromise *promise =
    
    dispatch_promise_on(dispatch_get_main_queue(),^id(){
        return  [MHXcodeDocumentNavigator currentSourceCodeTextView].textStorage.string;
    }).thenOn(dispatch_get_global_queue(0, 0), ^id(NSString *textStorageString){
        
        NSString *currentFilePath = [MHXcodeDocumentNavigator currentFilePath];
        BOOL isHeaderFile = [currentFilePath isHeaderFilePath];
        BOOL isCategoryFile = [currentFilePath isCategoryFilePath];
        
        
        //头文件
        if (isHeaderFile && !isCategoryFile)
            return error(@"一般类的头文件不处理", 10, nil);
        //解析ClassName
        NSString *matchClassNameStr = [currentFilePath currentClassName];
        if (isCategoryFile) {
            NSArray * classNameArr = [matchClassNameStr componentsSeparatedByString:@"+"];
            if (!classNameArr || [classNameArr count] == 0)
                return  error(@"获取分类名失败", 0, nil);
            matchClassNameStr = [NSString stringWithFormat:@"%@\\s*\\(\\s*%@\\s*\\)",classNameArr[0],classNameArr[1]];
        }
        
        // 匹配.m 内容
        NSString *soureString = textStorageString;
        if (isHeaderFile) {
            //读取.m 内容
            currentFilePath =
            [currentFilePath stringByReplacingCharactersInRange:NSMakeRange(currentFilePath.length - 1, 1) withString:@"m"];
            
            soureString = [NSString stringWithContentsOfFile:currentFilePath encoding:NSUTF8StringEncoding error:nil];
            if (!soureString||soureString.length == 0)
                return error(@"读取文件失败", 0, nil);
            
        }
        NSError *matchError;
        //匹配@end
        NSArray *endMatches = [soureString matcheStrWith:@"@end" error:&matchError];
        if (matchError)
            return matchError;
        //直接使用end
        if ([endMatches count] == 1)
            return  [NSValue valueWithRange:[endMatches[0] range]];
        
        
        //匹配到多个@end 则 匹配@implementation className
        NSString *matchStr = [NSString stringWithFormat:@"@implementation\\s+%@\\s*",matchClassNameStr];
        
        NSArray *impMatches = [soureString matcheStrWith:matchStr error:&matchError];
        if (matchError)
            return matchError;
        
        //查找@end
        __block NSInteger index = -1;
        
        [endMatches enumerateObjectsUsingBlock:^(NSTextCheckingResult * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSRange endRang = [obj range];
            NSRange impRange = [impMatches[0] range];
            if (endRang.location > impRange.location) {
                index = idx;
                *stop = YES;
            }
        }];
        if (index < 0)
            return error(@"没有找到正确的@end位置", 0, nil);
        
        return [NSValue valueWithRange:[endMatches[index] range]];
    });
    
    return promise;
}

#pragma mark - private Method

/**
 *  根据配置构造get方法
 *
 *  @param keyType   keyType description
 *  @param valueIvar valueIvar description
 *
 *  @return return value description
 */
- (NSString *)SpliceMethodStr:(NSString *)keyType value:(NSString *)valueIvar
{
    NSMutableString *methodStr = [NSMutableString stringWithCapacity:0];
    
    NSString *ivarNameStr = [NSString stringWithFormat:@"_%@", valueIvar];
    BOOL isObj = [keyType mh_containsString:@"*"];

    
    if (isObj) {
        [methodStr appendFormat:@"-(%@)%@{if(!%@){", keyType, valueIvar, ivarNameStr];
        keyType = [keyType substringToIndex:keyType.length - 1];
        keyType =  [keyType stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        //读取配置。。。
        if (self.configDic && [[self.configDic allKeys] containsObject:keyType]) {
            NSArray *configList = self.configDic[keyType];
            [configList enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                [methodStr appendFormat:obj, ivarNameStr];
            }];
        } else {
            [methodStr appendFormat:@"%@ = [[%@ alloc] init];", ivarNameStr, keyType];
        }
        [methodStr appendFormat:@"}return %@;}", ivarNameStr];
    }else{
        [methodStr appendFormat:@"-(%@)%@{\n return %@;\n}", keyType, valueIvar,ivarNameStr];
    }


    return [NSString stringWithString:methodStr];
}


/**
 *  生成所有get方法代码字符串
 *
 *  @param propertyDic propertyDic description
 *
 *  @return return value description
 */
- (NSString *)AppendMethodesStrWithPropertyArr:(NSArray *)propertyArr
{
    NSMutableString *allMethodsStr = [NSMutableString stringWithCapacity:0];
    
    [propertyArr enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        NSDictionary *ppDic = propertyArr[idx];
        NSString *key = [ppDic allKeys][0];
        NSString *value = ppDic[key];
        NSString *methodStr = [self SpliceMethodStr:key value:value];
        [allMethodsStr appendString:methodStr];
    }];
    
    [allMethodsStr appendString:@"\n\n@end"];
    
    return [NSString stringWithString:allMethodsStr];
}
/**
 *  过滤选中属性
 *
 *  @param matcheProprotyArr matcheProprotyArr description
 *  @param ediorContent      ediorContent description
 *
 *  @return return value description
 */
-(NSMutableArray *)matchePropertyMethodOnCurrentEditor:(NSArray *)matcheProprotyArr andCurrentEdiorContent:(NSString *)ediorContent{
    
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
    
    [matcheProprotyArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *ppDic = matcheProprotyArr[idx];
        NSString *key = [ppDic allKeys][0];
        NSString *value = ppDic[key];
        
        BOOL isContain = [key mh_containsString:@"*"];
        key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (isContain) {
            key = [key substringToIndex:key.length - 1];
            key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        NSString *matcheStr = [NSString stringWithFormat:@"-\\s*\\(\\s*%@\\s*%@\\)\\s*%@\\s*",key,(isContain?@"\\*\\s*":@""),value];
        NSError *matchError;
        NSArray *matcheArr = [ediorContent matcheStrWith:matcheStr error:&matchError];
        if (ArrIsEmpty(matcheArr)&&!matchError) {
            [arr addObject:ppDic];
        }
        
    }];
    
    return arr;
}

#pragma mark - 获取配置信息

/**
 *  获取配置信息
 *
 *  @return return value description
 */
- (NSDictionary *)configDic
{
    if (!_configDic) {
        QYPreferencesModel *preferencesModel = [[QYIDENotificationHandler sharedHandler] preferencesModel];
        
        if (!preferencesModel.getterJSON || preferencesModel.getterJSON.length == 0) {
            return nil;
        }
        NSData *jsonData = [preferencesModel.getterJSON dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic =
        [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        if (err) {
            NSLog(@"json解析失败：%@", err);
            return nil;
        }
        _configDic = dic;
    }
    return _configDic;
}

-(LAFIDESourceCodeEditor *)editor{
    if (!_editor) {
        _editor = [[LAFIDESourceCodeEditor alloc] init];
    }
    return _editor;
}
@end
