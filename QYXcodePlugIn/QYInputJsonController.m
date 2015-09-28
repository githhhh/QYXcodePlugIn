//
//  QYInputJsonController.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/24.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "QYInputJsonController.h"
#import "NSString+Extensions.h"
static NSString *StringClass = @"[NSString class]";

static NSString *NumberClass = @"[NSNumber class]";


@interface QYInputJsonController ()<NSTextViewDelegate,NSWindowDelegate>


@property (weak) IBOutlet NSScrollView *scrollView;
@property (unsafe_unretained) IBOutlet NSTextView *inputTextView;
@property (weak) IBOutlet NSButton *cancelBtn;
@property (weak) IBOutlet NSButton *confirmBtn;

@property (nonatomic,copy) NSString *currJsonStr;

@property (nonatomic,copy) NSString *testDataMethodStr;
@property (nonatomic,copy) NSString *validatorMethodStr;
@end

@implementation QYInputJsonController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.inputTextView.delegate = self;
    self.window.delegate = self;
}
-(void)dealloc{
    self.sourceTextView = nil;
    self.delegate = nil;
    NSLog(@"=====QYInputJsonController======dealloc===");
}




- (IBAction)cancelAction:(id)sender {
    [super close];
    if (self.delegate &&[self.delegate respondsToSelector:@selector(windowDidClose)]) {
        [self.delegate windowDidClose];
    }
}


- (IBAction)confirmAction:(id)sender {
    id resulte = [self dictionaryWithJsonStr:self.currJsonStr];
    if ([resulte isKindOfClass:[NSError class]]) {
        self.window.title = @"不符合Json 格式";
        [self.window setBackgroundColor:[NSColor redColor]];
        return;
    }
    self.window.title = @"执行中....";
    
    id data = nil;
    if ([resulte isKindOfClass:[NSDictionary class]]) {
        data = resulte[@"data"];
    }
    
    self.validatorMethodStr = [self getJsonString:data withValidator:YES];
    
    self.testDataMethodStr = [self getJsonString:resulte withValidator:NO];

    NSMutableString *validatorMStr = [NSMutableString stringWithCapacity:0];
    [validatorMStr appendString:@"\n- (id)validatorResult {\n"];
    [validatorMStr appendString:[NSString stringWithFormat:@"      return %@;\n}\n",self.validatorMethodStr]];
    self.validatorMethodStr = validatorMStr;
    
    NSMutableString *testDataMStr = [NSMutableString stringWithCapacity:0];
    [testDataMStr appendString:@"\n-(NSDictionary *)testData {\n"];
    [testDataMStr appendString:[NSString stringWithFormat:@"      return %@;\n}\n",self.testDataMethodStr]];
    self.testDataMethodStr = testDataMStr;
    
    
    
    NSMutableString *methodStr = [NSMutableString stringWithString:self.validatorMethodStr];
    [methodStr appendString:self.testDataMethodStr];
    [methodStr appendString:@"@end"];
    
    if (!self.sourceTextView) {
        return;
    }

    // 对str字符串进行匹配
    NSArray *endMatches =
    [self.sourceTextView.string matcheStrWith:@"@end"];
    
    if (!(endMatches && [endMatches count] >0)) {
        return;
    }
    NSInteger count = endMatches.count;
    NSTextCheckingResult *match = endMatches[count - 1];
    NSRange lastEndRange = [match range];
    
    //格式化
    
    
    NSString *source = [self clangFormatSourceCode:methodStr];
    
    
    [self.sourceTextView insertText:source replacementRange:lastEndRange];
    
    
    if (self.delegate &&[self.delegate respondsToSelector:@selector(windowDidClose)]) {
        [self.delegate windowDidClose];
    }
}



-(void)textDidChange:(NSNotification *)notification{
    NSTextView *textView = (NSTextView *)[notification object];
    self.currJsonStr = textView.textStorage.string;
}

