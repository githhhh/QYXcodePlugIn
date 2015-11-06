//
//  MenuItemAchieve.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/18.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//

#import "MenuItemAchieve.h"
#import <AppKit/AppKit.h>
#import <objc/runtime.h>
#import "NSMenuItem+QYXcodePluginMenuItem.h"
@implementation MenuItemAchieve

+ (id)createMenuActionResponse:(NSMenuItem *)item preBlock:(BOOL(^)(void))preBlock{
    BOOL isContinue = YES;
    if (preBlock) {
        isContinue = preBlock();
    }
    if (!isContinue) {
        return nil;
    }
    
    NSString *className = item.achieveClassName;
    
    Class achieveClass = NSClassFromString(className);
    if (!achieveClass) {
        NSLog(@"====确保实现类名和对应菜单名称一致========");
        return nil;
    }
    id obj = nil;
    if (item.tag>10) {
        obj = [[achieveClass alloc] initWithWindowNibName:className];
    }else{
        obj = [[achieveClass alloc] init];
        if (![obj conformsToProtocol:@protocol(QYMenuActionProtocol)]) {
            NSLog(@"====确保实现类实现=QYMenuActionProtocol=======");
            return nil;
        }
    }
    
    

    return obj;
}



@end
