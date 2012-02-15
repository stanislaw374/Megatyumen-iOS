//
//  CheckinCatalogView.h
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 04.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Catalog.h"
#import "MBProgressHUD.h"
#import "MainMenu.h"

@interface CheckinCatalogView : UIViewController <UISearchBarDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableViewCell *cell;
@property (nonatomic) BOOL isFeedbackMode;

- (void)getCatalog;

@end
