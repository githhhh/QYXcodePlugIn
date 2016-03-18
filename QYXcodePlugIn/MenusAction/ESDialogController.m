//
//  ESDialogController.m
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/26.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import "ESDialogController.h"

@interface ESDialogController ()<NSWindowDelegate,NSTextFieldDelegate>

@property (weak) IBOutlet NSTextField *msgLabel;
@property (weak) IBOutlet NSTextField *classNameField;


@property (weak) IBOutlet NSTextField *businessPrefixField;


@end

@implementation ESDialogController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.delegate = self;
    self.classNameField.delegate = self;
    self.businessPrefixField.delegate = self;
    
    self.msgLabel.stringValue = self.msg;
    self.classNameField.stringValue = self.className;
    self.businessPrefixField.stringValue = self.prefixName;
    
    [self.classNameField becomeFirstResponder];
}

- (void)setDataWithMsg:(NSString *)msg
      defaultClassName:(NSString *)className
        classNameBlock:(CallBackBlock)confirmClassNameBlock
           prefixBlock:(CallBackBlock)confirmPrefixBlock{
    
    self.msg = msg;
    self.className = className;
    self.confirmClassNameBlock = confirmClassNameBlock;
    self.confirmPrefixBlock = confirmPrefixBlock;
}


-(void)windowWillClose:(NSNotification *)notification{
    [NSApp stopModal];
    [NSApp endSheet:[self window]];
    [[self window] orderOut:nil];
}


#pragma mark - nstextfiled delegate

-(void)controlTextDidEndEditing:(NSNotification *)notification{
    if ( [[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement){
        [self enterBtnClick:nil];
    }
}

- (void)enterBtnClick:(NSButton *)sender {
    if (self.confirmClassNameBlock) {
        self.confirmClassNameBlock(self.classNameField.stringValue);
    }
    
    if (self.confirmPrefixBlock) {
        self.confirmPrefixBlock(self.businessPrefixField.stringValue);
    }
    
    [self close];
}
@end
