//
//  AddCommentView.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 29.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardListener.h"
#import "New.h"
#import "AuthorizationView.h"
#import "MBProgressHUD.h"
#import "MainMenu.h"

@interface AddCommentView : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (unsafe_unretained, nonatomic) New *currentNew;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)onAddCommentButtonClick;
//- (void)didPassAuthorization:(NSNotification *)notification;
//- (void)didAddComment:(NSNotification *)notification;

@end
