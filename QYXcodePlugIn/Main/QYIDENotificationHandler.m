//
//  QYIDENotificationHandler.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/22.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//

#import "QYAutoGetterAchieve.h"
#import "QYCategoryAutoGetterSetterAchieve.h"
#import "MHXcodeDocumentNavigator.h"
#import "NSMenu+RegisterMenuItem.h"
#import "NSString+Extensions.h"
#import "NSTextView+Operations.h"
#import "Promise.h"
#import "QYAutoGetterMenuItem.h"
#import "QYIDENotificationHandler.h"
#import "QYRequestVerifyController.h"
#import "QYPreferencesController.h"
#import "QYRequestVerifiMenuItem.h"
#import "QYPreferencesMenuItem.h"
#import "QYWindowsCloseProtocol.h"
#import "QYAutoModelMenuItem.h"
#import "ESInputJsonController.h"
#import "QYUpdateMenuItem.h"

@interface QYIDENotificationHandler () <QYWindowsCloseProtocol>
//window
@property (nonatomic, retain) QYRequestVerifyController *requestVerifyWindow;
@property (nonatomic, retain) QYPreferencesController *preferencesWindow;
@property (nonatomic, retain) ESInputJsonController *autoModelWindow;
//
@property (nonatomic, retain) NSString *clangFormateContentPath;
@property (nonatomic, retain) QYPreferencesModel *preferencesModel;

@end

@implementation QYIDENotificationHandler

#pragma mark - Life cycle

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(projectDidOpenNotification:)
                                                     name:@"PBXProjectDidOpenNotification"
                                                   object:nil];

    }
    return self;
}


#pragma mark -  Xcode 通知

- (void)didApplicationFinishLaunchingNotification:(NSNotification *)noti
{
    //cycript
#if DEBUG
//    void *handle = dlopen("/usr/lib/libcycript.dylib", RTLD_NOW);
//    void (*listenServer)(short) = dlsym(handle, "CYListenServer");
//    (*listenServer)(54321);
#endif
    
    // removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSApplicationDidFinishLaunchingNotification
                                                  object:nil];
    

    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    
    //添加子菜单er
    [self addCustomMenuOnEdit];
}

-(void)projectDidOpenNotification:(NSNotification *)noti{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PBXProjectDidOpenNotification" object:nil];

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

    //Auto JSONModel
    [subMenus registerMenuItem:[QYAutoModelMenuItem class]];

    //请求校验
    [subMenus registerMenuItem:[QYRequestVerifiMenuItem class]];
    [subMenus insertItem:[NSMenuItem separatorItem] atIndex:3];

    //全局设置
    [subMenus registerMenuItem:[QYPreferencesMenuItem class]];
    //更新
    [subMenus registerMenuItem:[QYUpdateMenuItem class]];
    
    [actionMenuItem setSubmenu:subMenus];
}

#pragma mark - receiveMenuItemPromise

-(void)receiveMenuItemPromise:(PMKPromise *)promise sender:(QYMenuBaseItem *)sender{
    
    promise.thenOn(dispatch_get_main_queue(),^(id obj){
        //show window
        if ([sender isKindOfClass:[QYRequestVerifiMenuItem class]] && [obj isKindOfClass:[NSValue class]]) {
            [self showRequestVerifiWindow];
            self.requestVerifyWindow.insertRangeValue = obj;
            return ;
        }
        if ([sender isKindOfClass:[QYPreferencesMenuItem class]]) {
            [self showPreferencesWindow];
            return ;
        }
    
        if ([sender isKindOfClass:[QYAutoModelMenuItem class]]) {
            //父类名称
            [self showAutoModelWindow:[obj boolValue]];
            return ;
        }
    }).catchOn(dispatch_get_main_queue(),^(NSError *err){
        
        NSString* errInfo = dominWithError(err);
//        [LAFIDESourceCodeEditor showAboveCaret:errInfo color:[NSColor yellowColor]];
        [LAFIDESourceCodeEditor showAboveCaretOnCenter:errInfo color:[NSColor yellowColor]];

    }).finally(^(){
        sender.windowDelegate = nil;
    });
}

-(void)showRequestVerifiWindow{
    self.requestVerifyWindow = [[QYRequestVerifyController alloc] initWithWindowNibName:@"QYRequestVerifyController"];
    self.requestVerifyWindow.sourceTextView = [MHXcodeDocumentNavigator currentSourceCodeTextView];
    self.requestVerifyWindow.delegate = self;
    [self.requestVerifyWindow showWindow:self];
}

-(void)showPreferencesWindow{
    self.preferencesWindow = [[QYPreferencesController alloc] initWithWindowNibName:@"QYPreferencesController"];
    self.preferencesWindow.pgDelegate = self;
    [self.preferencesWindow showWindow:self];
}

-(void)showAutoModelWindow:(BOOL)isJSONModel{
    self.autoModelWindow = [[ESInputJsonController alloc] initWithWindowNibName:@"ESInputJsonController"];
    self.autoModelWindow.editorView = [MHXcodeDocumentNavigator currentSourceCodeTextView];
    self.autoModelWindow.currentImpleMentationPath = [QYIDENotificationHandler currentImpleMentationPath];
    self.autoModelWindow.delegate = self;
    self.autoModelWindow.isJsonModel = isJSONModel;
    [self.autoModelWindow showWindow:self];
}

#pragma mark - publice method
+ (NSString *)currentImpleMentationPath
{
    NSString *sourceFilePath = [MHXcodeDocumentNavigator currentFilePath];
    //.m path
    sourceFilePath = [sourceFilePath stringByReplacingCharactersInRange:NSMakeRange(sourceFilePath.length - 1, 1)
                                                                 withString:@"m"];
    return sourceFilePath;
}

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

- (QYPreferencesModel *)preferencesModel{
    
    if (!_preferencesModel) {
        NSUserDefaults *userdf = [NSUserDefaults standardUserDefaults];
        NSData *data = [userdf objectForKey:@"preferencesModel"];
        
        id setMode = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if (!setMode||![setMode isKindOfClass:[QYPreferencesModel class]]) {
            return nil;
        }
        _preferencesModel = setMode;
    }
    
    return _preferencesModel;
}

- (void)updatePreferencesModel:(QYPreferencesModel *)preferencesModel{
    _preferencesModel = preferencesModel;
    NSData *customData = [NSKeyedArchiver archivedDataWithRootObject:preferencesModel] ;
    NSUserDefaults *userdf = [NSUserDefaults standardUserDefaults];
    [userdf setObject:customData forKey:@"preferencesModel"];
    [userdf synchronize];
}




#pragma mark - close window

- (void)windowDidClose
{
    if (self.requestVerifyWindow) {
        [self.requestVerifyWindow.window close];
        self.requestVerifyWindow.window = nil;
        self.requestVerifyWindow = nil;
    }
    
    if (self.preferencesWindow) {
        [self.preferencesWindow.window close];
        self.preferencesWindow.window = nil;
        self.preferencesWindow = nil;
    }
    
    if (self.autoModelWindow) {
        [self.autoModelWindow.window close];
        self.autoModelWindow.window = nil;
        self.autoModelWindow = nil;
    }
}

@end
