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
#import "QYMenuBaseItem.h"

#define ClangFormateContentPath  [[[QYXcodePlugIn sharedPlugin] notificationHandler] clangFormateContentPath]

#define PreferencesModel  [[[QYXcodePlugIn sharedPlugin] notificationHandler] preferencesModel]


@interface QYIDENotificationHandler : NSObject<MenuItemPromiseDelegate>

- (NSString *)clangFormateContentPath;

- (QYPreferencesModel *)preferencesModel;

- (void)updatePreferencesModel:(QYPreferencesModel *)preferencesModel;

- (void)didApplicationFinishLaunchingNotification:(NSNotification *)noti;

@end
