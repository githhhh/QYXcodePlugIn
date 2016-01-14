//
//  QYMenuBaseItem.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/12/21.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ShortcutRecorder/ShortcutRecorder.h>
#import <PTHotKey/PTHotKeyCenter.h>
#import <PTHotKey/PTHotKey+ShortcutRecorder.h>
@class QYMenuBaseItem;
@class PMKPromise;
@protocol MenuItemPromiseDelegate <NSObject>

@optional
-(void)receiveMenuItemPromise:(PMKPromise *)promise sender:(QYMenuBaseItem *)sender;

@end


@interface QYMenuBaseItem : NSMenuItem

@property (nonatomic,weak) id<MenuItemPromiseDelegate> windowDelegate;

-(void)bindDynamicHoteKey;
-(void)menuItemAction:(id)sender;

@end
