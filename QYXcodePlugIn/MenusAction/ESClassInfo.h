//
//  ESClassInfo.h
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/28.
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESClassInfo : NSObject
/**
 *  实体类的类名
 */
@property (nonatomic, copy) NSString *className;
/**
 *  当前类在JSON里面对应的key
 */
@property (nonatomic, copy) NSString *classNameKey;
/**
 *  当前类对应的字典(接口定义的)
 */
@property (nonatomic, strong) NSDictionary *classDic;
/**
 *  当前类的业务前缀
 */
@property (nonatomic, copy) NSString *businessPrefix;
/**
 *  业务属性名和接口返回字段对应关系
 */
@property (nonatomic, strong) NSDictionary *mapDic;
/**
 *  当前类里面属性对应为类的字典 [key->JSON字段的key : value->ESClassInfo对象]
 */
@property (nonatomic, strong) NSMutableDictionary *propertyClassDic;
/**
 *  当前类里属性对应为集合(指定集合里面存某个模型，用作MJExtension) [key->JSON字段的key : value->ESClassInfo对象]
 */
@property (nonatomic, strong) NSMutableDictionary *propertyArrayDic;



- (instancetype)initWithClassNameKey:(NSString *)classNameKey ClassName:(NSString *)className classDic:(NSDictionary *)classDic;

@end

