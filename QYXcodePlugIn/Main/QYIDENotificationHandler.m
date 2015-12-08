//
//  QYIDENotificationHandler.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/22.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//

#import "QYIDENotificationHandler.h"
#import "MHXcodeDocumentNavigator.h"
#import "NSString+Extensions.h"
#import <ShortcutRecorder/ShortcutRecorder.h>
#import <PTHotKey/PTHotKeyCenter.h>
#import <PTHotKey/PTHotKey+ShortcutRecorder.h>

#import "AutoGetterAchieve.h"
#import "QYInputJsonController.h"
#import "QYPluginSetingController.h"
#import "QYWindowsCloseProtocol.h"
#import "NSTextView+Operations.h"
/**
 *  菜单结构
 */
#define SuperMenu @"Edit"
#define QYMenu @"QYAction"
#define QYMenu_AutoGetter @"AutoGetter"
#define QYMenu_RequestValidator @"RequestValidator"
#define QYMenu_Settings @"Settings"


@interface QYIDENotificationHandler () <QYWindowsCloseProtocol> {
}
@property (nonatomic, retain) QYInputJsonController *inputJsonWindow;
@property (nonatomic, retain) QYPluginSetingController *setingWindow;
@property (nonatomic,retain)NSString *tempFilePath;

@end

@implementation QYIDENotificationHandler


+ (id)sharedHandler
{
    static QYIDENotificationHandler *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}


- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        
        
        //选中改变
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeSelecteText:)
                                                     name:NSTextViewDidChangeSelectionNotification
                                                   object:nil];
    }
    return self;
}
#pragma mark -  Xcode 通知
#pragma mark -  启动
- (void)didApplicationFinishLaunchingNotification:(NSNotification *)noti
{
    // removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSApplicationDidFinishLaunchingNotification
                                                  object:nil];
    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    
    //添加子菜单
    [self addCustomMenuOnEdit];
}

#pragma mark -  选中内容改变
- (void)didChangeSelecteText:(NSNotification *)noti
{
    if ([[noti object] isKindOfClass:[NSTextView class]]) {
        NSTextView *textView = (NSTextView *)[noti object];
        
        NSArray *selectedRanges = [textView selectedRanges];
        
        if ([selectedRanges count] == 0) {
            return;
        }
        
        NSRange selectedRange = [[selectedRanges objectAtIndex:0] rangeValue];
        NSString *text = textView.textStorage.string;
        NSString *selectedText = [text substringWithRange:selectedRange];
        
        self.globlaParamter = selectedText;
    }
}

/**
 *  添加子菜单
 */
