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
#import "QYClangFormatCode.h"
#import "QYPluginSetingController.h"
@interface AutoGetterAchieve()

@end

@implementation AutoGetterAchieve

-(void)dealloc{
    NSLog(@"===AutoGetterAchieve=======dealloc=");
}


-(void)getterAction:(NSString *)selecteText{
    if (!(selecteText && selecteText.length > 0)) {
        return;
    }
    NSString *currentFilePath = [MHXcodeDocumentNavigator currentFilePath];

    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableArray *sourceArr = [NSMutableArray arrayWithCapacity:0];
        NSArray *arr = [selecteText componentsSeparatedByString:@"\n"];
        [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *temp = arr[idx];
            if (temp.length > 0 && [temp containsString:@"*"]) {
                [sourceArr addObject:arr[idx]];
            }
        }];
        if ([sourceArr count] == 0) {
            return;
        }
        
        NSTextView *textView = [MHXcodeDocumentNavigator currentSourceCodeTextView];
        NSMutableString *resulteStr = [NSMutableString stringWithCapacity:0];
        NSString *regexPragma = @"#pragma  mark -\n#pragma  mark - getter\n";
        // 对str字符串进行匹配
        NSArray *pragmaMatches =
        [textView.textStorage.string matcheStrWith:regexPragma];
        
        if (!(pragmaMatches && [pragmaMatches count] > 0)) {
            [resulteStr appendString:regexPragma];
        }
        
        [sourceArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSString *tempStr = [self getMethodStr:sourceArr[idx]];
            [resulteStr appendString:tempStr];
        }];
        
        [resulteStr appendString:@"\n\n@end"];
        
        NSString *getString = [QYClangFormatCode clangFormatSourceCode:resulteStr andFilePath:currentFilePath];
        // 对str字符串进行匹配
        NSArray *endMatches =
        [textView.textStorage.string matcheStrWith:@"@end"];
        
        if ([endMatches count] > 0) {
            
            NSInteger count = endMatches.count;
            NSTextCheckingResult *match = endMatches[count - 1];
            NSRange lastEndRange = [match range];
            
            dispatch_async(dispatch_get_main_queue(), ^{
              [textView insertText:getString replacementRange:lastEndRange];
            });
        }
        
    });
     
}



-(NSString *)getMethodStr:(NSString *)itemString{
    
    NSMutableString *mString = [NSMutableString stringWithCapacity:0];
    
    NSString * typeStr = @"";
    NSString * propertyNameStr =  @"";
    NSArray *tempArr = [itemString componentsSeparatedByString:@"*"];
    NSArray *arr1 = [tempArr[0] componentsSeparatedByString:@")"];
    typeStr = arr1[1];
    typeStr = [typeStr  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    propertyNameStr = [tempArr[1] substringToIndex:([NSString stringWithFormat:@"%@",tempArr[1]].length - 1)];
    propertyNameStr = [propertyNameStr  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    
    NSString *ivarNameStr = [NSString stringWithFormat:@"_%@",propertyNameStr];
    
    
    [mString appendFormat:@"-(%@ *)%@{if(!%@){",typeStr,propertyNameStr,ivarNameStr];
    
    //具体内容。。。
    NSUserDefaults *userdf = [NSUserDefaults standardUserDefaults];
    NSString *allContent = [userdf objectForKey:geterSetingKey];
    if (allContent||allContent.length>0) {
        NSData *jsonData = [allContent dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        if(err) {
            NSLog(@"json解析失败：%@",err);
        }else{
            if ([[dic allKeys] containsObject:typeStr]) {
                NSArray *arrList = dic[typeStr];
                [arrList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [mString appendFormat:obj,ivarNameStr];
                }];
            }else{
                [mString appendFormat:@"%@ = [[%@ alloc] init];",ivarNameStr,typeStr];
            }
        }
    }else{
        [mString appendFormat:@"%@ = [[%@ alloc] init];",ivarNameStr,typeStr];
    }

    [mString appendFormat:@"}return %@;}",ivarNameStr];
    return [NSString stringWithString:mString];
}

@end
