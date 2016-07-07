//
//  QYAutoModelHelper.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 16/3/18.
//  Copyright © 2016年 X.Y. All rights reserved.
//

#import "QYAutoModelHelper.h"

@implementation QYAutoModelHelper

#pragma mark - 获取.h 内容

/**
 *  获取除主类外所有类名
 *
 *  @param classInfo classInfo description
 *
 *  @return 除主类外所有类名
 */
+ (NSString *)atClassContent:(ESClassInfo *)classInfo{
    NSArray *atClassArray = [self atClassArray:classInfo];
    if (atClassArray.count==0) {
        return @"";
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:atClassArray];
    
    NSMutableString *resultStr = [NSMutableString stringWithFormat:@"@class "];
    for (ESClassInfo *classInfo in array) {
        [resultStr appendFormat:@"%@,",classInfo.className];
    }
    
    if ([resultStr hasSuffix:@","]) {
        resultStr = [NSMutableString stringWithString:[resultStr substringToIndex:resultStr.length-1]];
    }
    [resultStr appendString:@";"];
    return resultStr;
}
/**
 *  获取所有除主类外的协议定义
 *
 *  @param classInfo classInfo description
 *
 *  @return return value description
 */
+(NSString *)protocolsClassContent:(ESClassInfo *)classInfo{

    NSArray *atClassArray = [self atClassArray:classInfo];
    if (atClassArray.count==0) {
        return @"";
    }
    
    NSMutableString *resultStr = [NSMutableString string];
    
    [atClassArray enumerateObjectsUsingBlock:^(ESClassInfo* obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
        [resultStr appendString:[self protocolDefineContent:obj]];
        
    }];
    
    return resultStr;
}

/**
 *  获取protocolDefine
 *
 *  @param classInfo classInfo description
 *
 *  @return return value description
 */
+ (NSString *)protocolDefineContent:(ESClassInfo *)classInfo{
    
    if (IsEmpty(classInfo.className)) {
        return @"";
    }
    
    return [NSString stringWithFormat:@"\n@protocol %@ <NSObject>\n\n@end\n",classInfo.className];
}




/**
 *  获取类的所有属性定义
 *
 *  @param classInfo classInfo description
 *
 *  @return 所有属性定义
 */
+ (NSString *)parsePropertyContentWithClassInfo:(ESClassInfo *)classInfo{
    NSMutableString *resultStr = [NSMutableString string];
    NSDictionary *dic = classInfo.classDic;
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, NSObject *obj, BOOL *stop) {
    
        [resultStr appendFormat:@"\n%@\n",[self formatObjcWithKey:key value:obj classInfo:classInfo]];
    
    }];
    return resultStr;
}


/**
 *  获取所有子类头文件内容
 *
 *  @param classInfo classInfo description
 *
 *  @return 所有子类头文件内容
 */
+ (NSString *)subClassContentForH:(ESClassInfo *)classInfo{
    NSMutableString *result = [NSMutableString stringWithFormat:@""];
    for (NSString *key in classInfo.propertyClassDic) {
        ESClassInfo *subClassInfo = classInfo.propertyClassDic[key];
        [result appendFormat:@"%@\n\n",[self parseClassHeaderContentForOjbcWithClassInfo:subClassInfo]];
        [result appendString: [self subClassContentForH:subClassInfo]];
    }
    
    for (NSString *key in classInfo.propertyArrayDic) {
        ESClassInfo *subClassInfo = classInfo.propertyArrayDic[key];
        [result appendFormat:@"%@\n\n",[self parseClassHeaderContentForOjbcWithClassInfo:subClassInfo]];
        [result appendString:[self subClassContentForH:subClassInfo]];
    }
    return result;
}

#pragma mark -  获取.m 内容

/**
 *  获取JSONModel 的Map 方法
 *
 *  @param classInfo classInfo description
 *
 *  @return return value description
 */
+ (NSString *)jsonMapContentOfClassInfo:(ESClassInfo *)classInfo{
    if (classInfo.classDic.count==0) {
        return @"";
    }
    
    NSMutableString *result = [NSMutableString string];
    if (PreferencesModel.isPropertyIsOptional) {
        [result appendString:@"\n+ (BOOL)propertyIsOptional:(NSString *)propertyName {\n    return YES;\n}\n"];
    }
    
    [result appendString:@"\n+ (JSONKeyMapper*)keyMapper\n{\n    return [[JSONKeyMapper alloc] initWithDictionary:@{\n"];

    __block NSInteger idx = 0;
    
    if (PreferencesModel.propertyBusinessPrefixEnable) {
        
        [classInfo.mapDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull businessKey, BOOL * _Nonnull stop) {
            
            NSString *mapStr = [NSString stringWithFormat:@"@\"%@\" : @\"%@\" ,",key,businessKey];
            
            idx ++;
            
            if (idx == [classInfo.mapDic count]) {
                
                mapStr = [mapStr substringToIndex:mapStr.length -2];
                
            }
            
            [result appendString:mapStr];
            
        }];
        
    }else{
        
        [classInfo.classDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
           
            NSString *mapStr = [NSString stringWithFormat:@"@\"%@\" : @\"%@\" ,",key,key];
            
            idx ++;
            
            if (idx == [classInfo.mapDic count]) {
                
                mapStr = [mapStr substringToIndex:mapStr.length -2];
                
            }
            
            [result appendString:mapStr];

        }];
        
    }
    
    [result appendString:@"\n}];\n}\n"];
    
    return result;
}


/**
 *  获取所有子类的实现内容
 *
 *  @param classInfo classInfo description
 *
 *  @return 所有子类的实现内容
 */
