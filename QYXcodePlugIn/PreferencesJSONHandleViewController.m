//
//  PreferencesNetworkViewController.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 16/6/13.
//  Copyright © 2016年 X.Y. All rights reserved.
//

#import "PreferencesJSONHandleViewController.h"

@interface PreferencesJSONHandleViewController ()

@property (weak) IBOutlet NSTextField *requestBaseName;
@property (weak) IBOutlet NSTextField *validatorMethodName;
@property (weak) IBOutlet NSButton *isNeedTestMethod;
@property (weak) IBOutlet NSTextField *testMethodName;

@property (weak) IBOutlet NSTextField *sepView;

@property (weak) IBOutlet NSButton *defaultAllJSONBtn;
@property (weak) IBOutlet NSButton *conentJSONKeyBtn;
@property (weak) IBOutlet NSButton *propertyIsOptionalButton;
@property (weak) IBOutlet NSButton *businessPrefixButton;
@property (weak) IBOutlet NSTextField *contentJSONKeyTextFiled;

@property (nonatomic,copy) NSString *test;
@end

@implementation PreferencesJSONHandleViewController

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
    self.sepView.layer.backgroundColor = [NSColor redColor].CGColor;//[NSColor colorWithRed:212/255.0 green:212/255.0 blue:212/255.0 alpha:1];
    [self.sepView setNeedsDisplay:YES];

    [self bindUI];
}

#pragma mark - Bind

-(void)bindUI{
    [self.requestBaseName bind:@"value" toObject:PreferencesModel withKeyPath:@"requestClassBaseName" options:nil];
    [self.isNeedTestMethod bind:@"value" toObject:PreferencesModel withKeyPath:@"isCreatTestMethod" options:nil];
    self.testMethodName.enabled = PreferencesModel.isCreatTestMethod;
    [self.validatorMethodName bind:@"value" toObject:PreferencesModel withKeyPath:@"requestValidatorMethodName" options:nil];
    [self.testMethodName bind:@"value" toObject:PreferencesModel withKeyPath:@"testMethodName" options:nil];
    
    
    /**
     *  这里因为默认启用,所以这么设置
     */
    [self.propertyIsOptionalButton bind:@"value" toObject:PreferencesModel withKeyPath:@"isPropertyIsOptional" options:nil];
    [self.businessPrefixButton bind:@"value" toObject:PreferencesModel withKeyPath:@"propertyBusinessPrefixEnable" options:nil];
    
    [self.defaultAllJSONBtn bind:@"value" toObject:PreferencesModel withKeyPath:@"isDefaultAllJSON" options:nil];
    self.conentJSONKeyBtn.state = (self.defaultAllJSONBtn.state > 0)?0:1;
    self.contentJSONKeyTextFiled.enabled = (self.defaultAllJSONBtn.state > 0)?NO:YES;
    [self.contentJSONKeyTextFiled bind:@"value" toObject:PreferencesModel withKeyPath:@"contentJSONKey" options:nil];
}

#pragma mark - action

//是否启用测试方法
- (IBAction)changeSelecteState:(id)sender {
    self.testMethodName.enabled = (self.isNeedTestMethod.state == 1);
}
//默认解析全部json
- (IBAction)defaultAllJSONBtnChangeState:(id)sender {
    PreferencesModel.isDefaultAllJSON = YES;
    self.conentJSONKeyBtn.state = (self.defaultAllJSONBtn.state == 1)?0:1;
    self.contentJSONKeyTextFiled.enabled = (self.defaultAllJSONBtn.state == 1)?NO:YES;
}
//指定要解析的json key
- (IBAction)contentJSONBtnChangeState:(id)sender {
    PreferencesModel.isDefaultAllJSON = NO;
    self.defaultAllJSONBtn.state = PreferencesModel.isDefaultAllJSON;
    self.contentJSONKeyTextFiled.enabled = !PreferencesModel.isDefaultAllJSON;
}

#pragma mark - CCNPreferencesWindowControllerDelegate

- (NSString *)preferenceIdentifier { return @"JSONHandlePreferencesIdentifier"; }
- (NSString *)preferenceTitle { return @"JSON"; }
- (NSImage *)preferenceIcon {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"X.Y.QYXcodePlugIn"];
    
    NSImage *bangImg = [bundle imageForResource:@"JSON-Code-icon.png"];
    
    return bangImg;
}

@end
