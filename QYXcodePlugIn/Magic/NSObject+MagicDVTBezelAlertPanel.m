//
//  NSObject+MagicDVTBezelAlertPanel.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/12/30.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "NSObject+MagicDVTBezelAlertPanel.h"
#import "NSObject+MethodSwizzler.h"

@implementation NSObject (MagicDVTBezelAlertPanel)


+ (void)load
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{

        [NSClassFromString(@"DVTBezelAlertPanel")
         swizzleWithOriginalSelector:NSSelectorFromString(@"initWithIcon:message:parentWindow:duration:")
         swizzledSelector:@selector(Rayrolling_initWithIcon:message:parentWindow:duration:)
         isClassMethod:NO];
    });
}


- (id)Rayrolling_initWithIcon:(id)icon message:(id)message parentWindow:(id)window duration:(double)duration
{
    if (icon) {
        NSBundle *bundle = [NSBundle bundleWithIdentifier:@"X.Y.QYXcodePlugIn"];
        NSImage *newImage = [bundle imageForResource:@"fail.pdf"];
        return [self Rayrolling_initWithIcon:newImage message:message parentWindow:window duration:duration];
    }
    return [self Rayrolling_initWithIcon:icon message:message parentWindow:window duration:duration];
}


@end
