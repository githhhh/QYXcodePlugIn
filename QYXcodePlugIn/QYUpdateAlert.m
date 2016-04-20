//
//  QYUpdateAlert.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 16/4/19.
//  Copyright © 2016年 X.Y. All rights reserved.
//

#import "QYUpdateAlert.h"
#define alertBtnBaseTag 10
@interface QYUpdateAlert ()




@end

@implementation QYUpdateAlert

-(void)dealloc{
    
    LOG(@"==QYUpdateAlert====dealloc==");

}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.alertTitle.stringValue = IsEmpty(self.title)?@"":self.title;
    self.alertMessage.editable = false;
    self.alertMessage.string = IsEmpty(self.msg)?@"":self.msg;
    self.alertMessage.backgroundColor = self.window.backgroundColor;

    
    if (IsEmpty(self.cancelTitle)) {
        self.cancelBtn.hidden = true;
    }else{
        [self.cancelBtn setTitle:self.cancelTitle];
        self.cancelBtn.hidden = false;
    }
    
    if (IsEmpty(self.confirmTitle)) {
        self.confirmBtn.hidden = true;
    }else{
        [self.confirmBtn setTitle:self.confirmTitle];
        self.confirmBtn.hidden = false;
        self.confirmBtn.state = 1;
    }
    
    self.confirmBtn.tag = alertBtnBaseTag ;
    self.cancelBtn.tag = alertBtnBaseTag + 1;
    
    [[self window] setLevel: kCGStatusWindowLevel];
}


- (IBAction)cancel:(NSButton *)sender {
    if (self.confirmBlock) {
        self.confirmBlock(sender.tag - alertBtnBaseTag);
    }
}


- (IBAction)confirm:(NSButton *)sender {
    if (self.confirmBlock) {
        self.confirmBlock(sender.tag - alertBtnBaseTag);
    }
}


@end
