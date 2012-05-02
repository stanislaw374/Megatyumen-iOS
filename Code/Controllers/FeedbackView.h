//
//  FeedbackView.h
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainMenu.h"
#import "MBProgressHUD.h"

@interface FeedbackView : UIViewController <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    BOOL _isLoading;
}
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnAddFeedback;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *borderView;

- (IBAction)onFeedbackButtonClick;

@end
