//
//  CheckinView.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 13.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CatalogItem.h"
#import "MBProgressHUD.h"
#import "MainMenu.h"
#import "Company.h"

@interface CheckinView : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) Company *company;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *feedBackTextView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnPositive;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnNeutral;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnNegative;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnCheckin;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnAddFeedback;
@property (nonatomic) BOOL isFeedbackMode;

- (IBAction)onPositiveButtonClick;
- (IBAction)onNeutralButtonClick;
- (IBAction)onNegativeButtonClick;
- (IBAction)onCheckinButtonClick;
- (IBAction)onAddFeedbackButtonClick;
- (IBAction)onBgClick:(id)sender;

@end
