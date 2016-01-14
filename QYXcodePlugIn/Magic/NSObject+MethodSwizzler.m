//
//  NSObject+MethodSwizzler.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/12/30.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "NSObject+MethodSwizzler.h"
#import <objc/runtime.h>

@implementation NSObject (MethodSwizzler)

+ (void)swizzleWithOriginalSelector:(SEL)originalSelector swizzledSelector:(SEL) swizzledSelector isClassMethod:(BOOL)isClassMethod
{
    Class cls = [self class];
    
    Method originalMethod;
    Method swizzledMethod;
    
    // 2
    if (isClassMethod) {
        originalMethod = class_getClassMethod(cls, originalSelector);
        swizzledMethod = class_getClassMethod(cls, swizzledSelector);
    } else {
        originalMethod = class_getInstanceMethod(cls, originalSelector);
        swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    }
    
    // 3
    if (!originalMethod) {
        NSLog(@"Error: originalMethod is nil, did you spell it incorrectly? %@", originalMethod);
        return;
    }
    
    // 4
    method_exchangeImplementations(originalMethod, swizzledMethod);
}


@end
