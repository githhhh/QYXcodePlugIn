//
//  QYPluginSetingController.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/11/6.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "QYPluginSetingController.h"
#import "QYShortcutRecorderController.h"



@interface QYPluginSetingController ()<NSWindowDelegate>{
    BOOL isSave;
}

@property (unsafe_unretained) IBOutlet NSTextView *setingTextView;

@property (weak) IBOutlet NSTextField *msgLable;
/**
 *  请求基类名
 */
@property (weak) IBOutlet NSTextField *requestBaseName;
/**
 *  是否生成测试数据
 */
@property (weak) IBOutlet NSButton *isTestData;
/**
 *  测试数据方法名
 */
@property (weak) IBOutlet NSTextField *testDataMethodName;
@property (weak) IBOutlet NSTextField *validatorMethodName;


@property (nonatomic,retain)QYShortcutRecorderController *shortcutRC;

@end

@implementation QYPluginSetingController

-(void)dealloc{
    NSLog(@"===QYPluginSetingController===dealloc=");
}

- (void)windowWillClose:(NSNotification *)notification {
    // whichever operations are needed when the
    // window is about to be closed
    
    if (!isSave) {
        return;
    }
    NSUserDefaults *userdf = [NSUserDefaults standardUserDefaults];
    [userdf setObject:self.setingTextView.string forKey:geterSetingKey];
    [userdf setObject:self.requestBaseName.stringValue forKey:rqBName];
    [userdf setObject:@(self.isTestData.state).stringValue forKey:isTD];
    [userdf setObject:self.testDataMethodName.stringValue forKey:testdateMethodName];
    [userdf setObject:self.validatorMethodName.stringValue forKey:validatorMName];
    
    [userdf synchronize];
    
}


- (void)windowDidLoad {
    [super windowDidLoad];
    self.window.delegate = self;
    self.msgLable.hidden = NO;
    self.msgLable.textColor = [NSColor redColor];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSUserDefaults *userdf = [NSUserDefaults standardUserDefaults];
        NSString *allContent = [userdf objectForKey:geterSetingKey];
        NSString *requstBName = [userdf objectForKey:rqBName];
        NSString *isTd = [userdf objectForKey:isTD];
        NSString *tdMdName = [userdf objectForKey:testdateMethodName];
        NSString *vMethodName = [userdf objectForKey:validatorMName];
        
        dispatch_async(dispatch_get_main_queue(), ^{
    
            self.requestBaseName.stringValue = requstBName?:@"QYRequest";
            self.isTestData.state = isTd?[isTd integerValue]:0;
            self.testDataMethodName.stringValue = tdMdName?:@"testData";
            self.validatorMethodName.stringValue = vMethodName?:@"validatorResult";
            
            self.setingTextView.string = allContent?:@"{\n\'UIView\':[\n   \'%@ = [[UIView alloc] init];\',\n   \'%@.backgroundColor = [UIColor clearColor];\'\n  ]\n}\n";
        });
    });
}

- (IBAction)shortcutRecorderAction:(id)sender {
    self.shortcutRC = [[QYShortcutRecorderController alloc] initWithWindowNibName:@"QYShortcutRecorderController"];
    [self.shortcutRC showWindow:self];
}


- (IBAction)onLineEdit:(id)sender {
    NSURL* url = [[ NSURL alloc ] initWithString :@"http://www.qqe2.com/"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}


- (IBAction)cancelAction:(id)sender {
    isSave = NO;
    [self close];
    if (self.pgDelegate &&[self.pgDelegate respondsToSelector:@selector(windowDidClose)]) {
        [self.pgDelegate windowDidClose];
    }
}


- (IBAction)saveAction:(id)sender {
    
    id resulte = [self dictionaryWithJsonStr:self.setingTextView.string];
    if ([resulte isKindOfClass:[NSError class]]) {
        self.msgLable.stringValue = @"不符合Json 格式";
        return;
    }
    
    
    if (self.requestBaseName.stringValue.length==0) {
        self.msgLable.stringValue = @"基类不能为空";
        return;
    }
    
    if (self.testDataMethodName.stringValue.length==0&&!self.isTestData.state) {
        self.msgLable.stringValue = @"测试数据方法名不能为空";
        return;
    }
    isSave = YES;
    [self close];
    if (self.pgDelegate &&[self.pgDelegate respondsToSelector:@selector(windowDidClose)]) {
        [self.pgDelegate windowDidClose];
    }
}


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
@end
