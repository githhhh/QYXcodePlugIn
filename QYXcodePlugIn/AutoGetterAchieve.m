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
@interface AutoGetterAchieve()

@end

@implementation AutoGetterAchieve

-(void)menuItemAction:(NSString *)selecteText{
    
    if (!(selecteText && selecteText.length > 0)) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"没有选中任何内容"];
        [alert runModal];
        return;
    }
    
    NSMutableArray *sourceArr = [NSMutableArray arrayWithCapacity:0];
    NSArray *arr = [selecteText componentsSeparatedByString:@"\n"];
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *temp = arr[idx];
        if (temp.length > 0 && [temp containsString:@"*"]) {
            [sourceArr addObject:arr[idx]];
        }
    }];
    if ([sourceArr count] == 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"确保选中了属性"];
        [alert runModal];
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
        
        NSString *tempStr = [self getResulteWithString:sourceArr[idx]];
        [resulteStr appendString:tempStr];
    }];
    
    [resulteStr appendString:@"@end"];
    
    NSString *getString = [NSString stringWithString:resulteStr];
    
    // 对str字符串进行匹配
    NSArray *endMatches =
    [textView.textStorage.string matcheStrWith:@"@end"];
    
    if ([endMatches count] > 0) {
        NSInteger count = endMatches.count;
        NSTextCheckingResult *match = endMatches[count - 1];
        NSRange lastEndRange = [match range];
        [textView insertText:getString replacementRange:lastEndRange];
    }

    
     
}



-(NSString *)getResulteWithString:(NSString *)itemString{
    
    NSMutableString *mString = [NSMutableString stringWithCapacity:0];
    
    NSString * typeStr = @"";
    NSString * nameStr =  @"";
    NSArray *arr = [itemString componentsSeparatedByString:@"*"];
    NSArray *arr1 = [arr[0] componentsSeparatedByString:@")"];
    typeStr = arr1[1];
    typeStr = [typeStr  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    nameStr = [arr[1] substringToIndex:([NSString stringWithFormat:@"%@",arr[1]].length - 1)];
    nameStr = [nameStr  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    
    NSString *ivarNameStr = [NSString stringWithFormat:@"_%@",nameStr];
    [mString appendFormat:@"\n-(%@ *)%@{\n      if(!%@){\n",typeStr,nameStr,ivarNameStr];
    [mString appendFormat:@"          %@ = [[%@ alloc] init];\n",ivarNameStr,typeStr];
    
    
    if ([typeStr isEqualToString:@"UILabel"]) {
        [mString appendFormat:@"          %@.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1];\n",ivarNameStr];
        [mString appendFormat:@"          %@.textAlignment = NSTextAlignmentLeft;\n",ivarNameStr];
        [mString appendFormat:@"          %@.font = [QYFont fontWithName:Default_Font size:0.0f];\n",ivarNameStr];
        [mString appendFormat:@"          %@.backgroundColor = [UIColor clearColor];\n",ivarNameStr];
        [mString appendFormat:@"          %@.numberOfLines = 0;\n",ivarNameStr];
        [mString appendFormat:@"          %@.lineBreakMode =  NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail;\n",ivarNameStr];
        
        
    }else if([typeStr isEqualToString:@"NIAttributedLabel"]){
        [mString appendFormat:@"          %@.verticalTextAlignment =  NIVerticalTextAlignmentTop;\n",ivarNameStr];
        
        [mString appendFormat:@"          %@.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1];\n",ivarNameStr];
        [mString appendFormat:@"          %@.textAlignment = NSTextAlignmentLeft;\n",ivarNameStr];
        [mString appendFormat:@"          %@.font = [QYFont fontWithName:Default_Font size:0.0f];\n",ivarNameStr];
        [mString appendFormat:@"          %@.backgroundColor = [UIColor clearColor];\n",ivarNameStr];
        [mString appendFormat:@"          %@.numberOfLines = 0;\n",ivarNameStr];
        [mString appendFormat:@"          %@.lineBreakMode =  NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail;\n",ivarNameStr];
        
    }
    else if([typeStr isEqualToString:@"UIView"]){
        [mString appendFormat:@"          %@.backgroundColor = [UIColor clearColor];\n",ivarNameStr];
        
        
        
    }else if([typeStr isEqualToString:@"UIImageView"]){
        [mString appendFormat:@"          %@.image = [UIImage  imageNamed:@""];\n",ivarNameStr];
        
    }else if([typeStr isEqualToString:@"UIButton"]){
        [mString appendFormat:@"          %@.backgroundColor = [UIColor clearColor];\n",ivarNameStr];
        
    }else if ([typeStr isEqualToString:@"QYMutableLable"]){
        [mString appendFormat:@"          %@.lable.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1];\n",ivarNameStr];
        [mString appendFormat:@"          %@.lable.font = [QYFont fontWithName:Default_Font size:0.0f];\n",ivarNameStr];
        
        [mString appendFormat:@"          %@.loadMoreLable.font = [QYFont fontWithName:Default_Font size:0.0f];\n",ivarNameStr];
        [mString appendFormat:@"          %@.loadMoreLable.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1];\n",ivarNameStr];
    }
    
    else if([typeStr isEqualToString:@"NSURL"]){
        [mString appendString:@"\n \n"];
    }else{
        [mString appendString:@"\n \n"];
    }
    
    [mString appendFormat:@"      }\n      return %@;\n}\n \n",ivarNameStr];
    
    return [NSString stringWithString:mString];
}



@end
