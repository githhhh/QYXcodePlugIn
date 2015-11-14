//
//  QYClangFormatCode.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/11/5.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYClangFormat : NSObject

/**
 *  clang-formate  可以异步执行
 *
 *  @param sourceCode sourceCode description
 *
 *  @return return value description
 */
+(NSString *)clangFormatSourceCode:(NSString *)sourceCode andFilePath:(NSString *)filePath;
/**
 *  直接执行shell  command
 *
 *  @param commandToRun commandToRun description
 *
 *  @return return value description
 */
+ (NSString *)runCommand:(NSString *)commandToRun;
@end
