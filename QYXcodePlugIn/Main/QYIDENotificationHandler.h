//
//  QYIDENotificationHandler.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/22.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "QYPreferencesModel.h"
#import <dlfcn.h>

@interface QYIDENotificationHandler : NSObject

+ (id)sharedHandler;

- (NSString *)clangFormateContentPath;

- (QYPreferencesModel *)preferencesModel;

- (void)updatePreferencesModel:(QYPreferencesModel *)setModel;
@end
