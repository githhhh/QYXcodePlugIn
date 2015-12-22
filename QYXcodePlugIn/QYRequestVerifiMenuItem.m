//
//  QYRequestVerifiMenuItem.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/12/21.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "QYRequestVerifiMenuItem.h"
#import "Promise.h"
#import "MHXcodeDocumentNavigator.h"
#import "NSString+Extensions.h"

@implementation QYRequestVerifiMenuItem

-(instancetype)init{
    self = [super init];
    if (self) {
        self.target = self;
        self.action = @selector(menuItemAction:);
        self.title = QYMenu_RequestValidator;
    }
    return self;
}

-(void)menuItemAction:(id)sender{
    [super menuItemAction:sender];
    
    self.windowDelegate = [QYIDENotificationHandler sharedHandler];

    PMKPromise *promise =
    
    dispatch_promise_on(dispatch_get_main_queue(), ^id{
    
        NSString *currentFilePath = [MHXcodeDocumentNavigator currentFilePath];
        if (!currentFilePath)
            return error(@"获取当前文件路径错误。。。", 0, nil);
        
        NSTextView *textView = [MHXcodeDocumentNavigator currentSourceCodeTextView];
        if (!textView)
            return error(@"获取当前textView错误。。。", 0, nil);

        return PMKManifold(currentFilePath,textView);
    }).thenOn(dispatch_get_global_queue(0, 0),^id(NSString *currentFilePath,NSTextView *textView){
        
        currentFilePath =
        [currentFilePath stringByReplacingCharactersInRange:NSMakeRange(currentFilePath.length - 1, 1) withString:@"h"];
        //读取.h 内容
        NSString *soureString = [NSString stringWithContentsOfFile:currentFilePath encoding:NSUTF8StringEncoding error:nil];
    
        //读取配置
        NSUserDefaults *userdf = [NSUserDefaults standardUserDefaults];
        NSString *requstBName = [userdf objectForKey:rqBName];
        if (!requstBName) {
            requstBName = @"QYRequest";
        }

        // 验证当前.h 文件的父类是否是制定类
        NSArray *contents =
        [soureString matcheGroupWith:[NSString stringWithFormat:@"@\\w+\\s*(\\w+)\\s*\\:\\s+%@\\s", requstBName]];
        if (!([contents count] > 0)) {
            return error(@"当前类和指定类没有匹配。。。", 0, nil);
        }
        return @1;
    });
    
    if (self.windowDelegate&&[self.windowDelegate respondsToSelector:@selector(receiveMenuItemPromise:sender:)])
        [self.windowDelegate receiveMenuItemPromise:promise sender:self];
}

#pragma mark - 动态绑定热键
-(void)bindDynamicHoteKey{
    
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];

    [self bind:@"keyEquivalent"
                            toObject:defaults
                         withKeyPath:RequestVerifiMenuKeyPath
                             options:@{NSValueTransformerBindingOption : [SRKeyEquivalentTransformer new]}];
    [self
     bind:@"keyEquivalentModifierMask"
     toObject:defaults
     withKeyPath:RequestVerifiMenuKeyPath
     options:@{NSValueTransformerBindingOption : [SRKeyEquivalentModifierMaskTransformer new]}];
}
@end
