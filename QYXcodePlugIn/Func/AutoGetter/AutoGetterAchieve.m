//
//  AutoGetterAchieve.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/18.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//


#import "AutoGetterAchieve.h"
#import "CategoryGetterSetterAchieve.h"
#import "MHXcodeDocumentNavigator.h"
#import "NSString+Extensions.h"
#import "QYClangFormat.h"
#import "QYIDENotificationHandler.h"
#import "QYPluginSetingController.h"
#import <AppKit/AppKit.h>

static NSString *const propertyMatcheStr = @"@property\\s*\\(.+?\\)\\s*(\\w+)?\\s*\\*{1}\\s*(\\w+)\\s*;{1}";
static NSInteger const groupBaseCount = 3;
@interface AutoGetterAchieve ()
/**
 *  设置
 */
@property (nonatomic, retain) NSDictionary *configDic;

@end

@implementation AutoGetterAchieve

- (void)dealloc { NSLog(@"===AutoGetterAchieve=======dealloc="); }


- (void)createGetterAction
{
    NSString  *currentFileName =  [[MHXcodeDocumentNavigator currentFilePath] lastPathComponent];
    if ([currentFileName rangeOfString:@"+"].location != NSNotFound) {
        //Category
        BOOL isHeaderFile = [[currentFileName pathExtension] isEqualToString:@"h"];
        CategoryGetterSetterAchieve *cgsAchieve =  [[CategoryGetterSetterAchieve alloc] init];
        [cgsAchieve createCategoryGetterSetterAction:isHeaderFile];
        return;
    }
    //AutoGeter
    NSString *selecteText = globleParamter;
    PMKPromise *cfGetterPromise = [self promiseClangFormateGetterStr:selecteText];
    PMKPromise *cfSelectePromise = [QYClangFormat promiseClangFormatSourceCode:selecteText];
    PMKPromise *insertLocPromise = [AutoGetterAchieve promiseInsertLoction];
    NSDictionary *promiseDic = @{
                                     @"cfGp":cfGetterPromise,
                                     @"cfSp":cfSelectePromise,
                                     @"insertLoc":insertLocPromise
                                 };
    
    [PMKPromise when:promiseDic].thenOn(dispatch_get_main_queue(),^(NSDictionary *resulte){
        //插入allGetterStr
        NSString * allGetterStr = resulte[@"cfGp"];
        NSValue  * rangValue = resulte[@"insertLoc"];
        NSRange replaceRang = [rangValue rangeValue];
        NSTextView *codeTextView = [MHXcodeDocumentNavigator currentSourceCodeTextView];
        [codeTextView insertText:allGetterStr replacementRange:replaceRang];
        
        //重新获取当前选择内容的位置。。
        NSString * selecteStr = resulte[@"cfSp"];
        NSRange selecteRange = [codeTextView.textStorage.string rangeOfString:selecteText];
        [codeTextView insertText:selecteStr replacementRange:selecteRange];
    }).catch(^(NSError *error){
        NSLog(@"createGetterAction==error==%@",error);
    });
    
}


#pragma mark - 根据选择内容获取所有生成getterStr

-(PMKPromise *)promiseClangFormateGetterStr:(NSString *)selecteText{
    
    PMKPromise *cfAllGetterStr =
    
    dispatch_promise_on(dispatch_get_main_queue(), ^id(){
        return  [MHXcodeDocumentNavigator currentSourceCodeTextView];
    }).thenOn(dispatch_get_global_queue(0, 0),^(NSTextView *currentCodeTextView){
        //解析选中property
        NSArray *propertyArr = [AutoGetterAchieve MatcheSelectText:selecteText];
        if ([propertyArr count] == 0)
            @throw  error(@"解析选中property错误.....", 0, nil);
        
        //拼接方法
        NSString *allMethodsStr = [self AppendMethodesStrWithPropertyArr:propertyArr CurrentSourceCodeTextView:currentCodeTextView];
        if (allMethodsStr.length == 0)
            @throw  error(@"拼接getter代码出错。。。", 0, nil);

        return [QYClangFormat  promiseClangFormatSourceCode:allMethodsStr];
    });
    return cfAllGetterStr;
}


#pragma mark - 确定插入代码位置

