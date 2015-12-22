//
//  QYCategoryPropertyMenuItem.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/12/21.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "QYCategoryPropertyMenuItem.h"
#import "CategoryGetterSetterAchieve.h"

@implementation QYCategoryPropertyMenuItem

-(instancetype)init{
    self = [super init];
    if (self) {
        self.target = self;
        self.action = @selector(menuItemAction:);
        self.title = QYMenu_CategoryProperty;
    }
    return self;
}

-(void)menuItemAction:(id)sender{
    [super menuItemAction:sender];
    
    CategoryGetterSetterAchieve *categoryGS = [[CategoryGetterSetterAchieve alloc] init];
    [categoryGS createCategoryGetterSetterAction];
}

#pragma mark - 动态绑定热键
-(void)bindDynamicHoteKey{
    
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    
    [self bind:@"keyEquivalent"
                               toObject:defaults
                            withKeyPath:AutoCategorySetterGetterMenuKeyPath
                                options:@{NSValueTransformerBindingOption : [SRKeyEquivalentTransformer new]}];
    [self bind:@"keyEquivalentModifierMask"
                               toObject:defaults
                            withKeyPath:AutoCategorySetterGetterMenuKeyPath
                                options:@{NSValueTransformerBindingOption : [SRKeyEquivalentModifierMaskTransformer new]}];
}


@end
