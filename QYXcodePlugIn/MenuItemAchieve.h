//
//  MenuItemAchieve.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/18.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QYMenuActionProtocol.h"
@interface MenuItemAchieve : NSObject
+ (id<QYMenuActionProtocol>)createMenuActionResponse:(NSMenuItem *)item;
@end
