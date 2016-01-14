//
//  NSObject+MagicClearCatalogFilter.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 16/1/9.
//  Copyright © 2016年 X.Y. All rights reserved.
//

#import "NSObject+MagicClearCatalogFilter.h"
#import "NSObject+MethodSwizzler.h"
#import "NSString+Files.h"
#import "MHXcodeDocumentNavigator.h"
@implementation NSObject (MagicClearCatalogFilter)
+ (void)load
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        [NSClassFromString(@"DVTStateToken")
         swizzleWithOriginalSelector:NSSelectorFromString(@"_pullStateFromDictionary:")
         swizzledSelector:@selector(sw__pullStateFromDictionary:)
         isClassMethod:NO];
    });
}

-(void)sw__pullStateFromDictionary:(id)arg{
    QYPreferencesModel *preferencesModel =  [[QYIDENotificationHandler sharedHandler] preferencesModel];
    
    if (preferencesModel.isClearCalalogSearchTitle && [arg count]==2 ) {
        if ([[arg allKeys] containsObject:@"previousFilter"]) {
            [arg setObject:@"" forKey:@"previousFilter"];
        }
    }
    
    [self sw__pullStateFromDictionary:arg];
}


@end
