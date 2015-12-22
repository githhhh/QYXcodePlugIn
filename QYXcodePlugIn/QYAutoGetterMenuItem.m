//
//  QYAutoGetterMenuItem.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/12/21.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "QYAutoGetterMenuItem.h"
#import "AutoGetterAchieve.h"
#import "QYIDENotificationHandler.h"
@implementation QYAutoGetterMenuItem


-(instancetype)init{
    self = [super init];
    if (self) {
        self.target = self;
        self.action = @selector(menuItemAction:);
        self.title = QYMenu_AutoGetter;
    }
    return self;
}

-(void)menuItemAction:(id)sender{
    [super menuItemAction:sender];
    AutoGetterAchieve *agAchieve = [[AutoGetterAchieve alloc] init];
    [agAchieve createGetterAction];
}

#pragma mark - 动态绑定热键
-(void)bindDynamicHoteKey{

    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    
    [self bind:@"keyEquivalent"
                    toObject:defaults
                 withKeyPath:AutoGetterMenuKeyPath
                     options:@{NSValueTransformerBindingOption : [SRKeyEquivalentTransformer new]}];
    
    [self bind:@"keyEquivalentModifierMask"
                    toObject:defaults
                 withKeyPath:AutoGetterMenuKeyPath
                     options:@{NSValueTransformerBindingOption : [SRKeyEquivalentModifierMaskTransformer new]}];
    
}

@end
