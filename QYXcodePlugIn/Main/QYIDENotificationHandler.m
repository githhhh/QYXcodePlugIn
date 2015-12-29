//
//  QYIDENotificationHandler.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/22.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//

#import "AutoGetterAchieve.h"
#import "CategoryGetterSetterAchieve.h"
#import "MHXcodeDocumentNavigator.h"
#import "NSMenu+RegisterMenuItem.h"
#import "NSString+Extensions.h"
#import "NSTextView+Operations.h"
#import "Promise.h"
#import "QYAutoGetterMenuItem.h"
#import "QYIDENotificationHandler.h"
#import "QYInputJsonController.h"
#import "QYPluginSetingController.h"
#import "QYRequestVerifiMenuItem.h"
#import "QYSettingMenuItem.h"
#import "QYWindowsCloseProtocol.h"


@interface QYIDENotificationHandler () <QYWindowsCloseProtocol>

@property (nonatomic, retain) QYInputJsonController *inputJsonWindow;
@property (nonatomic, retain) QYPluginSetingController *setingWindow;
@property (nonatomic, retain) NSString *clangFormateContentPath;
@property (nonatomic, retain) QYSettingModel *settingModel;
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
    
    NSMenu *subMenus = [[NSMenu alloc] init];
    //AutoGetter
    [subMenus registerMenuItem:[QYAutoGetterMenuItem class]];

    //请求校验
    [subMenus registerMenuItem:[QYRequestVerifiMenuItem class]];
    //全局设置
    [subMenus registerMenuItem:[QYSettingMenuItem class]];
    
    [actionMenuItem setSubmenu:subMenus];
}


#pragma mark -
#pragma mark - receiveMenuItemPromise

-(void)receiveMenuItemPromise:(PMKPromise *)promise sender:(QYMenuBaseItem *)sender{
    
    promise.thenOn(dispatch_get_main_queue(),^(NSNumber *isValedate){
        //show window
        if ([sender isKindOfClass:[QYRequestVerifiMenuItem class]]) {
            [self showRequestVerifiWindow];
        }
        if ([sender isKindOfClass:[QYSettingMenuItem class]]) {
            [self showSettingWindow];
        }
    
    }).catch(^(NSError *error){
    
    }).finally(^(){
        sender.windowDelegate = nil;
    });
}

-(void)showRequestVerifiWindow{
    self.inputJsonWindow = [[QYInputJsonController alloc] initWithWindowNibName:@"QYInputJsonController"];
    self.inputJsonWindow.sourceTextView = [MHXcodeDocumentNavigator currentSourceCodeTextView];
    self.inputJsonWindow.delegate = self;
    [self.inputJsonWindow showWindow:self];
}

-(void)showSettingWindow{
    self.setingWindow = [[QYPluginSetingController alloc] initWithWindowNibName:@"QYPluginSetingController"];
    self.setingWindow.pgDelegate = self;
    [self.setingWindow showWindow:self];
}


#pragma mark - publice method

- (NSString *)clangFormateContentPath{
    if (!_clangFormateContentPath) {
        NSString *currentFilePath = [MHXcodeDocumentNavigator currentWorkspacePath];
        if (currentFilePath&&currentFilePath.length>0) {
            NSString *dicStr = [currentFilePath stringByDeletingLastPathComponent];
            _clangFormateContentPath = [NSString stringWithFormat:@"%@/clangFormateContent.tm",dicStr];
        }
    }
    return _clangFormateContentPath;
}

- (QYSettingModel *)settingModel{
    if (!_settingModel) {
        NSUserDefaults *userdf = [NSUserDefaults standardUserDefaults];
        NSData *data = [userdf objectForKey:@"settingModel"];
        
        id setMode = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if (!setMode||![setMode isKindOfClass:[QYSettingModel class]]) {
            return nil;
        }
        _settingModel = setMode;
    }
    return _settingModel;
}



#pragma mark - close window

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
