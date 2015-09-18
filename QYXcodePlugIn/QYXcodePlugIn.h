//
//  QYXcodePlugIn.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/18.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//

#import <AppKit/AppKit.h>

@class QYXcodePlugIn;

static QYXcodePlugIn *sharedPlugin;

@interface QYXcodePlugIn : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end