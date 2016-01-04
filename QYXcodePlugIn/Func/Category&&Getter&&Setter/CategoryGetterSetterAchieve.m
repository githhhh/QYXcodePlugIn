//
//  CategoryGetterSetterAchieve.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/12/16.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "CategoryGetterSetterAchieve.h"
#import "Promise.h"
#import "MHXcodeDocumentNavigator.h"
#import "AutoGetterAchieve.h"
#import "NSString+Extensions.h"
#import "QYClangFormat.h"

static const NSString * machsStr = @"static\\s+char\\s+const\\s+\\*\\s*const\\s+\\w*\\s*=\\s*\"\\w*\";{1}";

@interface CategoryGetterSetterAchieve()

@property (nonatomic,retain) LAFIDESourceCodeEditor *editor;

@property (nonatomic,retain) NSDictionary *charDefMathcheDic;

@property (nonatomic,assign) BOOL isHeaderFile;

@property (nonatomic,copy) NSString *currentSource;

@property (nonatomic,copy) NSString *currentImpleMentationPath;

@end

@implementation CategoryGetterSetterAchieve


-(void)createCategoryGetterSetterAction{

    self.isHeaderFile = [[MHXcodeDocumentNavigator currentFilePath] isHeaderFilePath];

    PMKPromise *promiseStr = [self promiseAllMethodStr];
    PMKPromise *promiseInserLoc =  [AutoGetterAchieve promiseInsertLoction];
    
    NSDictionary *promiseDic = @{@"appendStrDic":promiseStr,@"rang":promiseInserLoc};

    [PMKPromise when:promiseDic] .thenOn(dispatch_get_main_queue(),^id(NSDictionary *dic){
        //当前在.m 文件
        if (_isHeaderFile) {
            return dic;
        }
        NSDictionary *appendStrDic = dic[@"appendStrDic"];
        
        NSString *charDefStr = appendStrDic[@"charKeyDef"];
        NSString *methodStr  = appendStrDic[@"methodStr"];
        NSValue *endRangValue = dic[@"rang"];

        if (ArrIsEmpty(self.charDefMathcheDic)) {
            NSString *markStr = @"#pragma mark - Setter && Getter ";
            NSString *allStr = [NSString stringWithFormat:@"%@\n%@\n%@",markStr,charDefStr,methodStr];
            
            [self.editor.view insertText:allStr replacementRange:[endRangValue rangeValue]];
        }else {
            [self.editor.view insertText:methodStr replacementRange:[endRangValue rangeValue]];
            
            //替换charDefStr  去掉换行
            NSString *lastCharDefStr = [self.charDefMathcheDic[@"charDefStrArr"]  lastObject];
            NSString *replaceCharDefContent = [NSString stringWithFormat:@"%@\n%@",lastCharDefStr,charDefStr];
            NSRange charDefInsertRang = [self.editor.view.textStorage.string rangeOfString:lastCharDefStr];
            if (RangIsNotFound(charDefInsertRang))
                return  error(@"匹配charDef错误。。。", 0, nil);
            
            [self.editor.view insertText:replaceCharDefContent replacementRange:charDefInsertRang];
        }

        return  nil;
    }).thenOn(dispatch_get_global_queue(0, 0),^(NSDictionary *dic){
        //当前在.h 文件
        if (!_isHeaderFile) {
            return ;
        }
        NSDictionary *appendStrDic = dic[@"appendStrDic"];
        
        NSString *charDefStr = appendStrDic[@"charKeyDef"];
        NSString *methodStr  = appendStrDic[@"methodStr"];
        NSValue *endRangValue = dic[@"rang"];
        
        if (ArrIsEmpty(self.charDefMathcheDic)) {
            NSString *markStr = @"#pragma mark - Setter && Getter ";
            NSString *allStr = [NSString stringWithFormat:@"%@\n%@\n%@",markStr,charDefStr,methodStr];
            //替换
            self.currentSource = [self.currentSource stringByReplacingCharactersInRange:[endRangValue rangeValue] withString:allStr];
        }else{
            //替换methodStr
            self.currentSource = [self.currentSource stringByReplacingCharactersInRange:[endRangValue rangeValue] withString:methodStr];
            
            //替换charDefStr  去掉换行
            NSString *lastCharDefStr = [self.charDefMathcheDic[@"charDefStrArr"] lastObject];
            NSString *replaceCharDefContent = [NSString stringWithFormat:@"%@\n%@",lastCharDefStr,charDefStr];
            NSRange charDefInsertRang = [self.currentSource rangeOfString:lastCharDefStr];
            self.currentSource = [self.currentSource stringByReplacingCharactersInRange:charDefInsertRang withString:replaceCharDefContent];
        }
        
    }).thenOn(dispatch_get_main_queue(),^(){
        if (_isHeaderFile) {
            NSError *writeError;
            BOOL isWrite = [ self.currentSource writeToFile:self.currentImpleMentationPath atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
            if (writeError || !isWrite)
                @throw  error(@".m写入内容失败", 0, nil);
        }
        
        //判断、添加头文件   去重。。
        if (![self.editor hasImportedHeader:@"#import <objc/runtime.h>"])
            [self.editor importHeader:@"#import <objc/runtime.h>"];

    }).catchOn(dispatch_get_main_queue(),^(NSError *err){
    
        NSString *dominStr = dominWithError(err);
        [self.editor showAboveCaret:dominStr color:[NSColor yellowColor]];
        
    });
};


#pragma mark - 拼接

-(PMKPromise *)promiseAllMethodStr{
    
    PMKPromise *promise =
    
    [self promiseSource].thenOn(dispatch_get_global_queue(0, 0),^id(NSString *source,NSString *seleteText){
        
        //匹配已经定义的charDef
        self.charDefMathcheDic = [self matchCharDefStrDic:source];
        
        //解析选中内容
        NSArray *ppArr = [AutoGetterAchieve MatcheSelectText:seleteText];
        if (ArrIsEmpty(ppArr))
            return error(@"解析选中内容失败。。", 0, nil);
        
        return [self appendCharDefWithPropertyArr:ppArr];;
    });
    
    return promise;
}


#pragma mark - main_queue 获取当前.m 文件内容 和 选择内容

-(PMKPromise *)promiseSource{
    
    PMKPromise *sourcePromise =
    
    dispatch_promise_on(dispatch_get_main_queue(), ^id(){
        
        self.currentSource = self.editor.view.textStorage.string;
        
        if (self.isHeaderFile) {
            NSError *readError;
            NSString *soureString = [NSString stringWithContentsOfFile:self.currentImpleMentationPath encoding:NSUTF8StringEncoding error:&readError];
            if (readError)
                return  readError;
            self.currentSource = soureString;
        }
        
        if ( IsEmpty(self.editor.selectedText))
            return error(@"选中内容为空。。", 0, nil);
        
        return PMKManifold(self.currentSource,self.editor.selectedText);
    });
    
    return sourcePromise;
}


#pragma mark - private Methode

-(NSDictionary *)matchCharDefStrDic:(NSString *)contentSource{
    
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableArray *charKeyArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *charDefStrArr = [NSMutableArray arrayWithCapacity:0];
    NSArray *matchArr = [contentSource matcheGroupWith:@"static\\s+char\\s+const\\s+\\*\\s*const\\s+(\\w+)\\s*=\\s*\"\\w*\";{1}"];
    if (!ArrIsEmpty(matchArr)) {
        NSInteger groupCount = [matchArr count]/2;
        
        for (NSInteger i = 0; i < groupCount; i++) {
            NSInteger charDefIndex = i*2;
            NSInteger charKeyIndex = charDefIndex + 1;
            NSString *key = matchArr[charKeyIndex];
            key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            [charDefStrArr addObject:matchArr[charDefIndex]];
            [charKeyArr addObject:key];
        }
        
        [mDic setObject:charDefStrArr forKey:@"charDefStrArr"];
        [mDic setObject:charKeyArr forKey:@"charKeyArr"];
    }
    

    return mDic;
}


-(NSDictionary  *)appendCharDefWithPropertyArr:(NSArray *)ppArr {
    
    NSMutableString *allCharKeyDef = [NSMutableString stringWithCapacity:0];
    NSMutableString *allMethodsStr = [NSMutableString stringWithCapacity:0];
    
    [ppArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        NSDictionary *ppDic = ppArr[idx];
        NSString *key = [NSString stringWithFormat:@"%@",[ppDic allKeys][0]] ;
        NSString *value = ppDic[key];
        
        //char key
        NSString *charKey = [NSString stringWithFormat:@"k%@",[value capitalizedString]];
        charKey = [charKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        NSString *charKeyDef = [NSString stringWithFormat:@"static char const * const %@  = \"%@\";\n",charKey,value];
        
        if (!ArrIsEmpty(self.charDefMathcheDic) && [self.charDefMathcheDic[@"charKeyArr"] containsObject:charKey]) {
            return ;
        }
        
        NSString *methodStr = [self appendMethodStrWithKeyType:key andVarName:value];
        
        [allMethodsStr appendString:methodStr];
        [allCharKeyDef appendString:charKeyDef];
    }];
    //全部重复
    if ( IsEmpty(allMethodsStr)&& IsEmpty(allCharKeyDef))
        @throw error(@"选中内容已经有了哦。。。", 100, nil);
    
    [allMethodsStr appendString:@"\n\n@end"];
    
    return  @{@"charKeyDef":allCharKeyDef,@"methodStr":allMethodsStr};
}


-(NSString *)appendMethodStrWithKeyType:(NSString *)key andVarName:(NSString *)value{
    
    key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    BOOL isObj = [key mh_containsString:@"*"];
    //Retain / Copy / Assign
    NSString *propertyAttr = @"OBJC_ASSOCIATION_RETAIN_NONATOMIC";
    if (!isObj) {
        propertyAttr = @"OBJC_ASSOCIATION_ASSIGN";
    }else{
       NSString *classNameStr =  [key substringToIndex:key.length - 1];
        classNameStr = [classNameStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if ([classNameStr isEqualToString:@"NSString"]) {
            propertyAttr = @"OBJC_ASSOCIATION_COPY_NONATOMIC";
        }
    }
    
    NSString *charKey = [NSString stringWithFormat:@"k%@",[value capitalizedString]];
    //Setter
    NSString *setterBody = [NSString stringWithFormat:@" objc_setAssociatedObject(self, &%@, %@, %@);",charKey,value,propertyAttr];
    if (!isObj)
        setterBody = [NSString stringWithFormat:@" objc_setAssociatedObject(self, &%@, @(%@), %@);",charKey,value,propertyAttr];
    
    NSString *setterStr = [NSString stringWithFormat:@"- (void)set%@:(%@)%@{\n  %@  \n}\n",[value capitalizedString],key,value,setterBody];
    
    //Getter
    NSString *getterBody = [NSString stringWithFormat:@"  return objc_getAssociatedObject(self, &%@);",charKey];
    if (!isObj) {
        
        if ( [key isEqual:@"NSInteger"]) {
            getterBody = [NSString stringWithFormat:@"  return [objc_getAssociatedObject(self, &%@) integerValue];",charKey];
            
        }else if ([key isEqualToString:@"BOOL"]){
            getterBody = [NSString stringWithFormat:@"  return [objc_getAssociatedObject(self, &%@) boolValue];",charKey];
        }else if ([key isEqualToString:@"CGFloat"]){
            getterBody = [NSString stringWithFormat:@"  return [objc_getAssociatedObject(self, &%@) floatValue];",charKey];
        }else if ([key isEqualToString:@"NSRange"]){
            getterBody = [NSString stringWithFormat:@"  return [objc_getAssociatedObject(self, &%@) rangeValue];",charKey];
        }
        //other
        
    }
    NSString *getterStr = [NSString stringWithFormat:@"- (%@)%@{\n %@ \n}\n",key,value,getterBody];
    
    return  [NSString stringWithFormat:@"%@\n%@",setterStr,getterStr];
}


#pragma mark - Getter

- (NSString *)currentImpleMentationPath
{
    if (!_currentImpleMentationPath) {
        NSString *sourceFilePath = [MHXcodeDocumentNavigator currentFilePath];
        //.m path
        sourceFilePath = [sourceFilePath stringByReplacingCharactersInRange:NSMakeRange(sourceFilePath.length - 1, 1)
                                                                 withString:@"m"];
        
        _currentImpleMentationPath = sourceFilePath;
    }
    return _currentImpleMentationPath;
}


-(LAFIDESourceCodeEditor *)editor{
    if (!_editor) {
        _editor = [[LAFIDESourceCodeEditor alloc] init];
    }
    return _editor;
}

@end
