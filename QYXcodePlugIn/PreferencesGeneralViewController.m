//
//  PreferencesGeneralViewController.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 16/6/13.
//  Copyright © 2016年 X.Y. All rights reserved.
//

#import "PreferencesGeneralViewController.h"
#import "QYShortcutRecorderController.h"
#import "QYUpdateModel.h"

@interface PreferencesGeneralViewController ()

/**
 *  录制热键
 */
@property (nonatomic, retain) QYShortcutRecorderController *shortcutRC;

@property (weak) IBOutlet NSButton *magicCalalogSearch;

@property (weak) IBOutlet NSButton *isReminder;

@property (nonatomic, retain) QYUpdateModel *updateModel;

@property (weak) IBOutlet NSTextField *versionLable;
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
 
    [self bindUI];
}

#pragma mark - Bind

-(void)bindUI{
    //绑定
    [self.magicCalalogSearch bind:@"value" toObject:PreferencesModel withKeyPath:@"isClearCalalogSearchTitle" options:nil];
    
    [self.isReminder bind:@"value" toObject:PreferencesModel withKeyPath:@"isPromptException" options:nil];
    
    self.versionLable.stringValue = [NSString stringWithFormat:@"当前版本:%@",[QYUpdateModel currentVersion]];
}

#pragma mark - Action
//去录制热键
- (IBAction)shortcutRecorderAction:(id)sender {
    
    if (!self.shortcutRC) {
        self.shortcutRC = [[QYShortcutRecorderController alloc] initWithWindowNibName:@"QYShortcutRecorderController"];
    }
    
    [self.view.window beginSheet:self.shortcutRC.window completionHandler:nil];
}

- (IBAction)checkUpdate:(id)sender {
    [self.updateModel updateVersion];
}

#pragma mark - CCNPreferencesWindowControllerDelegate

- (NSString *)preferenceIdentifier { return @"GeneralPreferencesIdentifier"; }
- (NSString *)preferenceTitle { return @"通用"; }
- (NSImage *)preferenceIcon { return [NSImage imageNamed:NSImageNamePreferencesGeneral]; }


#pragma mark -  AutoGetter

- (QYUpdateModel *)updateModel {
    if (!_updateModel) {
        _updateModel = [[QYUpdateModel alloc] init];
    }
    
    return _updateModel;
}

@end
