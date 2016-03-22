//
//  TestWindowController.m
//  ESJsonFormat
//
//  Created by 尹桥印 on 15/6/19.
//  Modefied by 唐斌
//  Copyright (c) 2015年 EnjoySR. All rights reserved.
//

#import "ESInputJsonController.h"
#import "ESDialogController.h"
#import "ESClassInfo.h"
#import "Promise.h"
#import "MHXcodeDocumentNavigator.h"
#import "QYAutoModelHelper.h"
#import "NSString+Extensions.h"
#import "QYIDENotificationHandler.h"
#import "QYClangFormat.h"
#import "NSString+Files.h"

#define validatorErrorCode 110

@interface ESInputJsonController ()<NSTextViewDelegate,NSWindowDelegate,NSTextFieldDelegate>

@property (unsafe_unretained) IBOutlet NSTextView *inputTextView;

@property (weak) IBOutlet NSButton *enterButton;

@property (weak) IBOutlet NSButton *cancelButton;

@property (weak) IBOutlet NSScrollView *scrollView;

@property (weak) IBOutlet NSTextField *propertyPrefixField;

@property (weak) IBOutlet NSLayoutConstraint *configPrefixViewTopConstraint;

@property (weak) IBOutlet NSLayoutConstraint *scrollViewTopConstraint;

@property (nonatomic,retain) ESClassInfo  *classInfo;

@property (nonatomic,assign) BOOL isCatchedError;
@end

@implementation ESInputJsonController

#pragma mark - Window Life cycle

-(void)dealloc{
    _inputTextView.delegate = nil;
    _inputTextView = nil;
    
    _propertyPrefixField.delegate = nil;
    _propertyPrefixField = nil;
    
    LOG(@"====ESInputJsonController=====dealloc=");
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.inputTextView.delegate = self;
    self.propertyPrefixField.delegate = self;
    self.window.delegate = self;
    
    
    if (!PreferencesModel.propertyBusinessPrefixEnable) {
        NSString *rootClassName = [self.currentImpleMentationPath currentClassName];
        self.propertyPrefixField.stringValue = [rootClassName lowercaseString];
        
        self.configPrefixViewTopConstraint.constant = 0;
        self.scrollViewTopConstraint.constant = 52;
        [self.window.contentView updateConstraints];
    }
    /**
     *  将window置顶
     */
    [[self window] setLevel: kCGStatusWindowLevel];
}

#pragma mark - xib Action

- (IBAction)cancelButtonClick:(NSButton *)sender {
    [self closeWindown];
}

