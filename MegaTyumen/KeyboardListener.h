//
//  KeyboardNotifications.h
//  buhg
//
//  Created by Yazhenskikh Stanislaw on 20.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyboardListener : NSObject

@property (nonatomic, unsafe_unretained) UIView *activeControl;
@property (nonatomic, unsafe_unretained) UIScrollView *scrollView;

- (id)initWithScrollView:(UIScrollView *)scrollView;
- (void)registerForKeyboardNotifications;
- (void)keyboardWasShown:(NSNotification*)aNotification;
- (void)keyboardWillBeHidden:(NSNotification*)aNotification;

@end
