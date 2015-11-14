//
//  QYShortcutRecorderController.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/11/13.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PTHotKey/PTHotKeyCenter.h>
#import <ShortcutRecorder/ShortcutRecorder.h>

@interface QYShortcutRecorderController : NSWindowController<SRRecorderControlDelegate, SRValidatorDelegate>

@property (weak) IBOutlet SRRecorderControl *agRecorderControl;
@property (weak) IBOutlet SRRecorderControl *rvRecorderControl;
@property (weak) IBOutlet SRRecorderControl *settingRecorderControl;

@end
