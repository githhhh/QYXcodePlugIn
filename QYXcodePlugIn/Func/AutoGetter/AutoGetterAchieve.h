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

@interface AutoGetterAchieve : NSObject

-(void)createGetterAction;

+ (NSArray *)MatcheSelectText:(NSString *)sourceStr;

+ (PMKPromise *)promiseInsertLoction;
@end
