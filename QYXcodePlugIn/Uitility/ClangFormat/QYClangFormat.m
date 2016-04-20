//
//  QYClangFormatCode.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/11/5.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "QYClangFormat.h"
#import "MHXcodeDocumentNavigator.h"
#import "QYXcodePlugIn.h"
/**
 *  定义clang-form style
 *
 *  @param clang_fpath  clang-form 启动路径
 *  @param tempCodePath 要格式化的代码路径
 *
 */
#define defineClangFromatStyle(clang_fpath,tempCodePath) [NSString stringWithFormat:@"%@ -style=\"{BasedOnStyle: llvm,AlignTrailingComments: true,BreakBeforeBraces: Linux,ColumnLimit: 120,IndentWidth: 4,KeepEmptyLinesAtTheStartOfBlocks: false,MaxEmptyLinesToKeep: 2,ObjCSpaceAfterProperty: true,ObjCSpaceBeforeProtocolList: true,PointerBindsToType: false,SpacesBeforeTrailingComments: 1,TabWidth: 4,UseTab: Never,BinPackParameters: false}\"  %@ | /usr/local/bin/uncrustify  -q -c ~/.uncrustify.cfg -l OC",clang_fpath,tempCodePath]


static dispatch_queue_t clangFormateQueue;
static NSString *cfExecutablePath;

/**
 *  CFQueue
 *
 *  @return return value description
 */
dispatch_queue_t ClangFormateCreateQueue() {
    if (!clangFormateQueue) {
        clangFormateQueue = dispatch_queue_create("org.clangFormate.Q", DISPATCH_QUEUE_CONCURRENT);
    }
    return clangFormateQueue;
}

/**
 *  获取clang-format 启动路径
 *
 *  @return return value description
 */
NSString * launchClangFormatPath(){
    
    if (!cfExecutablePath) {
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
            cfExecutablePath = outputPath;
        }
    }
    return cfExecutablePath;
}



@implementation QYClangFormat


+(PMKPromise *)promiseClangFormatSourceCode:(NSString *)sourceCode{
    
    PMKPromise *clangFormatPromise =
    // promise 实现。。。。
    dispatch_promise_on(ClangFormateCreateQueue(), ^id() {
        if (!sourceCode || sourceCode.length == 0)
            return error(@"源代码为空。。", 0, nil);

        NSString *clangFpath    = launchClangFormatPath();
        if (!clangFpath||clangFpath.length == 0)
            return error(@"没有找到Clang-Formate", 100, nil);

        NSString *cfContentPath = [[[QYXcodePlugIn sharedPlugin] notificationHandler] clangFormateContentPath];
        if (!cfContentPath)
            return error(@"获取临时文件路径出错。。。", 0, nil);
        
        return  PMKManifold(sourceCode,clangFpath,cfContentPath);

    }).thenOn(ClangFormateCreateQueue(), ^id(NSString *sCode,NSString *cfPath,NSString *cfConentPath) {
        //判断文件是否存在
        if (![[NSFileManager defaultManager] fileExistsAtPath:cfPath])
            return error(@"clang-formate 启动文件不存在", 0, nil);
        
        NSError *error;
        BOOL isWrite         = [sCode writeToFile:cfConentPath atomically:YES
                                         encoding:NSUTF8StringEncoding error:&error];
        if (!isWrite)
            return error;

        //直接指定style
        NSString *newContent = [self runCommand:defineClangFromatStyle(cfPath, cfConentPath)];
        [[NSFileManager defaultManager] removeItemAtPath:cfConentPath error:&error];
        if (error)
            return error;
        
        return newContent;
        
    });

    return clangFormatPromise;
}




#pragma mark -
#pragma mark - NSTask shell
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
//    LOG(@"run command:%@", commandToRun);
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
