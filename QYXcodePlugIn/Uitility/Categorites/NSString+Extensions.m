//
//  NSString+Extensions.m
//  PropertyParser
//
//  Created by marko.hlebar on 7/20/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)
- (BOOL)mh_containsString:(NSString *)string {
	return [self rangeOfString:string].location != NSNotFound;
}

- (NSString *)mh_stringByRemovingWhitespacesAndNewlines {
	NSString *string = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
	return [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

- (BOOL)mh_isAlphaNumeric {
	NSCharacterSet *unwantedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
	return [self rangeOfCharacterFromSet:unwantedCharacters].location == NSNotFound;
}

- (BOOL)mh_isWhitespaceOrNewline {
	NSString *string = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
	string = [self stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	return string.length == 0;
}



-(NSArray *)matcheStrWith:(NSString *)regex error:(NSError **)error{
    if (IsEmpty(regex)||IsEmpty(self)) {
        return nil;
    }
    
    
    NSError *matchError;
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex
                                                                             options:NSRegularExpressionCaseInsensitive
                                                                               error:&matchError];
    if (matchError) {
        *error = matchError;
        return nil;
    }
    // 对str字符串进行匹配
    NSArray *matches = [regular matchesInString:self
                                        options:0
                                          range:NSMakeRange(0, self.length)];
    return matches;
}


-(NSArray *)matcheGroupWith:(NSString *)regex error:(NSError **)error{
    if (IsEmpty(regex)||IsEmpty(self))
        return nil;
    
    NSMutableArray *groupContentArr = [NSMutableArray arrayWithCapacity:0];
    NSError *matchError;
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex
                                                                             options:NSRegularExpressionCaseInsensitive
                                                                               error:&matchError];
    
    // 对str字符串进行匹配
    NSArray *matches = [regular matchesInString:self
                                        options:0
                                          range:NSMakeRange(0, self.length)];
    if (matchError) {
        *error = matchError;
        return nil;
    }
    if (ArrIsEmpty(matches))
        return nil;
    
    // 遍历匹配后的每一条记录
    for (NSTextCheckingResult *match in matches) {
        for (int i = 0;i<match.numberOfRanges;i++) {
            NSRange range = [match rangeAtIndex:i];
            NSString *mStr = (NSString *)[self substringWithRange:range];
            [groupContentArr addObject:mStr];
        }
    }
    
    return groupContentArr;
}


/**
 *  首字母转大写
 *
 *  @return return value description
 */
- (NSString *)mh_capitalizedString{
    if (IsEmpty(self)) {
        return self;
    }
    if (self.length == 1) {
        return [self capitalizedString];
    }
    NSString *firstChar = [self substringWithRange:NSMakeRange(0, 1)];
    firstChar = [firstChar uppercaseString];
    
    NSString *capStr = [self stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstChar];
    
    return capStr;
}

@end
