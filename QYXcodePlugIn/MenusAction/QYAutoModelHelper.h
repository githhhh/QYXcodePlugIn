//
//  QYAutoModelHelper.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 16/3/18.
//  Copyright © 2016年 X.Y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESClassInfo.h"

@interface QYAutoModelHelper : NSObject

#pragma mark - 获取.h 内容

/**
 *  获取除主类外所有类名
 *
 *  @param classInfo classInfo description
 *
 *  @return 除主类外所有类名
 */
+ (NSString *)atClassContent:(ESClassInfo *)classInfo;

/**
 *  获取类的所有属性定义
 *
 *  @param classInfo classInfo description
 *
 *  @return 所有属性定义
 */
+ (NSString *)parsePropertyContentWithClassInfo:(ESClassInfo *)classInfo;

/**
 *  获取所有子类头文件内容
 *
 *  @param classInfo classInfo description
 *
 *  @return 所有子类头文件内容
 */
+ (NSString *)subClassContentForH:(ESClassInfo *)classInfo;


#pragma mark -  获取.m 内容

/**
 *  获取JSONModel 的Map 方法
 *
 *  @param classInfo classInfo description
 *
 *  @return return value description
 */
+ (NSString *)jsonMapContentOfClassInfo:(ESClassInfo *)classInfo;

/**
 *  获取所有子类的实现内容
 *
 *  @param classInfo classInfo description
 *
 *  @return 所有子类的实现内容
 */
+ (NSString *)subClassImplementateContentForM:(ESClassInfo *)classInfo;
@end
