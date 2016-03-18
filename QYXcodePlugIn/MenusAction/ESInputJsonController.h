//
//  TestWindowController.h
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/19.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QYWindowsCloseProtocol.h"

@interface ESInputJsonController : NSWindowController

@property (nonatomic,strong) NSTextView *editorView;
@property (nonatomic,copy) NSString *currentImpleMentationPath;


@property (nonatomic,weak) id<QYWindowsCloseProtocol> delegate;
@end
