//
//  PreferencesFormateCodeViewController.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 16/6/13.
//  Copyright © 2016年 X.Y. All rights reserved.
//

#import "PreferencesFormateCodeViewController.h"

@interface PreferencesFormateCodeViewController ()

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
}


#pragma mark - CCNPreferencesWindowControllerDelegate

- (NSString *)preferenceIdentifier { return @"PreferencesFormateCodeViewController"; }
- (NSString *)preferenceTitle { return @"格式化"; }
- (NSImage *)preferenceIcon { return [NSImage imageNamed:NSImageNameNetwork]; }



@end
