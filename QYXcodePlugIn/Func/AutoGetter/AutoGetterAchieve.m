//
//  AutoGetterAchieve.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/18.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//

#import "AutoGetterAchieve.h"
#import "MHXcodeDocumentNavigator.h"
#import "NSString+Extensions.h"
#import "QYClangFormat.h"
#import "QYIDENotificationHandler.h"
#import "QYPluginSetingController.h"
#import <AppKit/AppKit.h>
#import "Promise.h"
#import "Promise+When.h"
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
    NSString *selecteText = globleParamter;
    PMKPromise *cfGetterPromise = [self promiseClangFormateGetterStr:selecteText];
    PMKPromise *cfSelectePromise = [QYClangFormat promiseClangFormatSourceCode:selecteText];
    PMKPromise *insertLocPromise = [self prommiseReplaceLocationBySelecteText:selecteText];
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
        NSArray *propertyArr = [self MatcheSelectText:selecteText];
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


#pragma mark - 根据选中内容位置确定插入代码位置

/**
 *  根据选中内容位置确定插入代码位置
 *
 *  @param selecteText selecteText description
 *
 *  @return return value description
 */
- (PMKPromise *)prommiseReplaceLocationBySelecteText:(NSString *)selecteText
{
    PMKPromise *insertRange =
    dispatch_promise_on(dispatch_get_main_queue(), ^id(){
        if (!selecteText||selecteText.length == 0) {
            return error(@"选中内容为空。。。", 0, nil);
        }
        NSTextView *currentCodeTextView = [MHXcodeDocumentNavigator currentSourceCodeTextView];
        if (!currentCodeTextView) {
            return error(@"获取当前TextView失败。。。", 0, nil);
        }
        return currentCodeTextView;
    }).thenOn(dispatch_get_global_queue(0, 0),^id(NSTextView *currentCodeTextView){

        NSRange selecteRange = [currentCodeTextView.textStorage.string rangeOfString:selecteText];
        // 查找对应@end 位置
        if (selecteRange.location == NSNotFound)
            return error(@"获取选中range失败。。。", 0, nil);
        
        NSArray *endMatches = [currentCodeTextView.textStorage.string matcheStrWith:@"@end"];
        if (!(endMatches && [endMatches count] >= 2))
            return error(@"获取end位置失败", 0, nil);
        
        __block NSInteger index = 0;
        [endMatches enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            NSTextCheckingResult *match = endMatches[idx];
            NSRange range = [match range];
            if (selecteRange.location < range.location) {
                index = idx;
                *stop = YES;
            }
        }];
    
        NSTextCheckingResult *match = endMatches[index + 1];
        NSRange endRange = [match range];
        return [NSValue valueWithRange:endRange];
    });
    
    return insertRange;
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
- (NSArray *)MatcheSelectText:(NSString *)sourceStr
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
