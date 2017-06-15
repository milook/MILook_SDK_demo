//
// ActionSheetDelegate.h
//
// Created by Joshua Caswell on 12/5/11.
// 
// To the extent possible under law, the author has dedicated all
// copyright and related and neighboring rights to this software to 
// the public domain worldwide. This software is distributed without
// any warranty.
// See License.txt for details.

#import <UIKit/UIKit.h>

typedef void (^ButtonClickedHandler)(UIActionSheet *, NSInteger);

@interface ActionSheetDelegate : NSObject <UIActionSheetDelegate>

@property (copy, nonatomic) ButtonClickedHandler handler;

+ (id)delegateWithHandler: (ButtonClickedHandler)newHandler;

/* Uses objc_setAssociatedObject() to tie self to the passed-in sheet;
 * the delegate will therefore be released when the sheet is deallocated.
 * This obviates the need to keep a reference to the delegate in the scope
 * in which it was created.
 */
- (void)associateSelfWithSheet: (UIActionSheet *)sheet;

@end
