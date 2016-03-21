//
//  QYPreferencesModel.h
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/12/22.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYPreferencesModel : NSObject<NSCoding>

#pragma mark - AutoGetter
/**
 *  配置AutoGetter 的JSON
 */
@property (nonatomic, copy  ) NSString *getterJSON;

#pragma mark - RequestValidator
/**
 *  请求文件的基类名
 */
@property (nonatomic, copy  ) NSString *requestClassBaseName;
/**
 *  是否创建测试方法
 */
@property (nonatomic, assign) BOOL     isCreatTestMethod;
/**
 *  测试方法名称
 */
@property (nonatomic, copy  ) NSString *testMethodName;
/**
 *  校验方法名称
 */
@property (nonatomic, copy  ) NSString *requestValidatorMethodName;

#pragma mark - ClearCalalogSearchTitle
/**
 *  是否始终清空图片列表上一次的搜索条件。
 */
@property (nonatomic, assign) BOOL     isClearCalalogSearchTitle;

#pragma mark - PromptException
/**
 *  是否提醒异常
 */
@property (nonatomic, assign) BOOL     isPromptException;

#pragma mark - AutoModel
/**
 *  忽略大小写,默认启用
 */
@property (nonatomic,assign) BOOL isPropertyIsOptional;
/**
 *  属性业务前缀,默认启用
 */
@property (nonatomic,assign) BOOL propertyBusinessPrefixEnable;
/**
 *  默认为空,即解析所以JSON内容。或者指定JSONKey 对应内容。
 */
@property (nonatomic,copy) NSString *contentJSONKey;
/**
 *  是否默认解析整个JSON
 */
@property (nonatomic,assign) BOOL isDefaultAllJSON;

@end