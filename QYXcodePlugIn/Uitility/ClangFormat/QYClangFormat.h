//
//  QYClangFormatCode.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/11/5.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Promise.h"

@interface QYClangFormat : NSObject

/**
 *  clang-formate  promise
 *
 *  @param sourceCode sourceCode description
 *
 *  @return return value description
 */
+(PMKPromise *)promiseClangFormatSourceCode:(NSString *)sourceCode;
/**
 *  直接执行shell  command
 *
 *  @param commandToRun commandToRun description
 *
 *  @return return value description
 */
+ (NSString *)runCommand:(NSString *)commandToRun;

@end
