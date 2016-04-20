//
//  QYUpdateAlert.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 16/4/19.
//  Copyright © 2016年 X.Y. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QYWindowsCloseProtocol.h"

@interface QYUpdateAlert : NSWindowController

@property (nonatomic,copy) NSString *title;

@property (nonatomic,copy) NSString *msg;

@property (nonatomic,copy) NSString *cancelTitle;

@property (nonatomic,copy) NSString *confirmTitle;

@property (nonatomic,copy)void(^confirmBlock)(NSInteger index);

@property (unsafe_unretained) IBOutlet NSTextView *alertMessage;

@property (weak) IBOutlet NSImageView *alertIcon;

@property (weak) IBOutlet NSButton *cancelBtn;

@property (weak) IBOutlet NSButton *confirmBtn;

@property (weak) IBOutlet NSTextField *alertTitle;

@end
