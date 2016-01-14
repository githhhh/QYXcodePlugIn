//
//  NSMenu+RegisterMenuItem.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/12/21.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSMenu (RegisterMenuItem)

-(void)registerMenuItem:(Class)menuItemClass;

@end
