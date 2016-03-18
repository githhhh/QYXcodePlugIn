//
//  QYAutoModelMenuItem.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 16/3/14.
//  Copyright © 2016年 X.Y. All rights reserved.
//  Template From QYXcodePlugin
//

#import "QYAutoModelMenuItem.h"
#import "Promise.h"

@implementation QYAutoModelMenuItem
-(instancetype)init{
    self = [super init];
    if (self) {
        self.target = self;
        self.action = @selector(menuItemAction:);
        self.title = QYMenu_AutoModel;
    }
    return self;
}

-(void)menuItemAction:(id)sender{
    [super menuItemAction:sender];
    
    //action
    
    self.windowDelegate = [QYIDENotificationHandler sharedHandler];
    
    PMKPromise *promise = [PMKPromise promiseWithValue:@1];
    
    if (self.windowDelegate && [self.windowDelegate respondsToSelector:@selector(receiveMenuItemPromise:sender:)]) [self.windowDelegate receiveMenuItemPromise:promise sender:self];
}



#pragma mark - 动态绑定热键
-(void)bindDynamicHoteKey{
    
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    
    [self bind:@"keyEquivalent"
      toObject:defaults
   withKeyPath:AutoModelMenuKeyPath
       options:@{NSValueTransformerBindingOption : [SRKeyEquivalentTransformer new]}];
    
    [self bind:@"keyEquivalentModifierMask"
      toObject:defaults
   withKeyPath:AutoModelMenuKeyPath
       options:@{NSValueTransformerBindingOption : [SRKeyEquivalentModifierMaskTransformer new]}];
    
}

@end
