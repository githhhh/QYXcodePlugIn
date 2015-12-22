//
//  QYIDENotificationHandler.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/22.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "QYSettingModel.h"

@interface QYIDENotificationHandler : NSObject

@property (nonatomic, retain) id globlaParamter;

+ (id)sharedHandler;

- (NSString *)clangFormateContentPath;
- (QYSettingModel *)settingModel;
@end