+ (PMKPromise *)promiseInsertLoction{
    
    PMKPromise *promise =
    
    dispatch_promise_on(dispatch_get_main_queue(),^id(){
        NSString *currentFilePath = [MHXcodeDocumentNavigator currentFilePath];
        IsFilePathEmpty(currentFilePath);
        NSTextView *currentTextView = [MHXcodeDocumentNavigator currentSourceCodeTextView];
        
        return PMKManifold(currentFilePath,currentTextView);
    }).thenOn(dispatch_get_global_queue(0, 0), ^id(NSString *currentFilePath,NSTextView *currentTextView){
        
        NSString *lastPathComponent = [currentFilePath lastPathComponent];
        
        BOOL isHeaderFile = ([lastPathComponent rangeOfString:@".h"].location != NSNotFound);
        BOOL isCategoryFile = ([lastPathComponent rangeOfString:@"+"].location != NSNotFound);
        //头文件
        if (isHeaderFile && !isCategoryFile)
            return error(@"一般类的头文件不处理", 10, nil);
        //解析ClassName
        NSString *matchClassNameStr =  [lastPathComponent substringToIndex:lastPathComponent.length - 2];
        if (isCategoryFile) {
            NSArray * classNameArr = [matchClassNameStr componentsSeparatedByString:@"+"];
            if (!classNameArr || [classNameArr count] == 0)
                return  error(@"获取分类名失败", 0, nil);
            matchClassNameStr = [NSString stringWithFormat:@"%@\\s*\\(\\s*%@\\s*\\)",classNameArr[0],classNameArr[1]];
        }
        
        // 匹配.m 内容
        NSString *soureString = @"";
        if (isHeaderFile) {
            //读取.h 内容
            currentFilePath =
            [currentFilePath stringByReplacingCharactersInRange:NSMakeRange(currentFilePath.length - 1, 1) withString:@"m"];
            
            soureString = [NSString stringWithContentsOfFile:currentFilePath encoding:NSUTF8StringEncoding error:nil];
            if (!soureString||soureString.length == 0)
                return error(@"读取文件失败", 0, nil);
            
        }else{
            soureString = currentTextView.textStorage.string;
        }
        if (soureString.length == 0)
            return error(@"获取文件内容失败", 0, nil);
        
        //匹配@end
        NSArray *endMatches = [soureString matcheStrWith:@"@end"];
        if (!endMatches || [endMatches count] == 0)
            return error(@"获取@end位置失败", 0, nil);
        //直接使用end
        if ([endMatches count] == 1)
            return  [NSValue valueWithRange:[endMatches[0] range]];
        
        
        //匹配到多个@end 则 匹配@implementation className
        NSString *matchStr = [NSString stringWithFormat:@"@implementation\\s+%@\\s*",matchClassNameStr];
        
        NSArray *impMatches = [soureString matcheStrWith:matchStr];
        if (!impMatches || [impMatches count] != 1)
            return error(@"获取categoryName位置错误", 0, nil);
        
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


#pragma mark - 生成所有get方法代码字符串

/**
 *  生成所有get方法代码字符串
 *
 *  @param propertyDic propertyDic description
 *
 *  @return return value description
 */
- (NSString *)AppendMethodesStrWithPropertyArr:(NSArray *)propertyArr CurrentSourceCodeTextView:(NSTextView *)textView
{
    NSMutableString *allMethodsStr = [NSMutableString stringWithCapacity:0];
    NSString *regexPragma = @"#pragma  mark - Getter";
    // 对str字符串进行匹配
    NSArray *pragmaMatches = [textView.textStorage.string matcheStrWith:@"Getter"];
    
    if (!(pragmaMatches && [pragmaMatches count] > 0)) {
        [allMethodsStr appendString:regexPragma];
    }
    [allMethodsStr appendString:@"\n"];
    
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

#pragma mark - 解析选中内容，返回类型和变量名的dic

/**
 *  解析选中内容，返回类型和变量名的dic
 *
 *  @param sourceStr sourceStr description
 *
 *  @return return value description
 */
+ (NSArray *)MatcheSelectText:(NSString *)sourceStr
{
    NSMutableArray *propertyArr = [NSMutableArray arrayWithCapacity:0];
    NSRange tempRange = [sourceStr rangeOfString:@"@end"];
    if (tempRange.location != NSNotFound) {
        return propertyArr;
    }
    
    NSArray *mathcheArr = [sourceStr matcheGroupWith:propertyMatcheStr];
    if (!mathcheArr || [mathcheArr count] == 0) {
        return propertyArr;
    }
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

#pragma mark - 根据配置构造get方法

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
    
    NSString *typeStr = keyType;
    NSString *ivarNameStr = [NSString stringWithFormat:@"_%@", valueIvar];
    
    [methodStr appendFormat:@"-(%@ *)%@{if(!%@){", typeStr, valueIvar, ivarNameStr];
    
    
    if (self.configDic && [[self.configDic allKeys] containsObject:typeStr]) {
        NSArray *configList = self.configDic[typeStr];
        [configList enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [methodStr appendFormat:obj, ivarNameStr];
        }];
    } else {
        [methodStr appendFormat:@"%@ = [[%@ alloc] init];", ivarNameStr, typeStr];
    }
    [methodStr appendFormat:@"}return %@;}", ivarNameStr];
    return [NSString stringWithString:methodStr];
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
        QYSettingModel *setModel = [[QYIDENotificationHandler sharedHandler] settingModel];
        
        if (!setModel.getterJSON || setModel.getterJSON.length == 0) {
            return nil;
        }
        NSData *jsonData = [setModel.getterJSON dataUsingEncoding:NSUTF8StringEncoding];
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


@end
