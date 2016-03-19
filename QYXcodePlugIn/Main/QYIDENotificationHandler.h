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

#define ClangFormateContentPath  [[QYIDENotificationHandler sharedHandler] clangFormateContentPath]

#define PreferencesModel  [[QYIDENotificationHandler sharedHandler] preferencesModel]


@interface QYIDENotificationHandler : NSObject

+ (id)sharedHandler;

- (NSString *)clangFormateContentPath;

- (QYPreferencesModel *)preferencesModel;

- (void)updatePreferencesModel:(QYPreferencesModel *)preferencesModel;

@end
