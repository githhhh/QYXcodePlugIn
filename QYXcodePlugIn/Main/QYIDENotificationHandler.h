//
//  QYIDENotificationHandler.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/22.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "QYPreferencesModel.h"
#import <dlfcn.h>

#define ClangFormateContentPath  [[[QYXcodePlugIn sharedPlugin] notificationHandler] clangFormateContentPath]

#define PreferencesModel  [[[QYXcodePlugIn sharedPlugin] notificationHandler] preferencesModel]


@interface QYIDENotificationHandler : NSObject

- (NSString *)clangFormateContentPath;

- (QYPreferencesModel *)preferencesModel;

- (void)updatePreferencesModel:(QYPreferencesModel *)preferencesModel;

@end
