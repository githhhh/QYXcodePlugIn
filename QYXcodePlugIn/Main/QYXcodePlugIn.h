//
//  QYXcodePlugIn.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/18.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface QYXcodePlugIn : NSObject

@property (nonatomic, strong, readonly) NSBundle* bundle;

+ (void)pluginDidLoad:(NSBundle *)plugin;

+ (instancetype)sharedPlugin;

@end