//
//  RequestTemplateAchieve.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/18.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//

#import "RequestTemplateAchieve.h"
#import "MHXcodeDocumentNavigator.h"
#import "NSString+Extensions.h"
#import "QYXcodePlugIn.h"
#import "XCClassDefinition.h"
#import <objc/runtime.h>
@interface RequestTemplateAchieve ()
@end
@implementation RequestTemplateAchieve

-(void)menuItemAction:(id)paramte{
    
    NSTextView *textView = [MHXcodeDocumentNavigator currentSourceCodeTextView];
    //先获取类名
    NSArray *arr = [textView.textStorage.string matcheGroupWith:@"\\//\\s+(\\w+)\\.m"];
    if ([arr count]==0||[arr count]<1) {
        return;
    }
    NSString *className = arr[1];
    
    //读取.h 文件,判断是否是QYRequest 子类
    NSString *sourcePath = [MHXcodeDocumentNavigator currentFilePath];
    sourcePath = [sourcePath stringByReplacingCharactersInRange:NSMakeRange(sourcePath.length-1, 1) withString:@"h"];
    NSString *soureString = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
   
    NSArray *contents = [soureString matcheGroupWith:@"@\\w+\\s*(\\w+)\\s*\\:\\s+QYRequest\\s"];
    if (!([contents count]>1&&[className isEqualToString:contents[1]])) {
        return;
    }
    
    //.h 中插入 公共方法
    NSString *publishMethodStr = @"\n-(id)initWithParamter:(NSDictionary *)paramterDic;\n";
    NSMutableString *str = [NSMutableString stringWithString:contents[0]];
    [str appendString:publishMethodStr];

    
    NSError *error1 = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@\\w+\\s*(\\w+)\\s*\\:\\s+QYRequest\\s" options:NSRegularExpressionCaseInsensitive error:&error1];
    //完整模板
    NSString *modifiedsoureString = [regex stringByReplacingMatchesInString:soureString options:0 range:NSMakeRange(0, [soureString length]) withTemplate:str];
    
    
    BOOL isWrite = [modifiedsoureString writeToFile:sourcePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (!isWrite) {
        return;
    }
    
    
    //读取模板文件
    QYXcodePlugIn *plugin = [QYXcodePlugIn sharedPlugin];
    NSError *error;
    
    NSString *filePath = [plugin.bundle pathForResource:@"RequestTemplate" ofType:@""];
    
    NSString *templateString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    if (!error&&templateString) {
        //替换模板中的类名
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@&" options:NSRegularExpressionCaseInsensitive error:&error];
        //完整模板
        NSString *modifiedString = [regex stringByReplacingMatchesInString:templateString options:0 range:NSMakeRange(0, [templateString length]) withTemplate:className];
        
        //替换当前文件
        NSArray *impMathches =  [textView.textStorage.string matcheStrWith:@"@\\w+\\s+\\w+\\s+@\\w+"];

        // 遍历匹配后的每一条记录
        NSTextCheckingResult *match = impMathches[0];
        NSRange impRange = [match range];
        [textView insertText:modifiedString replacementRange:impRange];
    }
}





@end
