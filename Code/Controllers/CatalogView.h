//
//  CatalogView.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 13.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "MainMenu.h"
#import <CoreLocation/CoreLocation.h>

@interface CatalogView : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UISearchBar *searchBar;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
//@property (strong, nonatomic) IBOutlet UITableViewCell *cell;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *checkinLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *checkinButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *borderButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnType;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnCuisine;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnBill;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnNearby;

- (IBAction)onButtonClick:(id)sender;
- (void)onCatalogCategoryButtonClick:(id)sender;
- (IBAction)onCheckinButtonClick;

- (IBAction)onTypeButtonClick;
- (IBAction)onCuisineButtonClick;
- (IBAction)onBillButtonClick;
- (IBAction)onNearbyButtonClick;

@end
