//
//  PreferencesNetworkViewController.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 16/6/13.
//  Copyright © 2016年 X.Y. All rights reserved.
//

#import "PreferencesNetworkViewController.h"

@interface PreferencesNetworkViewController ()

@end

@implementation PreferencesNetworkViewController

- (instancetype)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleWithIdentifier:@"X.Y.QYXcodePlugIn"]];
    if (self) {
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}



#pragma mark - CCNPreferencesWindowControllerDelegate

- (NSString *)preferenceIdentifier { return @"NetworkPreferencesIdentifier"; }
- (NSString *)preferenceTitle { return @"Network"; }
- (NSImage *)preferenceIcon { return [NSImage imageNamed:NSImageNameNetwork]; }


@end
