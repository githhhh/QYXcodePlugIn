//
//  QYXcodePlugIn.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/18.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//

#import "QYXcodePlugIn.h"
#import <Carbon/Carbon.h>

static QYXcodePlugIn *sharedPlugin;

@interface QYXcodePlugIn ()

@property (nonatomic, strong, readwrite) NSBundle *bundle;

@property (nonatomic, retain ,readwrite) QYIDENotificationHandler *notificationHandler;

@end

@implementation QYXcodePlugIn

//static OSStatus lafHotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData)
//{
//    EventHotKeyID lafRef;
//    GetEventParameter(anEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(lafRef), NULL, &lafRef);
//    switch (lafRef.id) {
//        case 2: {
//            LOG(@"============");
//        } break;
//    }
//    return noErr;
//}
//

+ (instancetype)sharedPlugin {
    return sharedPlugin;
}

+ (void)pluginDidLoad:(NSBundle *)plugin {
    
    static dispatch_once_t onceToken;

    if ([[[NSBundle mainBundle] infoDictionary][@"CFBundleName"] isEqual:@"Xcode"]) {
        
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}


+ (void)reloadPlugin:(NSBundle *)plugin{
    
    if ([[[NSBundle mainBundle] infoDictionary][@"CFBundleName"] isEqual:@"Xcode"]) {

        sharedPlugin = [[self alloc] initWithBundle:plugin];
        
        [[[QYXcodePlugIn sharedPlugin] notificationHandler] didApplicationFinishLaunchingNotification:nil];
    }
}

- (id)initWithBundle:(NSBundle *)plugin {
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        //通知
        self.notificationHandler =  [[QYIDENotificationHandler alloc] init];
        
//        [self loadKeyboardHandler];
    }

    return self;
}





//#pragma mark -  直接注册热键 事件
//- (void)loadKeyboardHandler
//{
//    EventHotKeyRef lafHotKeyRef;
//    EventHotKeyID lafHotKeyID;
//    EventTypeSpec eventType;
//    
//    eventType.eventClass = kEventClassKeyboard;
//    eventType.eventKind = kEventHotKeyPressed;
//    InstallApplicationEventHandler(&lafHotKeyHandler, 1, &eventType, NULL, NULL);
//    
//    lafHotKeyID.signature = 'lak1';
//    lafHotKeyID.id = 2;
//    
//    RegisterEventHotKey(kVK_ANSI_T, cmdKey + shiftKey, lafHotKeyID, GetApplicationEventTarget(), 0, &lafHotKeyRef);
//}

@end
