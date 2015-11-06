//
//  QYIDENotificationHandler.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/22.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//

#import "QYIDENotificationHandler.h"

#import <AppKit/AppKit.h>
#import "QYMenuActionProtocol.h"
#import "MenuItemAchieve.h"
#import "QYInputJsonController.h"
#import "MHXcodeDocumentNavigator.h"
#import "NSString+Extensions.h"
#import "NSMenuItem+QYXcodePluginMenuItem.h"

#import "QYPluginSetingController.h"

@interface QYIDENotificationHandler ()<QYInputJsonControllerDelegate>
@property (nonatomic,retain)QYInputJsonController *inputJsonWindow;
@property (nonatomic,retain)QYPluginSetingController  *setingWindow;

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


-(id)init{
    
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        
        
        //选中改变
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeSelecteText:) name:NSTextViewDidChangeSelectionNotification object:nil];

        
        
    }
    return self;
}
#pragma mark -
#pragma mark -  Xcode 启动
- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] init];
        [actionMenuItem setTitle:@"QYAction"];
        [[menuItem submenu] addItem:actionMenuItem];
        
        //添加子菜单
        [self addMenuOnQYActionMenu:actionMenuItem];
    }
}

#pragma mark -  选中内容改变
- (void)didChangeSelecteText:(NSNotification *)noti{
    
    if ([[noti object] isKindOfClass:[NSTextView class]]) {
        NSTextView *textView = (NSTextView *)[noti object];
        
        NSArray *selectedRanges = [textView selectedRanges];
        
        if ([selectedRanges count]== 0) {
            return;
        }
        
        NSRange selectedRange = [[selectedRanges objectAtIndex:0] rangeValue];
        NSString *text = textView.textStorage.string;
        self.globlaParamter = [text substringWithRange:selectedRange];
    }
    
}

#pragma mark - 添加菜单
-(void)addMenuOnQYActionMenu:(NSMenuItem *)actionMenuItem{
    
    NSMenu *subMenu = [[NSMenu alloc] init];
    NSMenuItem*geterMenuItem = [subMenu addItemWithTitle:@"AutoGetter" action:@selector(itemAction:) keyEquivalent:@"F"];//热键 + 『F』
    //设置热键
    [geterMenuItem setKeyEquivalentModifierMask:NSControlKeyMask];
    [geterMenuItem setTarget:self];
    geterMenuItem.tag = 1;
    geterMenuItem.achieveClassName = @"AutoGetterAchieve";
    
    //分割线
    [subMenu insertItem:[NSMenuItem separatorItem] atIndex:1];
    
    
//    NSMenuItem*subItem1 = [subMenu addItemWithTitle:@"RequestTemplate" action:@selector(itemAction:) keyEquivalent:@"D"];//热键 + 『D』
//    //设置热键
//    [subItem1 setKeyEquivalentModifierMask:NSControlKeyMask];
//    [subItem1 setTarget:self];
//    subItem1.tag = 2;
//    
//    //分割线
//    [subMenu insertItem:[NSMenuItem separatorItem] atIndex:1];

    
    NSMenuItem*requestVerifiMenuItem = [subMenu addItemWithTitle:@"请求类校验方法" action:@selector(itemAction:) keyEquivalent:@"S"];//热键 + 『S』
    //设置热键
    [requestVerifiMenuItem setKeyEquivalentModifierMask:NSControlKeyMask];
    [requestVerifiMenuItem setTarget:self];
    requestVerifiMenuItem.tag = 12;
    requestVerifiMenuItem.achieveClassName = @"QYInputJsonController";
    
    
    [subMenu insertItem:[NSMenuItem separatorItem] atIndex:1];
    
    //全局设置
    NSMenuItem *setMenuItem = [subMenu addItemWithTitle:@"Seting" action:@selector(itemAction:) keyEquivalent:@""];
    [setMenuItem setTarget:self];
    setMenuItem.tag = 13;
    setMenuItem.achieveClassName = @"QYPluginSetingController";
    
    [subMenu insertItem:[NSMenuItem separatorItem] atIndex:1];

    
    [actionMenuItem setSubmenu:subMenu];
}
#pragma mark -
#pragma mark - menuAction
/**
 *  根据选中的菜单，初始对应处理单元。
 */
- (void)itemAction:(NSMenuItem *)item
{
    if (item.tag < 10) {
        id<QYMenuActionProtocol> achieve = [MenuItemAchieve createMenuActionResponse:item preBlock:nil];
        if (!achieve) {
            return;
        }
        [achieve menuItemAction:self.globlaParamter];
        
    }else{
        
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            if (item.tag == 12) {
                id achieve = [MenuItemAchieve createMenuActionResponse:item preBlock:^BOOL{
                    
                    NSString *currentFilePath = [MHXcodeDocumentNavigator currentFilePath];
                    if (!currentFilePath) {
                        return NO;
                    }
                    NSTextView *textView = [MHXcodeDocumentNavigator currentSourceCodeTextView];
                    if (!textView) {
                        return NO;
                    }
                    currentFilePath = [currentFilePath stringByReplacingCharactersInRange:NSMakeRange(currentFilePath.length-1, 1) withString:@"h"];
                    NSString *soureString = [NSString stringWithContentsOfFile:currentFilePath encoding:NSUTF8StringEncoding error:nil];
                    
                    NSArray *contents = [soureString matcheGroupWith:@"@\\w+\\s*(\\w+)\\s*\\:\\s+QYRequest\\s"];
                    if (!([contents count]>0)) {
                        return NO;
                    }
                    return YES;
                }];
                
                if (!achieve) {
                    return;
                }
                self.inputJsonWindow = achieve;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.inputJsonWindow.sourceTextView = [MHXcodeDocumentNavigator currentSourceCodeTextView];
                    self.inputJsonWindow.delegate = self;
                    [self.inputJsonWindow showWindow:self.inputJsonWindow];
                    
                });
            }else if (item.tag == 13){
                
                id achieve = [MenuItemAchieve createMenuActionResponse:item preBlock:nil];
                self.setingWindow = achieve;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.setingWindow.delegate = self;
                    [self.setingWindow showWindow:self.setingWindow];
                });
            }
            
            
            
        });
       
    }
   
}

#pragma mark - 释放
-(void)windowDidClose{
    self.inputJsonWindow = nil;
    self.setingWindow = nil;
}




-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
