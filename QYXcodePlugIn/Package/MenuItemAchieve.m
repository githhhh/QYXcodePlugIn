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
@implementation MenuItemAchieve

+ (id<QYMenuActionProtocol> )createMenuActionResponse:(NSMenuItem *)item{
    
    NSString *suffixStr =  @"Achieve";
    NSString *className = [NSString stringWithFormat:@"%@%@",item.title,suffixStr];
    
    Class achieveClass = NSClassFromString(className);
    if (!achieveClass) {
        NSLog(@"====确保实现类名和对应菜单名称一致========");
        return nil;
    }
    id obj = [[achieveClass alloc] init];
    
    if (![obj conformsToProtocol:@protocol(QYMenuActionProtocol)]) {
        NSLog(@"====确保实现类实现=QYMenuActionProtocol=======");

        return nil;
    }
    
    return obj;
}



@end