+ (NSString *)subClassImplementateContentForM:(ESClassInfo *)classInfo{
    
    
    NSMutableString *result = [NSMutableString stringWithFormat:@""];
    for (NSString *key in classInfo.propertyClassDic) {
        ESClassInfo *subClassInfo = classInfo.propertyClassDic[key];
        [result appendFormat:@"%@\n\n",[self parseClassImplementateForM:subClassInfo]];
        [result appendString: [self subClassImplementateContentForM:subClassInfo]];
    }
    
    for (NSString *key in classInfo.propertyArrayDic) {
        ESClassInfo *subClassInfo = classInfo.propertyArrayDic[key];
        [result appendFormat:@"%@\n\n",[self parseClassImplementateForM:subClassInfo]];
        [result appendString:[self subClassImplementateContentForM:subClassInfo]];
    }
    return result;
    
}

/**
 *  解析.m文件内容--Objc
 *
 *  @param classInfo 类信息
 *
 *  @return
 */
+ (NSString *)parseClassImplementateForM:(ESClassInfo *)classInfo{
    
    NSMutableString *result = [NSMutableString stringWithFormat:@"@implementation %@ \n",classInfo.className];
    [result appendString:[self jsonMapContentOfClassInfo:classInfo]];
    [result appendString:@"\n@end"];
    
    return [result copy];

    
    
    return nil;
}



#pragma mark - Private Method

/**
 *  获取所有涉及的子类
 *
 *  @param classInfo classInfo description
 *
 *  @return 所有涉及的子类
 */
+ (NSArray *)atClassArray:(ESClassInfo *)classInfo{
    NSMutableArray *result = [NSMutableArray array];
    [classInfo.propertyClassDic enumerateKeysAndObjectsUsingBlock:^(id key, ESClassInfo *subClassInfo, BOOL *stop) {
        [result addObject:subClassInfo];
        [result addObjectsFromArray: [self atClassArray:subClassInfo]];
    }];
    
    [classInfo.propertyArrayDic enumerateKeysAndObjectsUsingBlock:^(id key, ESClassInfo *subClassInfo, BOOL *stop) {
        [result addObject:subClassInfo];
        [result addObjectsFromArray:[self atClassArray:subClassInfo]];
    }];
    
    return [result copy];
}


/**
 *  解析.h文件内容--Objc
 *
 *  @param classInfo 类信息
 *
 *  @return
 */
+ (NSString *)parseClassHeaderContentForOjbcWithClassInfo:(ESClassInfo *)classInfo{
    NSMutableString *result = [NSMutableString stringWithFormat:@"@interface %@ : JSONModel\n",classInfo.className];
    [result appendString:[self parsePropertyContentWithClassInfo:classInfo]];
    [result appendString:@"\n@end"];
    
    return [result copy];
}

/**
 *  格式化OC属性字符串
 *
 *  @param key       业务属性名
 *  @param value     JSON里面key对应的NSDiction或者NSArray
 *  @param classInfo 类信息
 *
 *  @return
 */
+ (NSString *)formatObjcWithKey:(NSString *)key value:(NSObject *)value classInfo:(ESClassInfo *)classInfo {
    NSString *qualifierStr = @"copy";
    NSString *typeStr = @"NSString";
    //转换key 为业务属性名
    NSString *businessKey = key;

    if (PreferencesModel.propertyBusinessPrefixEnable) {
        if (classInfo.mapDic && [classInfo.mapDic count] > 0) {
            businessKey = classInfo.mapDic[key];
        }
    }

    if ([value isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;", qualifierStr, typeStr, businessKey];
    } else if ([value isKindOfClass:[@(YES)class]]) {
        // the 'NSCFBoolean' is private subclass of 'NSNumber'
        qualifierStr = @"assign";
        typeStr = @"BOOL";
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ %@;", qualifierStr, typeStr, businessKey];
    } else if ([value isKindOfClass:[NSNumber class]]) {
        qualifierStr = @"assign";
        NSString *valueStr = [NSString stringWithFormat:@"%@", value];

        if ([valueStr rangeOfString:@"."].location != NSNotFound) {
            typeStr = @"CGFloat";
        } else {
            NSNumber *valueNumber = (NSNumber *)value;

            if ([valueNumber longValue] < 2147483648) {
                typeStr = @"NSInteger";
            } else {
                typeStr = @"long long";
            }
        }

        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ %@;", qualifierStr, typeStr, businessKey];
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)value;

        // May be 'NSString'，will crash
        NSString *genericTypeStr = @"";
        NSObject *firstObj = [array firstObject];

        if ([firstObj isKindOfClass:[NSDictionary class]]) {
            ESClassInfo *childInfo = classInfo.propertyArrayDic[key];
            genericTypeStr = [NSString stringWithFormat:@"<%@>", childInfo.className];
        } else if ([firstObj isKindOfClass:[NSString class]]) {
            genericTypeStr = @"<NSString *>";
        } else if ([firstObj isKindOfClass:[NSNumber class]]) {
            genericTypeStr = @"<NSNumber *>";
        }

        qualifierStr = @"strong";
        typeStr = @"NSArray";

        /**
         *  判断版本号
         */
        //        if ([ESJsonFormatSetting defaultSetting].useGeneric && [ESUtils isXcode7AndLater]) {
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@%@ *%@;", qualifierStr, typeStr, genericTypeStr,
                businessKey];
        //        }
        //        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,key];
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        qualifierStr = @"strong";
        ESClassInfo *childInfo = classInfo.propertyClassDic[key];
        typeStr = childInfo.className;

        if (!typeStr) {
            typeStr = [key capitalizedString];
        }

        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;", qualifierStr, typeStr, businessKey];
    }

    return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;", qualifierStr, typeStr, businessKey];
}

@end
