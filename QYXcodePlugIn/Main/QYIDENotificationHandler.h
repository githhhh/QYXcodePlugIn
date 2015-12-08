//
//  QYIDENotificationHandler.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/22.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface QYIDENotificationHandler : NSObject
+ (id)sharedHandler;
@property (nonatomic,retain)id globlaParamter;

@property (nonatomic,retain)NSMenuItem* geterMenuItem;
@property (nonatomic,retain)NSMenuItem* requestVerifiMenuItem;
@property (nonatomic,retain)NSMenuItem* settingsMenuItem;

- (NSString *)projectTempFilePath;
@end
