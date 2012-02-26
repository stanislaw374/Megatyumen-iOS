//
//  RemindPasswordView.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 18.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class KeyboardListener;

@interface RemindPasswordView : UIViewController <UITableViewDataSource, UITextFieldDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textField;

- (IBAction)onRestorePasswordButtonClick;
- (IBAction)onBgClick:(id)sender;

@end
