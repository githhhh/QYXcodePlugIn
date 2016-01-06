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
#import "QYIDENotificationHandler.h"

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




- (void)windowDidLoad
{
    [super windowDidLoad];
    self.window.delegate = self;

    dispatch_promise_on(dispatch_get_main_queue(),^(){
        QYSettingModel *setModel = [[QYIDENotificationHandler sharedHandler] settingModel];
        
        self.msgLable.hidden = NO;
        self.msgLable.textColor = [NSColor redColor];
        
        self.requestBaseName.stringValue = !IsEmpty(setModel.requestClassBaseName ) ?setModel.requestClassBaseName : @"QYRequest";
        
        self.isTestData.state = setModel.isCreatTestMethod?1:0;
        
        self.testDataMethodName.stringValue = !IsEmpty(setModel.testMethodName) ?setModel.testMethodName: @"testData";
        
        self.validatorMethodName.stringValue = !IsEmpty(setModel.requestValidatorMethodName)  ?setModel.requestValidatorMethodName: @"validatorResult";
        
        self.setingTextView.string = !IsEmpty(setModel.getterJSON) ? setModel.getterJSON : @"{\n\'UIView\':[\n   \'%@ = [[UIView alloc] init];\',\n   "
        @"\'%@.backgroundColor = [UIColor clearColor];\'\n  ]\n}\n";
    
    });
}
#pragma mark - 录制菜单热键。。

- (IBAction)shortcutRecorderAction:(id)sender
{
    if (!self.shortcutRC) {
      self.shortcutRC = [[QYShortcutRecorderController alloc] initWithWindowNibName:@"QYShortcutRecorderController"];
    }
   
    [self.window beginSheet:self.shortcutRC.window completionHandler:^(NSModalResponse returnCode) {
        
    }];
}

#pragma mark - 在线编辑 JSON

- (IBAction)onLineEdit:(id)sender
{
    NSURL *url = [[NSURL alloc] initWithString:@"http://www.qqe2.com/"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

#pragma mark - 保存/取消

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
    [self promiseValidatorJsonStr].thenOn(dispatch_get_main_queue(),^id (id resulte){
    
        if (IsEmpty(self.requestBaseName.stringValue))
            return   error(@"基类名不能为空", 0, nil);
        
        if (IsEmpty(self.validatorMethodName.stringValue))
            return  error(@"校验方法名不能为空", 0, nil);
        
        if (IsEmpty(self.testDataMethodName.stringValue) && self.isTestData.state == 1 )
            return error(@"测试数据方法名不能为空", 0, nil);
        
        isSave = YES;
        [self close];
        
        if (self.pgDelegate && [self.pgDelegate respondsToSelector:@selector(windowDidClose)])
            [self.pgDelegate windowDidClose];
        
        return nil;
    }).catchOn(dispatch_get_main_queue(),^(NSError *err){
        
        self.msgLable.stringValue = dominWithError(err);
    });
}

#pragma mark - windowClose Notifi

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
    setModel.isCreatTestMethod = self.isTestData.state == 1?YES:NO;
    setModel.testMethodName = self.testDataMethodName.stringValue;
    setModel.requestValidatorMethodName = self.validatorMethodName.stringValue;
    
    
    [[QYIDENotificationHandler sharedHandler] updateSettingModel:setModel];
}



/**
 *  检查是否是一个有效的JSON
 */
- (PMKPromise *)promiseValidatorJsonStr
{
    PMKPromise *validatorPromise =
    
    [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        
        NSString *jsonString  = self.setingTextView.string;
        if (IsEmpty(jsonString)) {
            reject(error(@"getter配置JSON为空,去试试在线编辑JSON工具？？？？", 10, nil));
        }else{
            
            jsonString = [[jsonString stringByReplacingOccurrencesOfString:@" " withString:@""]
                          stringByReplacingOccurrencesOfString:@" "
                          withString:@""];
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            id dicOrArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            if (!err){
                fulfill(dicOrArray);
            }else{
                reject(error(@"不符合Json 格式,去试试在线编辑JSON工具？？？？", 10, nil));
            }
        }
        
    }];
    
    return validatorPromise;
}
@end
