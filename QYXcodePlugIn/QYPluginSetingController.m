//
//  QYPluginSetingController.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/11/6.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "QYPluginSetingController.h"

@interface QYPluginSetingController ()<NSTextViewDelegate,NSWindowDelegate>

@property (weak) IBOutlet NSButton *cancelBtn;
@property (weak) IBOutlet NSButton *saveBtn;
@property (unsafe_unretained) IBOutlet NSTextView *setingTextView;

@property (weak) IBOutlet NSTextField *msgLable;

@end

@implementation QYPluginSetingController

-(void)dealloc{
    
    NSLog(@"===QYPluginSetingController===dealloc=");
    
}


- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.setingTextView.delegate = self;

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSUserDefaults *userdf = [NSUserDefaults standardUserDefaults];
        NSString *allContent = [userdf objectForKey:geterSetingKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!allContent) {
                self.setingTextView.string = @"{\n\'UIView\':[\n   \'%@ = [[UIView alloc] init];\',\n   \'%@.backgroundColor = [UIColor clearColor];\'\n  ]\n}\n";
            }else{
                self.setingTextView.string = allContent;
            }
        });
    });
}

- (IBAction)onLineEdit:(id)sender {
    NSURL* url = [[ NSURL alloc ] initWithString :@"http://www.qqe2.com/"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)cancelAction:(id)sender {
    [super close];
    if (self.delegate &&[self.delegate respondsToSelector:@selector(windowDidClose)]) {
        [self.delegate windowDidClose];
    }
}


- (IBAction)saveAction:(id)sender {
    self.msgLable.stringValue = @"";
    self.msgLable.textColor = [NSColor clearColor];
    //验证。。。
    id resulte = [self dictionaryWithJsonStr:self.setingTextView.string];
    if ([resulte isKindOfClass:[NSError class]]) {
        self.msgLable.stringValue = @"不符合Json 格式";
        self.msgLable.textColor = [NSColor redColor];
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSUserDefaults *userdf = [NSUserDefaults standardUserDefaults];
        [userdf setObject:self.setingTextView.string forKey:geterSetingKey];
        [userdf synchronize];
        dispatch_async(dispatch_get_main_queue(), ^{
            [super close];
            if (self.delegate &&[self.delegate respondsToSelector:@selector(windowDidClose)]) {
                [self.delegate windowDidClose];
            }
        });
    });
}




-(void)textDidChange:(NSNotification *)notification{
    
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
