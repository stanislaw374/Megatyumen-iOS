//
//  CheckinItemView.h
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 05.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CatalogItem.h"
#import "CheckinView.h"
#import "MBProgressHUD.h"
#import "MainMenu.h"
#import "Company.h"
#import <CoreLocation/CoreLocation.h>

@interface CheckinItemView : UIViewController <UIWebViewDelegate>
{
    int timerCounter;
}
@property (nonatomic, strong) Company *company;
@property (nonatomic, strong) CLLocation *userLocation;

//@property (nonatomic, unsafe_unretained) CatalogItem *currentItem;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *nameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *addressLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *distanceButton;
//@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *descriptionWebView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *borderButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (unsafe_unretained, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *checkinButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *addFeedbackButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *checkinLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (nonatomic) BOOL isFeedbackMode;
@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *textWebView;

- (IBAction)onCheckinButtonClick;
- (IBAction)onAddFeedbackButtonClick;

@end
