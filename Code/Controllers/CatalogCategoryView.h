//
//  CatalogSubcategoryView.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 14.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CatalogCategory.h"
#import "Catalog.h"
#import "MBProgressHUD.h"
#import "MainMenu.h"
#import "CatalogView.h"

@interface CatalogCategoryView : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *redImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *headerLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnType;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnCuisine;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnBill;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnNearby;

@property (nonatomic, strong) NSDictionary *type;

@property (nonatomic, unsafe_unretained) CatalogView *parentCatalogView;

- (IBAction)onRefreshButtonClick;
- (IBAction)onButtonClick:(id)sender;

@end
