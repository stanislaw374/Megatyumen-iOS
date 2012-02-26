//
//  AuthorizationView.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 18.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardListener.h"
#import "MBProgressHUD.h"
#import "RegistrationView.h"
#import "RemindPasswordView.h"

@interface AuthorizationView : UIViewController <UITableViewDataSource, UITextFieldDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *registerButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textField;

- (IBAction)onEnterButtonClick;
- (IBAction)onForgotPasswordButtonClick;
- (IBAction)onRegisterButtonClick;
//- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)onBgClick:(id)sender;

@end
