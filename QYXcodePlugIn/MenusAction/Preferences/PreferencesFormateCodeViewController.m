//
//  PreferencesFormateCodeViewController.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 16/6/13.
//  Copyright © 2016年 X.Y. All rights reserved.
//

#import "PreferencesFormateCodeViewController.h"
#import "QYClangFormat.h"

@interface PreferencesFormateCodeViewController ()<NSTextViewDelegate>
@property (unsafe_unretained) IBOutlet NSTextView *sourceCode;
@property (unsafe_unretained) IBOutlet NSTextView *niceCode;
@end

@implementation PreferencesFormateCodeViewController
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

    
    self.sourceCode.delegate = self;
    self.sourceCode.backgroundColor = [NSColor blackColor];
    self.sourceCode.textColor = [NSColor whiteColor];
    self.sourceCode.insertionPointColor = [NSColor whiteColor];
    [self.sourceCode becomeFirstResponder];

    self.niceCode.editable = NO;
    self.niceCode.backgroundColor = [NSColor blackColor];
    self.niceCode.textColor = [NSColor whiteColor];
}

#pragma mark - NSTextViewDelegate

-(void)textDidChange:(NSNotification *)notification{
    NSTextView *textView = notification.object;

    if (IsEmpty(textView.string)) {
        self.niceCode.string = @"";
        return;
    }
    
    [QYClangFormat promiseClangFormatSourceCode:textView.string].thenOn(dispatch_get_main_queue(),^(NSString *niceCodeStr){
    
//        self.niceCode.attributedString = self.sourceCode.attributedString;
        
        
        self.niceCode.string = niceCodeStr;

    }).catchOn(dispatch_get_main_queue(),^(NSError *erro){
        
    });
}

#pragma mark - CCNPreferencesWindowControllerDelegate

- (NSString *)preferenceIdentifier { return @"PreferencesFormateCodeViewController"; }
- (NSString *)preferenceTitle { return @"格式化"; }
- (NSImage *)preferenceIcon {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"X.Y.QYXcodePlugIn"];
    
    NSImage *bangImg = [bundle imageForResource:@"formate-code-icon.png"];
    
    return bangImg;
}

@end
