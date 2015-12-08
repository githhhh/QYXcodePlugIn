//
//  AutoGetterAchieve.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/18.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//

#import "AutoGetterAchieve.h"
#import <AppKit/AppKit.h>
#import "MHXcodeDocumentNavigator.h"
#import "NSString+Extensions.h"
#import "QYClangFormat.h"
#import "QYPluginSetingController.h"
#import "QYIDENotificationHandler.h"
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


- (void)getterAction:(NSString *)selecteText
{
    if (!selecteText || (selecteText.length == 0)) {
        return;
    }
    NSTextView *currentCodeTextView = [MHXcodeDocumentNavigator currentSourceCodeTextView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //解析选中property
        NSArray *propertyArr = [self MatcheSelectText:selecteText];
        if ([propertyArr count] == 0) {
            return;
        }
        //格式化选中代码
        NSRange raplaceRange = [currentCodeTextView.textStorage.string rangeOfString:selecteText];
        NSString *formateCode =[self FormatCode:selecteText ReplaceRange:raplaceRange  OnCodeTextView:currentCodeTextView];
        if (!formateCode) {
            return;
        }
        NSRange formateCodeRange = [currentCodeTextView.textStorage.string rangeOfString:formateCode];
        
        //拼接方法
        NSString *allMethodsStr = [self AppendMethodesStrWithPropertyArr:propertyArr CurrentSourceCodeTextView:currentCodeTextView];
        if (allMethodsStr.length == 0) {
            return;
        }
        //格式化代码
      
        NSRange endRange = [self FindReplaceLocationBySelectedRange:formateCodeRange andCurrentSourceCodeTextView:currentCodeTextView];
        [self FormatCode:allMethodsStr ReplaceRange:endRange OnCodeTextView:currentCodeTextView];
    });
}

/**
 *  格式代码并替换
 *
 *  @param source       source description
 *  @param raplaceRange raplaceRange description
 *  @param codeTextView codeTextView description
 *
 *  @return return value description
 */
- (NSString *)FormatCode:(NSString *)source ReplaceRange:(NSRange)raplaceRange OnCodeTextView:(NSTextView *)codeTextView
{
    if (raplaceRange.location == NSNotFound || !source || source.length == 0) {
        return nil;
    }
    NSString *formatedCode = [QYClangFormat clangFormatSourceCode:source ];
    if (!formatedCode || formatedCode.length == 0) {
        return nil;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [codeTextView insertText:formatedCode replacementRange:raplaceRange];
    });
    return formatedCode;
}

/**
 *  根据选中内容位置确定插入代码位置
 *
 *  @param selecteText selecteText description
 *
 *  @return return value description
 */
- (NSRange)FindReplaceLocationBySelectedRange:(NSRange)seletedRange andCurrentSourceCodeTextView:(NSTextView *)textView
{
    // 查找对应@end 位置
    if (seletedRange.location == NSNotFound||!textView) {
        return NSMakeRange(0, 0);
    }
    
    NSArray *endMatches = [textView.textStorage.string matcheStrWith:@"@end"];
    if (!(endMatches && [endMatches count] >= 2)) {
        return NSMakeRange(0, 0);
    }
    __block NSInteger index = 0;
    [endMatches enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        NSTextCheckingResult *match = endMatches[idx];
        NSRange range = [match range];
        if (seletedRange.location < range.location) {
            index = idx;
            *stop = YES;
        }
    }];
    NSTextCheckingResult *match = endMatches[index + 1];
    NSRange endRange = [match range];
    return endRange;
}


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


/**
 *  获取配置信息
 *
 *  @return return value description
 */
- (NSDictionary *)configDic
{
    if (!_configDic) {
        NSUserDefaults *userdf = [NSUserDefaults standardUserDefaults];
        NSString *allContent = [userdf objectForKey:geterSetingKey];
        if (!allContent || allContent.length == 0) {
            return nil;
        }
        NSData *jsonData = [allContent dataUsingEncoding:NSUTF8StringEncoding];
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
