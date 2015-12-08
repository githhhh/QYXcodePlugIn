//
//  QYClangFormatCode.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/11/5.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "QYClangFormat.h"
#import "MHXcodeDocumentNavigator.h"
#import "QYIDENotificationHandler.h"

/**
 *  定义clang-form style
 *
 *  @param clang_fpath  clang-form 启动路径
 *  @param tempCodePath 要格式化的代码路径
 *
 *
 */
#define defineClangFromatStyle(clang_fpath,tempCodePath) [NSString stringWithFormat:@"%@ -style=\"{BasedOnStyle: llvm,AlignTrailingComments: true,BreakBeforeBraces: Linux,ColumnLimit: 120,IndentWidth: 4,KeepEmptyLinesAtTheStartOfBlocks: false,MaxEmptyLinesToKeep: 2,ObjCSpaceAfterProperty: true,ObjCSpaceBeforeProtocolList: true,PointerBindsToType: false,SpacesBeforeTrailingComments: 1,TabWidth: 4,UseTab: Never,BinPackParameters: false}\"  %@",clang_fpath,tempCodePath]



@implementation QYClangFormat

+(NSString *)clangFormatSourceCode:(NSString *)sourceCode{
    if (!sourceCode||sourceCode.length==0) {
        return nil;
    }
    NSString *filePath = [[QYIDENotificationHandler  sharedHandler] projectTempFilePath];
    if (!filePath) {
        return nil;
    }
    __block NSString *newContent = nil;

    NSString *tempPath = [NSString stringWithFormat:@"%@.tm",filePath];
    BOOL isWrite = [sourceCode writeToFile:tempPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (!isWrite) {
        newContent = nil;
    }else{
        NSString *clangFpath = [self launchClangFormatPath];
        //直接指定style
        newContent  = [self runCommand:defineClangFromatStyle(clangFpath, tempPath) ];
        [[NSFileManager defaultManager] removeItemAtPath:tempPath  error:nil];
    }
    
    return newContent;
}



#pragma mark -
#pragma mark - NSTask shell

/**
 *  获取clang-format 启动路径
 *
 *  @return return value description
 */
+ (NSString *)launchClangFormatPath{
    
    NSString *executablePath = nil;
    
    NSDictionary *environmentDict = [[NSProcessInfo processInfo] environment];
    NSString *shellString =
    [environmentDict objectForKey:@"SHELL"] ?: @"/bin/bash";
    
    NSPipe *outputPipe = [NSPipe pipe];
    NSPipe *errorPipe = [NSPipe pipe];
    
    NSTask *task = [[NSTask alloc] init];
    task.standardOutput = outputPipe;
    task.standardError = errorPipe;
    task.launchPath = shellString;
    task.arguments = @[ @"-l", @"-c", @"which clang-format" ];
    
    [task launch];
    [task waitUntilExit];
    [errorPipe.fileHandleForReading readDataToEndOfFile];
    NSData *outputData = [outputPipe.fileHandleForReading readDataToEndOfFile];
    NSString *outputPath = [[NSString alloc] initWithData:outputData
                                                 encoding:NSUTF8StringEncoding];
    outputPath = [outputPath
                  stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    BOOL isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath isDirectory:&isDirectory] && !isDirectory) {
        executablePath = outputPath;
    }
    return executablePath;
}



/**
 *  格式化
 *
 *  @param style      style description
 *  @param launchPath launchPath description
 *  @param tmpFileURL tmpFileURL description
 *
 *  @return return value description
 */
+ (NSString *)formatWithStyle:(NSString *)style
 usingClangFormatAtLaunchPath:(NSString *)launchPath
                     filePath:(NSString *)tmpFileURL{
    //判断文件是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:tmpFileURL]) {
        return nil;
    }
    
    NSPipe *outputPipe = [NSPipe pipe];
    NSPipe *errorPipe = [NSPipe pipe];
    
    NSTask *task = [[NSTask alloc] init];
    task.standardOutput = outputPipe;
    task.standardError = errorPipe;
    task.launchPath = launchPath;
    task.arguments = @[
                       [NSString stringWithFormat:@"--style=%@", style],
                       @"-i",
                       tmpFileURL
                       ];
    
    [outputPipe.fileHandleForReading readToEndOfFileInBackgroundAndNotify];
    
    [task launch];
    [task waitUntilExit];
    
    NSData *errorData = [errorPipe.fileHandleForReading readDataToEndOfFile];
    
    if ([errorData length]>0) {
        return nil;
    }
    
    NSString *newContent =
    [NSString stringWithContentsOfFile:tmpFileURL encoding:NSUTF8StringEncoding error:NULL];
    
    [[NSFileManager defaultManager] removeItemAtPath:tmpFileURL  error:nil];
    
    return newContent;
}


/**
 *  直接执行shell  command
 *
 *  @param commandToRun commandToRun description
 *
 *  @return return value description
 */
+ (NSString *)runCommand:(NSString *)commandToRun
{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    NSLog(@"run command:%@", commandToRun);
    [task setArguments:arguments];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return output;
}






@end
