//
//  WebFrame+Rayrolling_WebFrame.m
//  Rayrolling
//
//  Created by Derek Selander on 5/29/15.
//  Copyright (c) 2015 RayWenderlich. All rights reserved.
//

#import "WebFrame+Rayrolling_WebFrame.h"
#import "NSObject+MethodSwizzler.h"

@implementation WebFrame (Rayrolling_WebFrame)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleWithOriginalSelector:@selector(loadRequest:) swizzledSelector:@selector(Rayrolling_loadRequest:) isClassMethod:NO];
        
    });
}

- (void)Rayrolling_loadRequest:(NSURLRequest *)request
{
//    if (request) {
//        NSURL *url = [NSURL URLWithString:@"https://www.youtube.com/watch?v=ce-_0opZzh0"];
//        NSURLRequest *rickrollingRequest = [NSURLRequest requestWithURL:url];
//        [self Rayrolling_loadRequest:rickrollingRequest];
//
//    }
    
    [self Rayrolling_loadRequest:request];
    
}
@end