- (IBAction)enterButtonClick:(NSButton *)sender {
    self.isCatchedError = NO;

    [self dictionaryWithJsonStr:self.inputTextView.string].thenOn(dispatch_get_main_queue(), ^id(id result){
        
        NSString *rootClassName = [self.currentImpleMentationPath currentClassName];
        
        if (!PreferencesModel.propertyBusinessPrefixEnable) {
            self.classInfo = [[ESClassInfo alloc] initWithClassNameKey:self.propertyPrefixField.stringValue ClassName:rootClassName classDic:result];
        }else {
            self.classInfo = [[ESClassInfo alloc] initWithClassNameKey:[rootClassName lowercaseString] ClassName:rootClassName classDic:result];
        }
        //递归
        [self dealPropertyNameWithClassInfo:self.classInfo];
        
        return  self.editorView.string;
        
    }).thenOn(dispatch_get_global_queue(0, 0),^id(NSString *hContent){
    
        // 拼接 属性
        NSString *atClassContent = [QYAutoModelHelper atClassContent:self.classInfo];
        NSString *protocolContent = [QYAutoModelHelper protocolsClassContent:self.classInfo];
        NSString *classOrProtocolDefineContent = [NSString stringWithFormat:@"%@ \n %@",protocolContent,atClassContent];
        
        NSString *propertyContent = [QYAutoModelHelper parsePropertyContentWithClassInfo:self.classInfo];
        propertyContent = [propertyContent stringByAppendingString:@"\n@end\n\n"];
        
        NSString *subClassContent = [QYAutoModelHelper subClassContentForH:self.classInfo];
        
        // 拼接 .m 内容
        NSString *contentAppend = [propertyContent stringByAppendingString:subClassContent];
        /**
         *  匹配@end,获取@end 位置
         */
        NSError *matchError;
        NSArray *endMatches = [hContent matcheStrWith:@"\n@end" error:&matchError];
        if (matchError||[endMatches count]>1)
            return matchError;
        NSRange endRange =  [endMatches[0] range];
        
        /**
         *  匹配@interface
         */
        NSRange atInsertRange = [hContent rangeOfString:@"\n@interface"];
        if (RangIsNotFound(atInsertRange) || RangIsNotFound(endRange)) {
            return error(@"获取替换位置失败！", 0, nil);
        }
        
        //替换@end
        hContent = [hContent stringByReplacingCharactersInRange:endRange withString:contentAppend];
        
        //替换@interface
        hContent = [hContent stringByReplacingCharactersInRange:NSMakeRange(atInsertRange.location, 0) withString:[NSString stringWithFormat:@"%@",classOrProtocolDefineContent]];
        

        return  hContent;
    }).thenOn(dispatch_get_main_queue(),^(NSString *hContent){
    
        //替换头文件
        [self.editorView insertText:hContent replacementRange:NSMakeRange(0, self.editorView.string.length)];
        
    }).thenOn(dispatch_get_global_queue(0, 0),^id{
        NSError *readError;
        NSString *mContent = [NSString stringWithContentsOfFile:self.currentImpleMentationPath encoding:NSUTF8StringEncoding error:&readError];
        if (readError)
            return readError;

        NSString *implementateContent = [QYAutoModelHelper jsonMapContentOfClassInfo:self.classInfo];
        implementateContent = [implementateContent stringByAppendingString:@"\n@end\n\n"];
        
        NSString *subClassImplementateContent = [QYAutoModelHelper subClassImplementateContentForM:self.classInfo];

        implementateContent = [implementateContent stringByAppendingString:subClassImplementateContent];
        /**
         *  匹配@end,获取@end 位置
         */
        NSError *matchError;
        NSArray *endMatches = [mContent matcheStrWith:@"\n@end" error:&matchError];
        if (matchError||[endMatches count]>1)
            return matchError;
        NSRange endRange =  [endMatches[0] range];
        if (RangIsNotFound(endRange))
            return error(@"获取替换位置失败！", 0, nil);
        
        //替换@end
        mContent = [mContent stringByReplacingCharactersInRange:endRange withString:implementateContent];
        
        return [QYClangFormat promiseClangFormatSourceCode:mContent];
        
    }).thenOn(dispatch_get_main_queue(),^id(NSString *mContent){
    
        //写入.m文件
        NSError *writeError;
        
       BOOL isWrite = [mContent writeToFile:self.currentImpleMentationPath atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
       
        if (writeError||isWrite)
            return writeError;
        
        return nil;
        
    }).catchOn(dispatch_get_main_queue(),^(NSError *err){
       //报告错误
        NSString *dominStr = dominWithError(err);

        if (err.code == validatorErrorCode) {
            /**
             *  验证错误
             */
            self.isCatchedError = YES;
            self.window.title = dominStr;
            return ;
        }
        /**
         *  其它逻辑内部错误
         */
        [self closeWindown];
        [LAFIDESourceCodeEditor showAboveCaretOnCenter:dominStr color:[NSColor yellowColor]];
        
    }).finallyOn(dispatch_get_main_queue(),^{
        
        if (!self.isCatchedError)
            [self closeWindown];
        
    });
    
}



#pragma mark - Private Methode

-(void)closeWindown{
    [super close];
    if (self.delegate && [self.delegate respondsToSelector:@selector(windowDidClose)]) {
        [self.delegate windowDidClose];
    }
}


/**
 *  检查是否是一个有效的JSON
 */
-(PMKPromise *)dictionaryWithJsonStr:(NSString *)jsonString{
    __block NSString *jsonStr = [jsonString copy];
   PMKPromise *validatorPromise =  dispatch_promise_on(dispatch_get_global_queue(0, 0), ^id{
    
        jsonStr = [[jsonStr stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
        LOG(@"jsonString=%@",jsonStr);
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        id dicOrArray = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
        if (err)
            return error(@"输入JSON 格式不对哦。。。", validatorErrorCode, nil);
        //默认为解析所有JSON
        if (!PreferencesModel.isDefaultAllJSON)
            return dicOrArray;
        
        if ([dicOrArray isKindOfClass:[NSDictionary class]]) {
            NSDictionary *allJsonDic = dicOrArray;
            if ([[allJsonDic allKeys] containsObject:PreferencesModel.contentJSONKey]) {
                id jsonContent = allJsonDic[PreferencesModel.contentJSONKey];
                if ([jsonContent isKindOfClass:[NSArray class]]) {
                    
                    NSArray *classArr = jsonContent;
                    if ([[classArr firstObject] isKindOfClass:[NSDictionary class]]) {
                        return [classArr firstObject];
                    }else{
                        NSString *errorInfo = [NSString stringWithFormat:@"无法解析指定Key 的JSON内容---%@",jsonContent];
                        return error(errorInfo, validatorErrorCode, nil);
                    }
                }
                return jsonContent;
            }
        }
        NSString *errorInfo = [NSString stringWithFormat:@"AutoModel无法再JSON 一级结构中找到指定需要解析的JSON key(%@)..去设置里修改一下呗。。",PreferencesModel.contentJSONKey];
        return error(errorInfo, validatorErrorCode, nil);
    });
    
    return validatorPromise;
}


/**
 *  处理属性名字(用户输入属性对应字典对应类或者集合里面对应类的名字)
 *
 *  @param classInfo 要处理的ClassInfo
 *
 *  @return 处理完毕的ClassInfo
 */
- (ESClassInfo *)dealPropertyNameWithClassInfo:(ESClassInfo *)classInfo{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:classInfo.classDic];
    
    //获取当前classInfo 的 mapDic
    NSMutableDictionary *currentMapDic = [NSMutableDictionary dictionaryWithCapacity:0];
    for (NSString *key in dic) {
        //获取业务key
        NSString *businessKey = [[classInfo.businessPrefix lowercaseString] stringByAppendingString:[key capitalizedString]];
        [currentMapDic setObject:businessKey forKey:key];
        
        //取出的可能是NSDictionary或者NSArray
        id obj = dic[key];
        if (![obj isKindOfClass:[NSArray class]] && ![obj isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        ESDialogController *dialog = [[ESDialogController alloc] initWithWindowNibName:@"ESDialogController"];
        dialog.prefixName =  key;
        
        NSString *msg = [NSString stringWithFormat:@"The '%@' correspond class name is:",key];
        if ([obj isKindOfClass:[NSArray class]]) {
            //May be 'NSString'，will crash
            if (!([[obj firstObject] isKindOfClass:[NSDictionary class]] || [[obj firstObject] isKindOfClass:[NSArray class]])) {
                continue;
            }
            msg = [NSString stringWithFormat:@"The '%@' child items class name is:",key];
        }
        __block NSString *childClassName;//Record the current class name
        __block NSString *childPreFixName ;//Record the current preFix name
        [dialog setDataWithMsg:msg defaultClassName:[key capitalizedString] classNameBlock:^(NSString *className) {
            
            childClassName = className;
            
        } prefixBlock:^(NSString *prefixName) {
            
            childPreFixName = prefixName;
        }];
        
        [[NSApp mainWindow] beginSheet:[dialog window] completionHandler:nil];
        [NSApp runModalForWindow:[dialog window]];
        
        
        //如果当前obj是 NSDictionary 或者 NSArray，继续向下遍历
        if ([obj isKindOfClass:[NSDictionary class]]) {
            ESClassInfo *childClassInfo = [[ESClassInfo alloc] initWithClassNameKey:key ClassName:childClassName classDic:obj];
            childClassInfo.businessPrefix = IsEmpty(childPreFixName)?childClassName:childPreFixName;
            
            [self dealPropertyNameWithClassInfo:childClassInfo];
            
            //设置classInfo里面属性对应class
            [classInfo.propertyClassDic setObject:childClassInfo forKey:key];
            
        }else if([obj isKindOfClass:[NSArray class]]){
            //如果是 NSArray 取出第一个元素向下遍历
            NSArray *array = obj;
            
            //May be 'NSString'，will crash
            if ( !array.firstObject || ![[array firstObject] isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            ESClassInfo *childClassInfo = [[ESClassInfo alloc] initWithClassNameKey:key ClassName:childClassName classDic:[array firstObject]];
            childClassInfo.businessPrefix = IsEmpty(childPreFixName)?childClassName:childPreFixName;
            
            [self dealPropertyNameWithClassInfo:childClassInfo];
            //设置classInfo里面属性类型为 NSArray 情况下，NSArray 内部元素类型的对应的class
            [classInfo.propertyArrayDic setObject:childClassInfo forKey:key];
        }
        
    }
    /**
     *  设置当前mapDic
     */
    classInfo.mapDic = currentMapDic;
    
    return classInfo;
}

#pragma mark - NSTextfiledDelegate

-(void)controlTextDidEndEditing:(NSNotification *)notification{
    if ( [[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement){
        [self enterButtonClick:self.enterButton];
    }
}

#pragma mark - NSTextViewDelegate

-(void)textDidChange:(NSNotification *)notification{
    NSTextView *textView = notification.object;
    
    [self dictionaryWithJsonStr:textView.string].thenOn(dispatch_get_main_queue(), ^{
    
        //如果通过验证,属性业务前缀textField 获得焦点
        if (!PreferencesModel.propertyBusinessPrefixEnable) {
            [self.propertyPrefixField becomeFirstResponder];
        }
        
        self.window.title = @"Good Job...";

    }).catchOn(dispatch_get_main_queue(),^(NSError *er){
        //报告错误
        NSString *dominStr = dominWithError(er);
        self.window.title = dominStr;
    });
}


@end
