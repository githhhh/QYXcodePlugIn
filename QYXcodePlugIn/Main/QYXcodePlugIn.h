//
//  QYXcodePlugIn.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/18.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "QYIDENotificationHandler.h"

@interface QYXcodePlugIn : NSObject

@property (nonatomic, strong, readonly) NSBundle* bundle;

@property (nonatomic, retain ,readonly) QYIDENotificationHandler *notificationHandler;

+ (void)pluginDidLoad:(NSBundle *)plugin;

+ (void)reloadPlugin:(NSBundle *)plugin;

+ (instancetype)sharedPlugin;

@end