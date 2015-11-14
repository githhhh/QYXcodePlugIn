//
//  QYInputJsonController.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/24.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "QYInputJsonController.h"
#import "NSString+Extensions.h"
#import "QYClangFormat.h"
#import "MHXcodeDocumentNavigator.h"
#import "QYPluginSetingController.h"
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

@property (nonatomic,copy) NSString *currentFilePath;
@end

@implementation QYInputJsonController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.inputTextView.delegate = self;
    self.window.delegate = self;
    
    self.currentFilePath = [MHXcodeDocumentNavigator currentFilePath];

    
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
    if (!self.currJsonStr) {
        self.window.title = @"JSON 内容为空";
        [self.window setBackgroundColor:[NSColor redColor]];
        return;
    }
    id resulte = [self dictionaryWithJsonStr:self.currJsonStr];
 
    if ([resulte isKindOfClass:[NSError class]]) {
        self.window.title = @"不符合Json 格式";
        [self.window setBackgroundColor:[NSColor redColor]];
        return;
    }
    self.window.title = @"执行中....";
    

    __block NSMutableString *methodStr = nil;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       

        id data = nil;
        if ([resulte isKindOfClass:[NSDictionary class]]) {
            data = resulte[@"data"];
        }
        self.validatorMethodStr = [self getJsonString:data withValidator:YES];
        NSUserDefaults *userdf = [NSUserDefaults standardUserDefaults];
        NSString *vMethodName = [userdf objectForKey:validatorMName];
        
        
        NSMutableString *validatorMStr = [NSMutableString stringWithCapacity:0];
        [validatorMStr appendString:[NSString stringWithFormat:@"\n- (id)%@ {\n",vMethodName?:@"validatorResult"] ];
        [validatorMStr appendString:[NSString stringWithFormat:@"      return %@;\n}\n",self.validatorMethodStr]];
        self.validatorMethodStr = validatorMStr;
        methodStr = [NSMutableString stringWithString:self.validatorMethodStr];
        
        
        /**
         *  本地测试数据
         */
        NSString *isTd = [userdf objectForKey:isTD];
        if ([isTd boolValue]) {
            NSString *tdMdName = [userdf objectForKey:testdateMethodName];
            self.testDataMethodStr = [self getJsonString:resulte withValidator:NO];
            NSMutableString *testDataMStr = [NSMutableString stringWithCapacity:0];
            [testDataMStr appendString:[NSString stringWithFormat:@"\n#warning  本地测试数据，正式环境需要注释或删除\n\n-(id)%@ {\n",tdMdName?:@"testData"] ];
            [testDataMStr appendString:[NSString stringWithFormat:@"      return %@;\n}\n",self.testDataMethodStr]];
            self.testDataMethodStr = testDataMStr;
            [methodStr appendString:self.testDataMethodStr];
        }
        
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
        NSString *source = [QYClangFormat clangFormatSourceCode:methodStr andFilePath:self.currentFilePath];
        if (!source) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.sourceTextView insertText:source replacementRange:lastEndRange];
            if (self.delegate &&[self.delegate respondsToSelector:@selector(windowDidClose)]) {
                [self.delegate windowDidClose];
            }
        });
    });
}



-(void)textDidChange:(NSNotification *)notification{
    NSTextView *textView = (NSTextView *)[notification object];
    self.currJsonStr = textView.textStorage.string;
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


@end
