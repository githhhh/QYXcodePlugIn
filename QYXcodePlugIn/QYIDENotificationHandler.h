//
//  QYIDENotificationHandler.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/22.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYIDENotificationHandler : NSObject
+ (id)sharedHandler;

@property (nonatomic,retain)id globlaParamter;

@end
