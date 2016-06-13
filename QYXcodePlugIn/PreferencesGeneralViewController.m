//
//  PreferencesGeneralViewController.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 16/6/13.
//  Copyright © 2016年 X.Y. All rights reserved.
//

#import "PreferencesGeneralViewController.h"
#import "QYShortcutRecorderController.h"

@interface PreferencesGeneralViewController ()

/**
 *  录制热键
 */
@property (nonatomic, retain) QYShortcutRecorderController *shortcutRC;

@property (weak) IBOutlet NSButton *magicCalalogSearch;

@property (weak) IBOutlet NSButton *isReminder;



@end

@implementation PreferencesGeneralViewController

- (void)dealloc { LOG(@"===PreferencesGeneralViewController===dealloc="); }

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
    
    
    self.magicCalalogSearch.state   = PreferencesModel.isClearCalalogSearchTitle?1:0;
    self.isReminder.state           = PreferencesModel.isPromptException?1:0;
}



- (IBAction)shortcutRecorderAction:(id)sender {
    
    if (!self.shortcutRC) {
        self.shortcutRC = [[QYShortcutRecorderController alloc] initWithWindowNibName:@"QYShortcutRecorderController"];
    }
    
    [self.view.window beginSheet:self.shortcutRC.window completionHandler:^(NSModalResponse returnCode) {
        
    }];
}

#pragma mark - PreferencesProtocol

- (IBAction)magicChange:(id)sender {
    PreferencesModel.isClearCalalogSearchTitle  = self.magicCalalogSearch.state == 1?YES:NO;
}

- (IBAction)reminderChange:(id)sender {
    PreferencesModel.isPromptException          = self.isReminder.state == 1?YES:NO;
}

#pragma mark - CCNPreferencesWindowControllerDelegate

- (NSString *)preferenceIdentifier { return @"GeneralPreferencesIdentifier"; }
- (NSString *)preferenceTitle { return @"通用"; }
- (NSImage *)preferenceIcon { return [NSImage imageNamed:NSImageNamePreferencesGeneral]; }




@end
