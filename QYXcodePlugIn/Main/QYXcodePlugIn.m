//
//  QYXcodePlugIn.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/18.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//

#import "QYXcodePlugIn.h"
#import "MenuItemAchieve.h"
#import <Carbon/Carbon.h>
#import "QYIDENotificationHandler.h"

static QYXcodePlugIn *sharedPlugin;

@interface QYXcodePlugIn()

@property (nonatomic, strong, readwrite) NSBundle *bundle;

@end

@implementation QYXcodePlugIn

static OSStatus lafHotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData) {
    
    EventHotKeyID lafRef;
    GetEventParameter(anEvent,kEventParamDirectObject,typeEventHotKeyID,NULL,sizeof(lafRef),NULL,&lafRef);
    switch (lafRef.id) {
        case 2:
        {
            NSLog(@"============");
        }
            break;
            
    }
    return noErr;
}




+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[QYXcodePlugIn alloc] initWithBundle:plugin];
        });
    }
}


- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        //通知
        [QYIDENotificationHandler  sharedHandler];
        
        [self loadKeyboardHandler];
    }
    return self;
}



#pragma mark -  直接注册热键 事件
- (void)loadKeyboardHandler {
    EventHotKeyRef lafHotKeyRef;
    EventHotKeyID lafHotKeyID;
    EventTypeSpec eventType;
    
    eventType.eventClass=kEventClassKeyboard;
    eventType.eventKind=kEventHotKeyPressed;
    InstallApplicationEventHandler(&lafHotKeyHandler,1,&eventType,NULL,NULL);
    
    lafHotKeyID.signature='lak1';
    lafHotKeyID.id=2;
    
    RegisterEventHotKey(kVK_ANSI_T, cmdKey+shiftKey, lafHotKeyID, GetApplicationEventTarget(), 0, &lafHotKeyRef);
}

@end