#pragma mark - 格式化代码
-(NSString *)clangFormatSourceCode:(NSString *)sourceCode{
    if (!sourceCode) {
        return nil;
    }
    NSString *tempPath = [NSString stringWithFormat:@"%@.tm",self.sourcePath];
    
    BOOL isWrite = [sourceCode writeToFile:tempPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (!isWrite) {
        return nil;
    }
    
   NSString *path = [self launchClangFormatPath];
    
    //直接指定style
   NSString *newContent  = [self runCommand:[NSString stringWithFormat:@"%@ -style=\"{IndentWidth: 4,TabWidth: 4,UseTab: Never,BreakBeforeBraces: Stroustrup,ObjCBlockIndentWidth: 4,ObjCSpaceAfterProperty: true,ColumnLimit: 120,AlignTrailingComments: true,SpaceAfterCStyleCast: true}\"  %@",path,tempPath] ];
    [[NSFileManager defaultManager] removeItemAtPath:tempPath  error:nil];
    
   return newContent;
}



#pragma  mark -
#pragma  mark -  private Methode

/**
 *  检查是否是一个有效的JSON
 */
-(id)dictionaryWithJsonStr:(NSString *)jsonString{
    jsonString = [[jsonString stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id dicOrArray = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingMutableContainers
                                                      error:&err];
    if (err) {
        return err;
    }else{
        return dicOrArray;
    }
    
}

/**
 *  获取验证数据的字符串
 *
 *  @param object 需要验证的数据
 *
 *  @return 字符串
 */
- (NSString*)getJsonString:(id)object withValidator:(BOOL)validator
{
    if ([object isKindOfClass:[NSString class]])
    {
        return validator ? StringClass : [NSString stringWithFormat:@"@\"%@\"", object];
    }
    else if ([object isKindOfClass:[NSNumber class]])
    {
        return validator ? NumberClass : [NSString stringWithFormat:@"@(%@)", object];
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        return [self getArrayString:object withValidator:validator];
        
    }else if ([object isKindOfClass:[NSDictionary class]]) {
        
        return [self getDictionaryString:object withValidator:validator];
    }
    
    return nil;
}

/**
 *  获取数组类型的验证字符串
 *
 *  @param array 数组
 *
 *  @return 数组验证字符串
 */
- (NSString*)getArrayString:(NSArray*)array withValidator:(BOOL)validator
{
    NSMutableString *arrayStr = [[NSMutableString alloc] initWithString:@"@["];
    
    for (id obj in array) {
        
        NSString *resultStr = [self getJsonString:obj withValidator:validator];
        
        [arrayStr appendFormat:@"%@, ", resultStr];
        
        if (validator) {
            break;
        }
        
    }
    
    NSRange range = [arrayStr rangeOfString:@"," options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        [arrayStr deleteCharactersInRange:range];
    }
    [arrayStr appendString:@"]"];
    
    return arrayStr;
}

/**
 *  获取字典类型的验证字符串
 *
 *  @param item 字典
 *
 *  @return 字典验证字符串
 */
- (NSString*)getDictionaryString:(NSDictionary*)item withValidator:(BOOL)validator
{
    NSMutableString *dictStr = [[NSMutableString alloc] initWithString:@"@{"];
    
    for (NSString *key in [item allKeys]) {
        [dictStr appendFormat:@"@\"%@\" : ", key];
        id value = item[key];
        NSString *className = [self getJsonString:value withValidator:validator];
        [dictStr appendFormat:@"%@, ", className];
    }
    
    NSRange range = [dictStr rangeOfString:@"," options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        [dictStr deleteCharactersInRange:range];
    }
    [dictStr appendString:@"}"];
    
    return dictStr;
}

#pragma mark -
#pragma mark - NSTask shell

/**
 *  获取clang-format 启动路径
 *
 *  @return return value description
 */
-(NSString *)launchClangFormatPath{
    
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
- (NSString *)formatWithStyle:(NSString *)style
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
- (NSString *)runCommand:(NSString *)commandToRun
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
