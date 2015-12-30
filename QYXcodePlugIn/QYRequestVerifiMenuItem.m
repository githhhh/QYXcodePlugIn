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
#import "AutoGetterAchieve.h"
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

    // 验证请求文件。。
    PMKPromise *promise =
    
    dispatch_promise_on(dispatch_get_main_queue(), ^id{
        
        return [MHXcodeDocumentNavigator currentSourceCodeTextView];
        
    }).thenOn(dispatch_get_global_queue(0, 0),^id(NSTextView *textView){
        //读取.h 内容
        NSString *currentFilePath = [MHXcodeDocumentNavigator currentFilePath];
        currentFilePath =
        [currentFilePath stringByReplacingCharactersInRange:NSMakeRange(currentFilePath.length - 1, 1) withString:@"h"];
        NSString *soureString = [NSString stringWithContentsOfFile:currentFilePath encoding:NSUTF8StringEncoding error:nil];
    
        //读取配置
        NSString *requstBName = [[QYIDENotificationHandler sharedHandler] settingModel].requestClassBaseName;
        
        // 验证当前.h 文件的父类是否是制定类
        NSArray *contents =
        [soureString matcheGroupWith:[NSString stringWithFormat:@"@\\w+\\s*(\\w+)\\s*\\:\\s+%@\\s", requstBName]];
        if (ArrIsEmpty(contents)){
            NSString *errInfo  = [NSString stringWithFormat:@"该功能只适用于%@ 的子类",requstBName];
            return error(errInfo, 0, nil);
        }
        //返回插入位置。。
        return [AutoGetterAchieve promiseInsertLoction];
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
