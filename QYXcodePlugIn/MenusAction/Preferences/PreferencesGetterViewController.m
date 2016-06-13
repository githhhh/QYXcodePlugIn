//
//  PreferencesGetterViewController.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 16/6/13.
//  Copyright © 2016年 X.Y. All rights reserved.
//

#import "PreferencesGetterViewController.h"
#import "Promise.h"

@interface PreferencesGetterViewController ()<NSTextViewDelegate>
@property (unsafe_unretained) IBOutlet NSTextView *getterPreTextView;
@property (weak) IBOutlet NSTextField *msgLable;

@end

@implementation PreferencesGetterViewController
- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:[QYXcodePlugIn sharedPlugin].bundle];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.view.layer.backgroundColor = [NSColor colorWithRed:236/255.0 green:236/255.0 blue:236/255.0 alpha:1].CGColor;
    [self.view setNeedsDisplay:YES];

    self.msgLable.hidden = YES;
    self.getterPreTextView.delegate = self;
    self.getterPreTextView.string           = !IsEmpty(PreferencesModel.getterJSON) ? PreferencesModel.getterJSON : @"{\n\"UIView\":[\n   \"%@ = [[UIView alloc] init];\",\n   \"%@.backgroundColor = [UIColor clearColor];\"\n  ]\n}\n";
}

-(void)viewDidDisappear{
    [super viewDidDisappear];
    [self collectChangeData];
}


- (IBAction)action:(id)sender {
    //写入剪贴板
    [[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil]; //必须声明,否则无从开始工作!
    [[NSPasteboard generalPasteboard] setString:self.getterPreTextView.string forType:NSStringPboardType]; //现在,就是把东西放进去了!
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://www.qqe2.com/"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}


/**
 *  检查是否是一个有效的JSON
 */
- (PMKPromise *)promiseValidatorJsonStr:(NSString *)textStr
{
   __block NSString *jsonString = textStr;
    PMKPromise *validatorPromise =
    
    [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        
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



#pragma mark - PreferencesProtocol

-(void)collectChangeData{
    
    PreferencesModel.getterJSON  = self.getterPreTextView.string;
}


#pragma mark - CCNPreferencesWindowControllerDelegate

- (NSString *)preferenceIdentifier { return @"GetterPreferencesIdentifier"; }
- (NSString *)preferenceTitle { return @"Getter"; }
- (NSImage *)preferenceIcon { return [NSImage imageNamed:NSImageNameNetwork]; }


#pragma mark - NSTextViewDelegate

-(void)textDidChange:(NSNotification *)notification{
    NSTextView *textView = notification.object;
    
    [self promiseValidatorJsonStr:textView.string].thenOn(dispatch_get_main_queue(),^(){
    
        self.msgLable.hidden = NO;
        self.msgLable.stringValue = @"good job!";
        self.msgLable.backgroundColor   = [NSColor clearColor];
        self.msgLable.textColor = [NSColor blackColor];
        
    }).catchOn(dispatch_get_main_queue(),^(NSError *err){
        self.msgLable.hidden = NO;
        self.msgLable.textColor              = [NSColor redColor];

        self.msgLable.stringValue = dominWithError(err);
    });
}

@end
