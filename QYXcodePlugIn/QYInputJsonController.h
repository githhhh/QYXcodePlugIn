//
//  QYInputJsonController.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/24.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol QYInputJsonControllerDelegate <NSObject>

-(void)windowDidClose;

@end

@interface QYInputJsonController : NSWindowController

@property (nonatomic,strong) NSTextView *sourceTextView;
@property (nonatomic,copy) NSString *sourcePath;
@property (nonatomic,weak) id delegate;
@end
