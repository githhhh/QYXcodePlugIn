//
//  NSMenu+RegisterMenuItem.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/12/21.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "NSMenu+RegisterMenuItem.h"
#import "QYMenuBaseItem.h"
@implementation NSMenu (RegisterMenuItem)

-(void)registerMenuItem:(Class)menuItemClass{
    if (![menuItemClass isSubclassOfClass:[QYMenuBaseItem class]]) {
        NSAssert(NO, @"注册的menuItem 必须是QYMenuBaseItem子类");
    }
    QYMenuBaseItem *menuItem = [[menuItemClass  alloc] init];
    [self addItem:menuItem];
    [menuItem bindDynamicHoteKey];
}


@end
