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
{
    int _companiesCount[5];
}
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL isFeedbackMode;
@property (unsafe_unretained, nonatomic) IBOutlet UISearchBar *searchBar;

@end
