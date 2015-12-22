//
//  QYPluginSetingController.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/11/6.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "QYPluginSetingController.h"
#import "QYShortcutRecorderController.h"
#import "QYSettingModel.h"
#import "Promise.h"

@interface QYPluginSetingController () <NSWindowDelegate> {
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
/**
 *  请求验证名
 */
@property (weak) IBOutlet NSTextField *validatorMethodName;

/**
 *  录制热键
 */
@property (nonatomic, retain) QYShortcutRecorderController *shortcutRC;

@end

@implementation QYPluginSetingController

- (void)dealloc { NSLog(@"===QYPluginSetingController===dealloc="); }

- (void)windowWillClose:(NSNotification *)notification
{
    // whichever operations are needed when the
    // window is about to be closed
    
    if (!isSave) {
        return;
    }
    
    QYSettingModel *setModel = [[QYSettingModel alloc] init];
    setModel.getterJSON = self.setingTextView.string;
    setModel.requestClassBaseName = self.requestBaseName.stringValue;
    setModel.isCreatTestMethod = self.isTestData.state;
    setModel.testMethodName = self.testDataMethodName.stringValue;
    setModel.requestValidatorMethodName = self.validatorMethodName.stringValue;
    
    NSData *customData = [NSKeyedArchiver archivedDataWithRootObject:setModel] ;
    NSUserDefaults *userdf = [NSUserDefaults standardUserDefaults];
    [userdf setObject:customData forKey:@"settingModel"];
    [userdf synchronize];
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    dispatch_promise_on(dispatch_get_global_queue(0, 0), ^id(){
    
        return [[QYIDENotificationHandler sharedHandler] settingModel];
        
    }).thenOn(dispatch_get_main_queue(),^(QYSettingModel *setModel){
        
        self.window.delegate = self;
        self.msgLable.hidden = NO;
        self.msgLable.textColor = [NSColor redColor];
        
        self.requestBaseName.stringValue = setModel.requestClassBaseName ?: @"QYRequest";
        
        self.isTestData.state = setModel.isCreatTestMethod ;
        
        self.testDataMethodName.stringValue = setModel.testMethodName ?: @"testData";
        
        self.validatorMethodName.stringValue = setModel.requestValidatorMethodName ?: @"validatorResult";
        
        self.setingTextView.string = setModel.getterJSON ?: @"{\n\'UIView\':[\n   \'%@ = [[UIView alloc] init];\',\n   "
        @"\'%@.backgroundColor = [UIColor clearColor];\'\n  ]\n}\n";

    
    });
}

- (IBAction)shortcutRecorderAction:(id)sender
{
    if (!self.shortcutRC) {
      self.shortcutRC = [[QYShortcutRecorderController alloc] initWithWindowNibName:@"QYShortcutRecorderController"];
    }
   
    [self.window beginSheet:self.shortcutRC.window completionHandler:^(NSModalResponse returnCode) {
        
    }];
}


- (IBAction)onLineEdit:(id)sender
{
    NSURL *url = [[NSURL alloc] initWithString:@"http://www.qqe2.com/"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}


- (IBAction)cancelAction:(id)sender
{
    isSave = NO;
    [self close];
    if (self.pgDelegate && [self.pgDelegate respondsToSelector:@selector(windowDidClose)]) {
        [self.pgDelegate windowDidClose];
    }
}


- (IBAction)saveAction:(id)sender
{
    [self promiseValidatorJsonStr].then(^(id resulte){
    
        if (self.requestBaseName.stringValue.length == 0)
            @throw  error(@"基类不能为空", 0, nil);
        
        if (self.testDataMethodName.stringValue.length == 0 && !self.isTestData.state)
            @throw error(@"测试数据方法名不能为空", 0, nil);
        
        isSave = YES;
        
        [self close];
        
        if (self.pgDelegate && [self.pgDelegate respondsToSelector:@selector(windowDidClose)])
            [self.pgDelegate windowDidClose];
        
    }).catch(^(NSError *err){
        self.msgLable.stringValue = err.domain;
    });
}


/**
 *  检查是否是一个有效的JSON
 */
- (PMKPromise *)promiseValidatorJsonStr
{
    PMKPromise *validatorPromise =
    
    [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        
        NSString *jsonString  = self.setingTextView.string;
        jsonString = [[jsonString stringByReplacingOccurrencesOfString:@" " withString:@""]
                      stringByReplacingOccurrencesOfString:@" "
                      withString:@""];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        id dicOrArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        if (!err){
            fulfill(dicOrArray);
        }else{
            reject(error(@"不符合Json 格式", 0, nil));
        }
    }];
    
    return validatorPromise;
}
@end
