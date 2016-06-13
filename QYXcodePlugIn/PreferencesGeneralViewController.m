//
//  PreferencesGeneralViewController.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 16/6/13.
//  Copyright © 2016年 X.Y. All rights reserved.
//

#import "PreferencesGeneralViewController.h"

@interface PreferencesGeneralViewController ()

@end

@implementation PreferencesGeneralViewController


- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleWithIdentifier:@"X.Y.QYXcodePlugIn"]];
    if (self) {
        
    }
    return self;
}

#pragma mark - CCNPreferencesWindowControllerDelegate

- (NSString *)preferenceIdentifier { return @"GeneralPreferencesIdentifier"; }
- (NSString *)preferenceTitle { return @"General"; }
- (NSImage *)preferenceIcon { return [NSImage imageNamed:NSImageNamePreferencesGeneral]; }






@end
