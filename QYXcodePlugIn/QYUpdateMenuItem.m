//
//  QYUpdateMenuItem.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 16/4/20.
//  Copyright © 2016年 X.Y. All rights reserved.
//

#import "QYUpdateMenuItem.h"
#import "QYUpdateModel.h"

@interface QYUpdateMenuItem ()

@property (nonatomic, retain) QYUpdateModel *updateModel;

@end

@implementation QYUpdateMenuItem
-(instancetype)init{
    self = [super init];
    if (self) {
        self.target = self;
        self.action = @selector(menuItemAction:);
        self.title = QYMenu_UpdatePlugin;
    }
    return self;
}

-(void)menuItemAction:(id)sender{
    [super menuItemAction:sender];
    /**
     更新
     */
    [self.updateModel updateVersion];
}

#pragma mark - 动态绑定热键
-(void)bindDynamicHoteKey{
    
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    
    [self bind:@"keyEquivalent"
      toObject:defaults
   withKeyPath:UpdatePluginMenuKeyPath
       options:@{NSValueTransformerBindingOption : [SRKeyEquivalentTransformer new]}];
    
    [self bind:@"keyEquivalentModifierMask"
      toObject:defaults
   withKeyPath:UpdatePluginMenuKeyPath
       options:@{NSValueTransformerBindingOption : [SRKeyEquivalentModifierMaskTransformer new]}];
    
}

#pragma mark -  AutoGetter

- (QYUpdateModel *)updateModel {
    if (!_updateModel) {
        _updateModel = [[QYUpdateModel alloc] init];
    }

    return _updateModel;
}

@end
