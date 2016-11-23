//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Template From QYXcodePlugin
//___COPYRIGHT___
//


#import "___FILEBASENAME___.h"

@interface ___FILEBASENAMEASIDENTIFIER___()


@end

@implementation ___FILEBASENAMEASIDENTIFIER___

+ (id)sharedSingleton
{
    static ___FILEBASENAMEASIDENTIFIER___ *_sharedSingleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSingleton = [[self alloc] init];
    });
    return _sharedSingleton;
}


- (id)init
{
    self = [super init];
    if (self) {
        
        
    }
    return self;
}


@end
