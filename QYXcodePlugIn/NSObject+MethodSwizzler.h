//
//  NSObject+MethodSwizzler.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/12/30.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MethodSwizzler)

+ (void)swizzleWithOriginalSelector:(SEL)originalSelector swizzledSelector:(SEL) swizzledSelector isClassMethod:(BOOL)isClassMethod;
@end
