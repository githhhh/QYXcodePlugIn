//
//  NSObject+MagicIDEActivityReportStringSegment.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 16/1/2.
//  Copyright © 2016年 X.Y. All rights reserved.
//

#import "NSObject+MagicIDEActivityReportStringSegment.h"
#import "NSObject+MethodSwizzler.h"
@implementation NSObject (MagicIDEActivityReportStringSegment)

// 2
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSClassFromString(@"IDEActivityReportStringSegment") swizzleWithOriginalSelector:NSSelectorFromString(@"initWithString:priority:frontSeparator:backSeparator:") swizzledSelector:@selector(Rayrolling_initWithString:priority:frontSeparator:backSeparator:) isClassMethod:NO];
    });
}

- (id)Rayrolling_initWithString:(NSString *)string priority:(double)priority frontSeparator:(id)frontSeparator backSeparator:(id)backSeparator
{
    
    // 3
    static NSArray *lyrics;
    
    // 4
    static NSInteger index = 0;
    static dispatch_once_t onceToken;
    
    // 5
    dispatch_once(&onceToken, ^{
        lyrics = @[@"Never gonna live you up.",
                   @"Never gonna set you down."];
        
        
    });
    
    // 6
    index = index >= lyrics.count -1 ? 0 : index + 1;
    
    // 7
   
    return [self Rayrolling_initWithString:lyrics[index] priority:priority frontSeparator:frontSeparator backSeparator:backSeparator];
    
//    return [self Rayrolling_initWithString:string priority:priority frontSeparator:frontSeparator backSeparator:backSeparator];
}

@end
