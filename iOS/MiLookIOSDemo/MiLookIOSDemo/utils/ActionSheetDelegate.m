//
//  ActionSheetDelegate.m
//
//  Created by Joshua Caswell on 12/5/11.
// 
// To the extent possible under law, the author has dedicated all
// copyright and related and neighboring rights to this software to 
// the public domain worldwide. This software is distributed without
// any warranty.
// See License.txt for details.

#import "ActionSheetDelegate.h"
#import <objc/runtime.h>

#define SAFE_BLOCK_INVOKE(b,...) ((b) ? (b)(__VA_ARGS__) : 0)

@implementation ActionSheetDelegate

+ (id)delegateWithHandler: (ButtonClickedHandler)newHandler 
{
    return [[self alloc] initWithHandler:newHandler];
}

- (id)initWithHandler: (ButtonClickedHandler)newHandler 
{ 
    self = [super init];
    if( !self ) return nil;
    
    _handler = [newHandler copy];
    
    return self;
}

static char sheet_key;
- (void)associateSelfWithSheet: (UIActionSheet *)sheet 
{
    // Tie delegate's lifetime to that of the action sheet
    objc_setAssociatedObject(sheet, &sheet_key, self, OBJC_ASSOCIATION_RETAIN);
}

//MARK: -
//MARK: UIActionSheetDelegate methods

- (void)actionSheet: (UIActionSheet *)actionSheet 
  clickedButtonAtIndex: (NSInteger)buttonIndex 
{
    SAFE_BLOCK_INVOKE(_handler, actionSheet, buttonIndex);
}

@end
