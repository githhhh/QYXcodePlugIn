//
//  QYPreferencesMenuItem.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 16/1/13.
//  Copyright © 2016年 X.Y. All rights reserved.
//

#import "QYPreferencesMenuItem.h"
#import "Promise.h"

@implementation QYPreferencesMenuItem

- (instancetype)init {
    self = [super init];

    if (self) {
        self.target = self;
        self.action = @selector(menuItemAction:);
        self.title = QYMenu_Settings;
    }

    return self;
}

- (void)menuItemAction:(id)sender {
    [super menuItemAction:sender];
    self.windowDelegate = [[QYXcodePlugIn sharedPlugin] notificationHandler];

    PMKPromise *promise = [PMKPromise promiseWithValue:@1];

    if (self.windowDelegate && [self.windowDelegate respondsToSelector:@selector(receiveMenuItemPromise:sender:)]) [self.windowDelegate receiveMenuItemPromise:promise sender:self];
}

#pragma mark - 动态绑定热键
- (void)bindDynamicHoteKey {
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];

    [self bind:@"keyEquivalent"
           toObject:defaults
        withKeyPath:SettingsMenuKeyPath
            options:@{ NSValueTransformerBindingOption: [SRKeyEquivalentTransformer new] }];

    [self bind:@"keyEquivalentModifierMask"
           toObject:defaults
        withKeyPath:SettingsMenuKeyPath
            options:@{ NSValueTransformerBindingOption: [SRKeyEquivalentModifierMaskTransformer new] }];
}

@end