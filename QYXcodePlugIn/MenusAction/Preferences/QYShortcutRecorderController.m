//
//  QYShortcutRecorderController.m
//  QYXcodePlugIn
//
//  Created by 唐斌 on 15/11/13.
//  Copyright © 2015年 X.Y. All rights reserved.
//

#import "QYShortcutRecorderController.h"

@interface QYShortcutRecorderController ()

@end

@implementation QYShortcutRecorderController {
    SRValidator *_validator;
}

- (void)dealloc { NSLog(@"======QYShortcutRecorderController========"); }


#pragma mark - sheet
- (IBAction)CloseSheet:(id)sender {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}


#pragma mark SRRecorderControlDelegate

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder canRecordShortcut:(NSDictionary *)aShortcut
{
    __autoreleasing NSError *error = nil;
    BOOL isTaken = [_validator isKeyCode:[aShortcut[SRShortcutKeyCode] unsignedShortValue]
                           andFlagsTaken:[aShortcut[SRShortcutModifierFlagsKey] unsignedIntegerValue]
                                   error:&error];
    
    if (isTaken) {
        NSBeep();
        [self presentError:error modalForWindow:self.window delegate:nil didPresentSelector:NULL contextInfo:NULL];
    }
    
    return !isTaken;
}

- (BOOL)shortcutRecorderShouldBeginRecording:(SRRecorderControl *)aRecorder
{
    [[PTHotKeyCenter sharedCenter] pause];
    return YES;
}

- (void)shortcutRecorderDidEndRecording:(SRRecorderControl *)aRecorder { [[PTHotKeyCenter sharedCenter] resume]; }

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder
shouldUnconditionallyAllowModifierFlags:(NSEventModifierFlags)aModifierFlags
              forKeyCode:(unsigned short)aKeyCode
{
    // Keep required flags required.
    if ((aModifierFlags & aRecorder.requiredModifierFlags) != aRecorder.requiredModifierFlags)
        return NO;
    
    // Don't allow disallowed flags.
    if ((aModifierFlags & aRecorder.allowedModifierFlags) != aModifierFlags)
        return NO;
    
    switch (aKeyCode) {
        case kVK_F1:
        case kVK_F2:
        case kVK_F3:
        case kVK_F4:
        case kVK_F5:
        case kVK_F6:
        case kVK_F7:
        case kVK_F8:
        case kVK_F9:
        case kVK_F10:
        case kVK_F11:
        case kVK_F12:
        case kVK_F13:
        case kVK_F14:
        case kVK_F15:
        case kVK_F16:
        case kVK_F17:
        case kVK_F18:
        case kVK_F19:
        case kVK_F20:
            return YES;
        default:
            return NO;
    }
}


#pragma mark SRValidatorDelegate

- (BOOL)shortcutValidator:(SRValidator *)aValidator
                isKeyCode:(unsigned short)aKeyCode
            andFlagsTaken:(NSEventModifierFlags)aFlags
                   reason:(NSString **)outReason
{
#define IS_TAKEN(aRecorder) (recorder != (aRecorder) && SRShortcutEqualToShortcut(shortcut, [(aRecorder)objectValue]))
    SRRecorderControl *recorder = (SRRecorderControl *)self.window.firstResponder;
    
    if (![recorder isKindOfClass:[SRRecorderControl class]])
        return NO;
    
    NSDictionary *shortcut = SRShortcutWithCocoaModifierFlagsAndKeyCode(aFlags, aKeyCode);
    
    if (IS_TAKEN(_agRecorderControl) || IS_TAKEN(_rvRecorderControl) || IS_TAKEN(_settingRecorderControl)) {
        *outReason = @"it's already used. To use this shortcut, first remove or change the other shortcut";
        return YES;
    } else
        return NO;
#undef IS_TAKEN
}

- (BOOL)shortcutValidatorShouldCheckMenu:(SRValidator *)aValidator { return YES; }


#pragma mark NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    _validator = [[SRValidator alloc] initWithDelegate:self];
    
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    
    
    [self.agRecorderControl bind:NSValueBinding toObject:defaults withKeyPath:AutoGetterMenuKeyPath options:nil];
    
    [self.amRecorderControl bind:NSValueBinding toObject:defaults withKeyPath:AutoModelMenuKeyPath options:nil];
    
    [self.rvRecorderControl bind:NSValueBinding toObject:defaults withKeyPath:RequestVerifiMenuKeyPath options:nil];
    
    [self.settingRecorderControl bind:NSValueBinding toObject:defaults withKeyPath:SettingsMenuKeyPath options:nil];
}


@end
