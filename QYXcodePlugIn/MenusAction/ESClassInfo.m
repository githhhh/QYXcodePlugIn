//
//  ESClassInfo.m
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/28.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import "ESClassInfo.h"

@implementation ESClassInfo

- (instancetype)initWithClassNameKey:(NSString *)classNameKey ClassName:(NSString *)className classDic:(NSDictionary *)classDic
{
    self = [super init];
    if (self) {
        /**
         *  默认业务前缀
         */
        self.businessPrefix = classNameKey;
        
        self.classNameKey = classNameKey;
        self.className = className;
        self.classDic = classDic;
    }
    return self;
}

- (NSMutableDictionary *)propertyClassDic{
    if (!_propertyClassDic) {
        _propertyClassDic = [NSMutableDictionary dictionary];
    }
    return _propertyClassDic;
}

- (NSMutableDictionary *)propertyArrayDic{
    if (!_propertyArrayDic) {
        _propertyArrayDic = [NSMutableDictionary dictionary];
    }
    return _propertyArrayDic;
}







@end
