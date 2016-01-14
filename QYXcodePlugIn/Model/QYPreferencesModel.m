//
//  QYPreferencesModel.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/12/22.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "QYPreferencesModel.h"

@implementation QYPreferencesModel






//===========================================================
//  Keyed Archiving
//
//===========================================================
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.getterJSON forKey:@"GetterJSON"];
    [encoder encodeObject:self.requestClassBaseName forKey:@"RequestClassBaseName"];
    [encoder encodeBool:self.isCreatTestMethod forKey:@"CreatTestMethod"];
    [encoder encodeObject:self.testMethodName forKey:@"TestMethodName"];
    [encoder encodeObject:self.requestValidatorMethodName forKey:@"RequestValidatorMethodName"];
    [encoder encodeBool:self.isClearCalalogSearchTitle forKey:@"ClearCalalogSearchTitle"];

}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) {
        self.getterJSON = [decoder decodeObjectForKey:@"GetterJSON"];
        self.requestClassBaseName = [decoder decodeObjectForKey:@"RequestClassBaseName"];
        self.isCreatTestMethod = [decoder decodeBoolForKey:@"CreatTestMethod"];
        self.testMethodName = [decoder decodeObjectForKey:@"TestMethodName"];
        self.requestValidatorMethodName = [decoder decodeObjectForKey:@"RequestValidatorMethodName"];
        self.isClearCalalogSearchTitle = [decoder decodeBoolForKey:@"ClearCalalogSearchTitle"];

    }
    return self;
}

@end