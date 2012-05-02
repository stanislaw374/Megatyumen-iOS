//
//  KeyboardNotifications.m
//  buhg
//
//  Created by Yazhenskikh Stanislaw on 20.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "KeyboardListener.h"

@implementation KeyboardListener
@synthesize activeControl = _activeField;
@synthesize scrollView = _scrollView;

-(id)init {
    return [self initWithScrollView:nil];
}

-(id)initWithScrollView:(UIScrollView *)scrollView {
    self = [super init];
    if (self) {
        self.scrollView = scrollView;
        [self registerForKeyboardNotifications];
    }
    return self;
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.scrollView.frame;
    aRect.size.height -= kbSize.height;
    //NSLog(@"%lf %lf", self.activeControl.frame.origin.x, self.activeControl.frame.origin.y);
    if (!CGRectContainsRect(aRect, self.activeControl.frame)) { //!CGRectContainsPoint(aRect, self.activeControl.frame.origin
        CGPoint scrollPoint = CGPointMake(0.0, self.activeControl.frame.origin.y + self.activeControl.frame.size.height - kbSize.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
    //NSLog(@"%@", NSStringFromSelector(_cmd));
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    //NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end