- (void)addCustomMenuOnEdit
{
    NSMenuItem *editItem = [[NSApp mainMenu] itemWithTitle:SuperMenu];
    if (!editItem) {
        return;
    }
    [[editItem submenu] addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *actionMenuItem = [[NSMenuItem alloc] init];
    [actionMenuItem setTitle:QYMenu];
    [[editItem submenu] addItem:actionMenuItem];
    
    
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    
    NSMenu *actinMenus = [[NSMenu alloc] init];
    // get方法生成
    self.geterMenuItem = [self menuItemWithTitle:QYMenu_AutoGetter action:@selector(autoGetterAction:)];
    
    [actinMenus addItem:self.geterMenuItem];
    [self.geterMenuItem bind:@"keyEquivalent"
                    toObject:defaults
                 withKeyPath:AutoGetterMenuKeyPath
                     options:@{NSValueTransformerBindingOption : [SRKeyEquivalentTransformer new]}];
    [self.geterMenuItem bind:@"keyEquivalentModifierMask"
                    toObject:defaults
                 withKeyPath:AutoGetterMenuKeyPath
                     options:@{NSValueTransformerBindingOption : [SRKeyEquivalentModifierMaskTransformer new]}];
    //分割线
    [actinMenus insertItem:[NSMenuItem separatorItem] atIndex:1];
    
    
    //请求校验生成
    self.requestVerifiMenuItem =
    [self menuItemWithTitle:QYMenu_RequestValidator action:@selector(requestValidatorAction:)];
    [actinMenus addItem:self.requestVerifiMenuItem];
    
    [self.requestVerifiMenuItem bind:@"keyEquivalent"
                            toObject:defaults
                         withKeyPath:RequestVerifiMenuKeyPath
                             options:@{NSValueTransformerBindingOption : [SRKeyEquivalentTransformer new]}];
    [self.requestVerifiMenuItem
     bind:@"keyEquivalentModifierMask"
     toObject:defaults
     withKeyPath:RequestVerifiMenuKeyPath
     options:@{NSValueTransformerBindingOption : [SRKeyEquivalentModifierMaskTransformer new]}];
    //分割线
    [actinMenus insertItem:[NSMenuItem separatorItem] atIndex:1];
    
    
    //全局设置
    self.settingsMenuItem = [self menuItemWithTitle:QYMenu_Settings action:@selector(settingsAction:)];
    
    [actinMenus addItem:self.settingsMenuItem];
    
    [self.settingsMenuItem bind:@"keyEquivalent"
                       toObject:defaults
                    withKeyPath:SettingsMenuKeyPath
                        options:@{NSValueTransformerBindingOption : [SRKeyEquivalentTransformer new]}];
    [self.settingsMenuItem bind:@"keyEquivalentModifierMask"
                       toObject:defaults
                    withKeyPath:SettingsMenuKeyPath
                        options:@{NSValueTransformerBindingOption : [SRKeyEquivalentModifierMaskTransformer new]}];
    
    [actionMenuItem setSubmenu:actinMenus];
}


#pragma mark -
#pragma mark - menuAction

- (void)autoGetterAction:(id)sender
{
    AutoGetterAchieve *agAchieve = [[AutoGetterAchieve alloc] init];
    [agAchieve getterAction:self.globlaParamter];
}

- (void)requestValidatorAction:(id)sender
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        BOOL isRf = [self isRequestFileCurrent];
        if (!isRf) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.inputJsonWindow = [[QYInputJsonController alloc] initWithWindowNibName:@"QYInputJsonController"];
            self.inputJsonWindow.sourceTextView = [MHXcodeDocumentNavigator currentSourceCodeTextView];
            self.inputJsonWindow.delegate = self;
            [self.inputJsonWindow showWindow:self];
        });
    });
}
- (void)settingsAction:(id)sender
{
    self.setingWindow = [[QYPluginSetingController alloc] initWithWindowNibName:@"QYPluginSetingController"];
    self.setingWindow.pgDelegate = self;
    [self.setingWindow showWindow:self];
}


#pragma mark - private method

- (BOOL)isRequestFileCurrent
{
    NSString *currentFilePath = [MHXcodeDocumentNavigator currentFilePath];
    if (!currentFilePath) {
        return NO;
    }
    NSTextView *textView = [MHXcodeDocumentNavigator currentSourceCodeTextView];
    if (!textView) {
        return NO;
    }
    currentFilePath =
    [currentFilePath stringByReplacingCharactersInRange:NSMakeRange(currentFilePath.length - 1, 1) withString:@"h"];
    NSString *soureString = [NSString stringWithContentsOfFile:currentFilePath encoding:NSUTF8StringEncoding error:nil];
    
    //读取配置
    NSUserDefaults *userdf = [NSUserDefaults standardUserDefaults];
    NSString *requstBName = [userdf objectForKey:rqBName];
    if (!requstBName) {
        requstBName = @"QYRequest";
    }
    
    // 验证当前.h 文件的父类是否是制定类
    NSArray *contents =
    [soureString matcheGroupWith:[NSString stringWithFormat:@"@\\w+\\s*(\\w+)\\s*\\:\\s+%@\\s", requstBName]];
    if (!([contents count] > 0)) {
        return NO;
    }
    return YES;
}
#pragma mark - publice method

- (NSString *)projectTempFilePath{
    if (!_tempFilePath) {
        NSString *currentFilePath = [MHXcodeDocumentNavigator currentWorkspacePath];
        if (currentFilePath&&currentFilePath.length>0) {
            NSString *dicStr = [currentFilePath stringByDeletingLastPathComponent];
            _tempFilePath = [NSString stringWithFormat:@"%@/tempFilee",dicStr];
        }
    }
    return _tempFilePath;
}

#pragma mark - create MenuItem
- (NSMenuItem *)menuItemWithTitle:(NSString *)title action:(SEL)action
{
    NSMenuItem *rvMenu = [[NSMenuItem alloc] init];
    rvMenu.target = self;
    rvMenu.action = action;
    rvMenu.title = title;
    return rvMenu;
}


#pragma mark - 释放
- (void)windowDidClose
{
    if (self.inputJsonWindow) {
        [self.inputJsonWindow.window close];
        self.inputJsonWindow.window = nil;
        self.inputJsonWindow = nil;
    }
    
    if (self.setingWindow) {
        [self.setingWindow.window close];
        self.setingWindow.window = nil;
        self.setingWindow = nil;
    }
}

- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self]; }


@end
