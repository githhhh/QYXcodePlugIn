//
//  AutoGetterAchieve.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/18.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Promise.h"
#import "Promise+When.h"
#import "NSString+Files.h"

static NSString *const propertyMatcheStr = @"@property\\s*\\(.+?\\)\\s*(\\w+?\\s*\\*{0,1})\\s*(\\w+)\\s*;{1}";


@interface QYAutoGetterAchieve : NSObject

-(void)getterAction;


+ (PMKPromise *)promiseInsertLoction;
@end
