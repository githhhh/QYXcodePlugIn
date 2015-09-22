//
//  NSString+Extensions.h
//  PropertyParser
//
//  Created by marko.hlebar on 7/20/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extensions)
- (BOOL)mh_containsString:(NSString *)string;
- (NSString *)mh_stringByRemovingWhitespacesAndNewlines;
- (BOOL)mh_isAlphaNumeric;
- (BOOL)mh_isWhitespaceOrNewline;

/**
 *  正则或字符串匹配
 *
 *  @param regex regex description
 *
 *  @return return NSTextCheckingResult数组
 */
-(NSArray *)matcheStrWith:(NSString *)regex;
/**
 *  返回匹配到组的内容
 *
 *  @param regex regex description
 *
 *  @return return 匹配到每个组的内容数组
 */
-(NSArray *)matcheGroupWith:(NSString *)regex;
@end
