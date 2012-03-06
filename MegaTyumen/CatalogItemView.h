//
//  CatalogItemView.h
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 18.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CatalogItem.h"
#import "MBProgressHUD.h"
#import "CatalogCategoryView.h"
#import "CatalogCategory.h"
#import "MainMenu.h"

@interface CatalogItemView : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) CatalogItem *currentItem;

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *nameLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *addressLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *distanceButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnCommon;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnPhoto;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnMenu;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnFeedback;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnEvents;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnMap;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblType;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblPhone;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblAddress;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblWebsite;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblBusinessHours;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblAbout;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnCheckin;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblCheckin;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView0;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *borderButton0;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView1;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *borderButton1;
@property (strong, nonatomic) UIView *photosView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblPhotosCount;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView2;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *borderButton2;

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *menuCell;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnAddFeedback;
@property (strong, nonatomic) UIView *feedbackView;
@property (strong, nonatomic) IBOutlet UITableViewCell *eventCell;

@property (unsafe_unretained, nonatomic) CatalogCategoryView *parentCatalogCategoryView;
@property (unsafe_unretained, nonatomic) Catalog *catalog;

//- (void)didPassAuthorization:(NSNotification *)notification;

- (IBAction)onMenuButtonClick:(id)sender;
- (IBAction)onPhotoButtonClick:(id)sender;

- (IBAction)onCheckinButtonClick;
- (IBAction)onAddFeedbackButtonClick:(id)sender;

- (IBAction)onTypeButtonClick;
- (IBAction)onPhoneButtonClick;
- (IBAction)onAddressButtonClick;
- (IBAction)onWebsiteButtonClick;

@end
