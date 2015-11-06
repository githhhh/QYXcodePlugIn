//
//  NSMenuItem+QYXcodePluginMenuItem.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/11/6.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "NSMenuItem+QYXcodePluginMenuItem.h"
#import <objc/runtime.h>
static const char *achieveClassNameKey = "achieveClassNameKey";
@implementation NSMenuItem (QYXcodePluginMenuItem)



-(void)setAchieveClassName:(NSString *)achieveClassName{
    objc_setAssociatedObject(self, &achieveClassNameKey, achieveClassName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)achieveClassName{
   return  objc_getAssociatedObject(self, &achieveClassNameKey);
}


@end
