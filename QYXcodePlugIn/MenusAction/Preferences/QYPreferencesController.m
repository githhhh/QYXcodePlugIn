//
//  QYPluginSetingController.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/11/6.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "QYPreferencesController.h"
#import "QYShortcutRecorderController.h"
#import "QYPreferencesModel.h"
#import "Promise.h"
#import "QYIDENotificationHandler.h"

@interface QYPreferencesController () <NSWindowDelegate> {
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
/**
 *  清除CalalogSearch
 */
@property (weak) IBOutlet NSButton *clearCalalogSearch;
/**
 *  提醒异常
 */
@property (weak) IBOutlet NSButton *isReminder;

#pragma mark - AutoModel

/**
 *  是否忽略大小写
 */
@property (weak) IBOutlet NSButton *propertyIsOptionalButton;
/**
 *  业务前缀
 */
@property (weak) IBOutlet NSButton *businessPrefixButton;

@property (weak) IBOutlet NSButton *defaultAllJSONBtn;

@property (weak) IBOutlet NSButton *conentJSONKeyBtn;

@property (weak) IBOutlet NSTextField *contentJSONKeyTextFiled;

@end

@implementation QYPreferencesController

- (void)dealloc { LOG(@"===QYPluginSetingController===dealloc="); }


- (void)windowDidLoad
{
    [super windowDidLoad];
    self.window.delegate = self;
    /**
     *  将window置顶
     */
    [[self window] setLevel: kCGStatusWindowLevel];
    
    dispatch_promise_on(dispatch_get_main_queue(),^(){
        

        self.msgLable.hidden                 = NO;
        self.msgLable.textColor              = [NSColor redColor];

        self.requestBaseName.stringValue     = !IsEmpty(PreferencesModel.requestClassBaseName ) ?PreferencesModel.requestClassBaseName : @"QYRequest";

        self.isTestData.state                = PreferencesModel.isCreatTestMethod?1:0;

        self.testDataMethodName.enabled = PreferencesModel.isCreatTestMethod;
        
        
        self.clearCalalogSearch.state        = PreferencesModel.isClearCalalogSearchTitle?1:0;
        self.isReminder.state                = PreferencesModel.isPromptException?1:0;

        self.testDataMethodName.stringValue  = !IsEmpty(PreferencesModel.testMethodName) ?PreferencesModel.testMethodName: @"testData";

        self.validatorMethodName.stringValue = !IsEmpty(PreferencesModel.requestValidatorMethodName)  ?PreferencesModel.requestValidatorMethodName: @"validatorResult";

        self.setingTextView.string           = !IsEmpty(PreferencesModel.getterJSON) ? PreferencesModel.getterJSON : @"{\n\"UIView\":[\n   \"%@ = [[UIView alloc] init];\",\n   \"%@.backgroundColor = [UIColor clearColor];\"\n  ]\n}\n";
        /**
         *  这里因为默认启用,所以这么设置
         */
        self.propertyIsOptionalButton.state = PreferencesModel.isPropertyIsOptional?0:1;
        self.businessPrefixButton.state = PreferencesModel.propertyBusinessPrefixEnable?0:1;

        self.defaultAllJSONBtn.state = PreferencesModel.isDefaultAllJSON?0:1;
        self.conentJSONKeyBtn.state = PreferencesModel.isDefaultAllJSON?1:0;
        self.contentJSONKeyTextFiled.enabled = PreferencesModel.isDefaultAllJSON?YES:NO;
        self.contentJSONKeyTextFiled.stringValue = IsEmpty(PreferencesModel.contentJSONKey)?@"":PreferencesModel.contentJSONKey;
        
    });
}



- (IBAction)changeSelecteState:(id)sender {
    
//    LOG(@"=isTestData=is=%@=======",self.isTestData.state == 1?@"YES":@"NO");
    self.testDataMethodName.enabled = (self.isTestData.state == 1);
}

#pragma mark - 是否配置AutoModel解析指定特定key 的JSON内容

- (IBAction)defaultAllJSONBtnChangeState:(id)sender {
    
    self.conentJSONKeyBtn.state = (self.defaultAllJSONBtn.state == 1)?0:1;
    self.contentJSONKeyTextFiled.enabled = (self.defaultAllJSONBtn.state == 1)?NO:YES;
}

- (IBAction)contentJSONBtnChangeState:(id)sender {
    
    self.defaultAllJSONBtn.state = (self.conentJSONKeyBtn.state == 1)?0:1;
    self.contentJSONKeyTextFiled.enabled = (self.conentJSONKeyBtn.state == 1)?YES:NO;
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
    //写入剪贴板
    [[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil]; //必须声明,否则无从开始工作!
    [[NSPasteboard generalPasteboard] setString:self.setingTextView.string forType:NSStringPboardType]; //现在,就是把东西放进去了!
    
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
        
        if ((self.defaultAllJSONBtn.state == 0) && IsEmpty(self.contentJSONKeyTextFiled.stringValue))
            return error(@"AutoModel必须要指定JSON key 哦。。", 0, nil);
        
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
    
    QYPreferencesModel *newPreferencesModel        = [[QYPreferencesModel alloc] init];
    newPreferencesModel.getterJSON                 = self.setingTextView.string;
    newPreferencesModel.requestClassBaseName       = self.requestBaseName.stringValue;
    newPreferencesModel.isCreatTestMethod          = self.isTestData.state == 1?YES:NO;
    newPreferencesModel.isClearCalalogSearchTitle  = self.clearCalalogSearch.state == 1?YES:NO;
    newPreferencesModel.testMethodName             = self.testDataMethodName.stringValue;
    newPreferencesModel.requestValidatorMethodName = self.validatorMethodName.stringValue;
    newPreferencesModel.isPromptException          = self.isReminder.state == 1?YES:NO;
    
    /**
     *  这里因为默认为启用,所以这么设置
     */
    newPreferencesModel.isPropertyIsOptional       = self.propertyIsOptionalButton.state == 1?NO:YES;
    newPreferencesModel.propertyBusinessPrefixEnable = self.businessPrefixButton.state == 1?NO:YES;
    newPreferencesModel.isDefaultAllJSON = self.defaultAllJSONBtn.state == 1?NO:YES;
    newPreferencesModel.contentJSONKey = self.contentJSONKeyTextFiled.stringValue;
    [[[QYXcodePlugIn sharedPlugin] notificationHandler] updatePreferencesModel:newPreferencesModel];
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
            
            jsonString       = [[jsonString stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            id dicOrArray    = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
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
