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

    self.sepView.backgroundColor = [NSColor colorWithRed:212/255.0 green:212/255.0 blue:212/255.0 alpha:1];
    
    
    self.requestBaseName.stringValue     = !IsEmpty(PreferencesModel.requestClassBaseName ) ?PreferencesModel.requestClassBaseName : @"QYRequest";
    self.isNeedTestMethod.state                = PreferencesModel.isCreatTestMethod?1:0;
    self.testMethodName.enabled = PreferencesModel.isCreatTestMethod;
    self.validatorMethodName.stringValue = !IsEmpty(PreferencesModel.requestValidatorMethodName)  ?PreferencesModel.requestValidatorMethodName: @"validatorResult";
    self.testMethodName.stringValue  = !IsEmpty(PreferencesModel.testMethodName) ?PreferencesModel.testMethodName: @"testData";

    
    /**
     *  这里因为默认启用,所以这么设置
     */
    self.propertyIsOptionalButton.state = PreferencesModel.isPropertyIsOptional?0:1;
    self.businessPrefixButton.state = PreferencesModel.propertyBusinessPrefixEnable?0:1;
    
    self.defaultAllJSONBtn.state = PreferencesModel.isDefaultAllJSON?0:1;
    self.conentJSONKeyBtn.state = PreferencesModel.isDefaultAllJSON?1:0;
    self.contentJSONKeyTextFiled.enabled = PreferencesModel.isDefaultAllJSON?YES:NO;
    self.contentJSONKeyTextFiled.stringValue = IsEmpty(PreferencesModel.contentJSONKey)?@"":PreferencesModel.contentJSONKey;

}

-(void)viewDidDisappear{
    [super viewDidDisappear];
    [self collectChangeData];
}


- (IBAction)changeSelecteState:(id)sender {
    
    //    LOG(@"=isTestData=is=%@=======",self.isTestData.state == 1?@"YES":@"NO");
    self.testMethodName.enabled = (self.isNeedTestMethod.state == 1);
}

- (IBAction)defaultAllJSONBtnChangeState:(id)sender {
    self.conentJSONKeyBtn.state = (self.defaultAllJSONBtn.state == 1)?0:1;
    self.contentJSONKeyTextFiled.enabled = (self.defaultAllJSONBtn.state == 1)?NO:YES;
}

- (IBAction)contentJSONBtnChangeState:(id)sender {
    self.defaultAllJSONBtn.state = (self.conentJSONKeyBtn.state == 1)?0:1;
    self.contentJSONKeyTextFiled.enabled = (self.conentJSONKeyBtn.state == 1)?YES:NO;
}


#pragma mark - PreferencesProtocol

-(void)collectChangeData{
    
    PreferencesModel.requestClassBaseName       = self.requestBaseName.stringValue;
    PreferencesModel.isCreatTestMethod          = self.isNeedTestMethod.state == 1?YES:NO;
    PreferencesModel.testMethodName             = self.testMethodName.stringValue;
    PreferencesModel.requestValidatorMethodName = self.validatorMethodName.stringValue;

    /**
     *  这里因为默认为启用,所以这么设置
     */
    PreferencesModel.isPropertyIsOptional       = self.propertyIsOptionalButton.state == 1?NO:YES;
    PreferencesModel.propertyBusinessPrefixEnable = self.businessPrefixButton.state == 1?NO:YES;
    PreferencesModel.isDefaultAllJSON = self.defaultAllJSONBtn.state == 1?NO:YES;
    PreferencesModel.contentJSONKey = self.contentJSONKeyTextFiled.stringValue;
    
}


#pragma mark - CCNPreferencesWindowControllerDelegate

- (NSString *)preferenceIdentifier { return @"JSONHandlePreferencesIdentifier"; }
- (NSString *)preferenceTitle { return @"JSON"; }
- (NSImage *)preferenceIcon { return [NSImage imageNamed:NSImageNameNetwork]; }


@end
