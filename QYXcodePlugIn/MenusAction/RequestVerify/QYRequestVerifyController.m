//
//  QYInputJsonController.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/24.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "MHXcodeDocumentNavigator.h"
#import "NSString+Extensions.h"
#import "QYClangFormat.h"
#import "QYIDENotificationHandler.h"
#import "QYRequestVerifyController.h"
#import "QYPreferencesController.h"

static NSString *StringClass = @"[NSString class]";
static NSString *NumberClass = @"[NSNumber class]";


@interface QYRequestVerifyController () <NSTextViewDelegate, NSWindowDelegate>


@property (weak) IBOutlet NSScrollView *scrollView;
@property (unsafe_unretained) IBOutlet NSTextView *inputTextView;
@property (weak) IBOutlet NSButton *cancelBtn;
@property (weak) IBOutlet NSButton *confirmBtn;

//
@property (nonatomic, copy) NSString *currJsonStr;
@property (nonatomic, copy) NSString *testDataMethodStr;
@property (nonatomic, copy) NSString *validatorMethodStr;
@property (nonatomic, copy) NSString *currentFilePath;

@end

@implementation QYRequestVerifyController

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its
    // nib file.
    
    self.inputTextView.delegate = self;
    self.window.delegate = self;
}
- (void)dealloc
{
    self.sourceTextView = nil;
    self.delegate = nil;
    NSLog(@"=====QYInputJsonController======dealloc===");
}

#pragma mark - Action Method

- (IBAction)cancelAction:(id)sender
{
    [super close];
    [self closeWindown];
}


- (IBAction)confirmAction:(id)sender
{
    [self.window setBackgroundColor:[NSColor whiteColor]];

    dispatch_promise_on(dispatch_get_global_queue(0, 0),^id(){
        
        if (IsEmpty(self.currJsonStr))
            return error(@"JSON内容为空。。", 0, nil);
        //验证JSON
        id resulte =  [self dictionaryWithJsonStr:self.currJsonStr];
        if (!resulte||[resulte isKindOfClass:[NSError class]])
            return  error(@"JSON格式错误。。", 0, nil);
        //格式化
        NSString *methodStr = [self getMethodStrWithJson:resulte];
        return [QYClangFormat promiseClangFormatSourceCode:methodStr];
        
    }).thenOn(dispatch_get_main_queue(),^(NSString *source){
        
        NSRange lastEndRange = [self.insertRangeValue rangeValue];
        [self.sourceTextView insertText:source replacementRange:lastEndRange];
        [self closeWindown];
        
    }).catchOn(dispatch_get_main_queue(),^(NSError *err){
        
        NSString *errStr = dominWithError(err);
        self.window.title = errStr;
        [self.window setBackgroundColor:[NSColor redColor]];
        
    });
}



#pragma mark -  private Methode

-(void)closeWindown{
    if (self.delegate && [self.delegate respondsToSelector:@selector(windowDidClose)]) {
        [self.delegate windowDidClose];
    }
}

- (void)textDidChange:(NSNotification *)notification
{
    NSTextView *textView = (NSTextView *)[notification object];
    self.currJsonStr = textView.textStorage.string;
}


- (NSString *)getMethodStrWithJson:(id)resulte
{
    id data = nil;
    if ([resulte isKindOfClass:[NSDictionary class]]) {
        data = resulte[@"data"];
    }
    NSMutableString *methodStr = [NSMutableString stringWithCapacity:0];
    self.validatorMethodStr = [self getValidatorMethodStrWithJsonData:data];
    
    methodStr = [NSMutableString stringWithString:self.validatorMethodStr];
    
    self.testDataMethodStr = [self getLocTestDataMethodStrWithJsonData:resulte];
    if (self.testDataMethodStr) {
        [methodStr appendString:self.testDataMethodStr];
    }
    if (methodStr.length != 0) {
        [methodStr appendString:@"@end"];
    }
    return [NSString stringWithString:methodStr];
}

#pragma mark - 获取验证方法字符串

- (NSString *)getValidatorMethodStrWithJsonData:(id)data
{
    NSString *validatorStr = [self getJsonString:data withValidator:YES];
    NSString *vMethodName = PreferencesModel.requestValidatorMethodName;
    
    NSMutableString *validatorMStr = [NSMutableString stringWithCapacity:0];
    [validatorMStr appendString:[NSString stringWithFormat:@"\n- (id)%@ {\n", vMethodName ?: @"validatorResult"]];
    [validatorMStr appendString:[NSString stringWithFormat:@"      return %@;\n}\n", validatorStr]];
    return [NSString stringWithString:validatorMStr];
}

#pragma mark - 获取本地测试方法字符串

- (NSString *)getLocTestDataMethodStrWithJsonData:(id)data
{
    /**
     *  本地测试数据
     */
    if (!PreferencesModel.isCreatTestMethod) {
        return nil;
    }
    NSString *tdMdName = PreferencesModel.testMethodName;
    NSString *testDataStr = [self getJsonString:data withValidator:NO];
    NSMutableString *testDataMethodStr = [NSMutableString stringWithCapacity:0];
    [testDataMethodStr
     appendString:[NSString stringWithFormat:@"\n#warning  本地测试数据，正式环境需要注释或删除\n\n-(id)%@ {\n",
                   tdMdName ?: @"testData"]];
    [testDataMethodStr appendString:[NSString stringWithFormat:@"      return %@;\n}\n", testDataStr]];
    return testDataMethodStr;
}


/**
 *  检查是否是一个有效的JSON
 */
- (id)dictionaryWithJsonStr:(NSString *)jsonString
{
    jsonString = [[jsonString stringByReplacingOccurrencesOfString:@" " withString:@""]
                  stringByReplacingOccurrencesOfString:@" "
                  withString:@""];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id dicOrArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        return err;
    } else {
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
- (NSString *)getJsonString:(id)object withValidator:(BOOL)validator
{
    if ([object isKindOfClass:[NSString class]]) {
        return validator ? StringClass : [NSString stringWithFormat:@"@\"%@\"", object];
    } else if ([object isKindOfClass:[NSNumber class]]) {
        return validator ? NumberClass : [NSString stringWithFormat:@"@(%@)", object];
    } else if ([object isKindOfClass:[NSArray class]]) {
        return [self getArrayString:object withValidator:validator];
        
    } else if ([object isKindOfClass:[NSDictionary class]]) {
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
- (NSString *)getArrayString:(NSArray *)array withValidator:(BOOL)validator
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
- (NSString *)getDictionaryString:(NSDictionary *)item withValidator:(BOOL)validator
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

@end
