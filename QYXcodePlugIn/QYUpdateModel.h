//
//  QYUpdateModel.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 16/4/11.
//  Copyright © 2016年 X.Y. All rights reserved.
//

#import <Foundation/Foundation.h>
#define  IsCheckUpdate @"IsCheckUpdate"
@interface QYUpdateModel : NSObject

@property (nonatomic,copy)void(^confirmBlock)(void);

+ (NSString *)currentVersion;

- (void)updateVersion;

@end
