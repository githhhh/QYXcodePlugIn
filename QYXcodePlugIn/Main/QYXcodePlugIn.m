//
//  QYXcodePlugIn.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/9/18.
//  Copyright (c) 2015年 X.Y. All rights reserved.
//

#import "QYXcodePlugIn.h"
#import "MenuItemAchieve.h"

static QYXcodePlugIn *sharedPlugin;

@interface QYXcodePlugIn()

@property (nonatomic, strong, readwrite) NSBundle *bundle;

@end

@implementation QYXcodePlugIn


+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[QYXcodePlugIn alloc] initWithBundle:plugin];
        });
    }
}


- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeSelecteText:) name:NSTextViewDidChangeSelectionNotification object:nil];

    }
    return self;
}

#pragma mark -
#pragma mark -  Xcode 启动
- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] init];
        [actionMenuItem setTitle:@"QYAction"];
        [[menuItem submenu] addItem:actionMenuItem];
        
        //添加子菜单
        [self addMenuOnQYActionMenu:actionMenuItem];
    }
}

- (void)didChangeSelecteText:(NSNotification *)noti{
    
    if ([[noti object] isKindOfClass:[NSTextView class]]) {
        NSTextView *textView = (NSTextView *)[noti object];
        
        NSArray *selectedRanges = [textView selectedRanges];
        
        if ([selectedRanges count]== 0) {
            return;
        }
        
        NSRange selectedRange = [[selectedRanges objectAtIndex:0] rangeValue];
        NSString *text = textView.textStorage.string;
        self.globlaParamter = [text substringWithRange:selectedRange];
    }

}


#pragma mark - 添加菜单
-(void)addMenuOnQYActionMenu:(NSMenuItem *)actionMenuItem{
    
    NSMenu *subMenu = [[NSMenu alloc] init];
    NSMenuItem*subItem = [subMenu addItemWithTitle:@"AutoGetter" action:@selector(itemAction:) keyEquivalent:@"F"];//热键 + 『F』
    //设置热键
    [subItem setKeyEquivalentModifierMask:NSControlKeyMask];
    [subItem setTarget:self];

    //分割线
    [subMenu insertItem:[NSMenuItem separatorItem] atIndex:1];
    
    
    NSMenuItem*subItem1 = [subMenu addItemWithTitle:@"RequestTemplate" action:@selector(itemAction:) keyEquivalent:@"D"];//热键 + 『D』
    //设置热键
    [subItem1 setKeyEquivalentModifierMask:NSControlKeyMask];
    [subItem1 setTarget:self];
    
    
    
    
    [actionMenuItem setSubmenu:subMenu];
}
#pragma mark -
#pragma mark - menuAction
/**
 *  根据选中的属性,自动生成getter方法。
 */
- (void)itemAction:(NSMenuItem *)item
{    
    id<QYMenuActionProtocol> achieve = [MenuItemAchieve createMenuActionResponse:item];
    [achieve menuItemAction:self.globlaParamter];
}














- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
