//
//  QYSettingMenuItem.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/12/21.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "QYSettingMenuItem.h"
#import "Promise.h"
@implementation QYSettingMenuItem
-(instancetype)init{
    self = [super init];
    if (self) {
        self.target = self;
        self.action = @selector(menuItemAction:);
        self.title = QYMenu_Settings;
    }
    return self;
}

-(void)menuItemAction:(id)sender{
    [super menuItemAction:sender];
    self.windowDelegate = [QYIDENotificationHandler sharedHandler];

    PMKPromise *promise = [PMKPromise promiseWithValue:@1];
    
    if (self.windowDelegate&&[self.windowDelegate respondsToSelector:@selector(receiveMenuItemPromise:sender:)])
        [self.windowDelegate receiveMenuItemPromise:promise sender:self];
}

#pragma mark - 动态绑定热键
-(void)bindDynamicHoteKey{
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    
    [self bind:@"keyEquivalent"
                       toObject:defaults
                    withKeyPath:SettingsMenuKeyPath
                        options:@{NSValueTransformerBindingOption : [SRKeyEquivalentTransformer new]}];
    
    [self bind:@"keyEquivalentModifierMask"
                       toObject:defaults
                    withKeyPath:SettingsMenuKeyPath
                        options:@{NSValueTransformerBindingOption : [SRKeyEquivalentModifierMaskTransformer new]}];
    
}
@end
