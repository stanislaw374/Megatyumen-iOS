//
//  RegistrationView.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 18.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardListener.h"
#import "MBProgressHUD.h"
#import "AuthorizationView.h"

@interface RegistrationView : UIViewController <UITableViewDataSource, UITextFieldDelegate>

//@property (unsafe_unretained, nonatomic) AuthorizationView *authorizationView;

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;

//- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)onRegisterButtonClick;
- (IBAction)onReadUserAgreementButtonClick;

@end
