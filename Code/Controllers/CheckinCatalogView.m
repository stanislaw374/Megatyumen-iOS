//
//  CheckinCatalogView.m
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 04.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
typedef enum { CATEGORY_TYPES, CATEGORY_CUISINES, CATEGORY_NEARBY, CATEGORY_BY_NAME } Category;
#import "CheckinCatalogView.h"
#import "Authorization.h"
#import "Alerts.h"
#import "CatalogItem.h"
#import "CheckinItemView.h"
#import "UIImage+Thumbnail.h"
#import "UIImageView+WebCache.h"
#import "Config.h"
#import "Company.h"
#import "Catalog.h"
#import "Company.h"
#import "User.h"

@interface CheckinCatalogView() <CatalogDelegate>
@property (nonatomic, strong) MainMenu *mainMenu;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *allCompanies;
@property (nonatomic, strong) NSArray *companies;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSString *searchString;
@property (nonatomic) Category category;

@end

@implementation CheckinCatalogView
@synthesize tableView;
@synthesize locationManager = _locationManager;
@synthesize isFeedbackMode = _isFeedbackMode;
@synthesize searchBar = _searchBar;
@synthesize mainMenu = _mainMenu;
@synthesize category = _category;
@synthesize companies = _companies;
@synthesize dataSource = _dataSource;
@synthesize searchString = _searchString;
@synthesize allCompanies;

- (void)setSearchString:(NSString *)searchString {
    _searchString = searchString;
    
    if (self.searchString.length) {
        NSIndexSet *indexes = [self.allCompanies indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            Company *c = (Company *)obj;
            if ([c.name rangeOfString:self.searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
                return YES;
            }
            return NO;
        }];
        NSArray *c1 = [self.allCompanies objectsAtIndexes:indexes];
        self.dataSource = [NSArray arrayWithObject:c1];
    }
    else {
        self.dataSource = self.companies;
    }
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (void)setIsFeedbackMode:(BOOL)isFeedbackMode {
    _isFeedbackMode = isFeedbackMode;
    
    if (self.isFeedbackMode) {
        self.title = @"Добавить отзыв";
        [self.mainMenu addBackButton];
    }
    else {
        self.title = @"Отметиться";
    }
}

- (void)getCatalog { 
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [Catalog getCatalogByDistance:self.locationManager.location.coordinate withDelegate:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Отметиться";
    // Do any additional setup after loading the view from its nib.
    
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addMainButton];
    
    self.tableView.rowHeight = 104;
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if ([CLLocationManager locationServicesEnabled] && status != kCLAuthorizationStatusDenied) {
        [self.locationManager startUpdatingLocation];
    }
    else {
        [self getCatalog];
    } 
}

//-(void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//       
//}

- (void)viewDidUnload
{
    [self setTableView:nil];
    //[self setCell:nil];
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_ {
    searchBar_.showsCancelButton = searchBar_.text.length != 0;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
    self.searchString = searchBar.text;
    self.category = CATEGORY_BY_NAME;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if ([CLLocationManager locationServicesEnabled] && status != kCLAuthorizationStatusDenied) {
        [self.locationManager startUpdatingLocation];
    }
    else {
        [self getCatalogByName];
    }

}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    self.searchString = searchBar.text;
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar_ textDidChange:(NSString *)searchText {
    searchBar_.showsCancelButton = searchText.length != 0;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
    
    if (self.category == CATEGORY_BY_NAME) {
        [self getCatalogByName];
    }
    else {        
        [self getCatalog];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
    
    if (self.category == CATEGORY_BY_NAME) {
        [self getCatalogByName];
    }
    else {        
        [self getCatalog];
    }
}

#pragma mark - UITableViewDataSourceDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.searchString.length) return 1;  
    else return 5;
}

- (UIView *)tableView:(UITableView *)tableView_ viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView_.frame.size.width, 23)];
    view.backgroundColor = [UIColor yellowColor];
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:view.frame];
    bg.image = [UIImage imageNamed:@"sectionHeader.png"];
    [view addSubview:bg];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:18];
    label.adjustsFontSizeToFitWidth = YES;
    [view addSubview:label];
    
    NSString *headerText;
    switch (section) {
        case 0: 
            if (self.searchBar.text.length) {
                headerText = [NSString stringWithFormat:@"Найдено (%d)", ((NSArray *)[self.dataSource objectAtIndex:0]).count];
            }
            else
            {
                headerText = [NSString stringWithFormat:@"Рядом со мной (%d)", ((NSArray *)[self.dataSource objectAtIndex:0]).count]; 
            }
            break;
        case 1: headerText = [NSString stringWithFormat:@"В радиусе 100 метров (%d)", ((NSArray *)[self.dataSource objectAtIndex:1]).count]; break;
        case 2: headerText = [NSString stringWithFormat:@"В радиусе 150 метров (%d)", ((NSArray *)[self.dataSource objectAtIndex:2]).count]; break;
        case 3: headerText = [NSString stringWithFormat:@"В радиусе 300 метров (%d)", ((NSArray *)[self.dataSource objectAtIndex:3]).count]; break;
        case 4: headerText = [NSString stringWithFormat:@"В радиусе более 300 метров (%d)", ((NSArray *)[self.dataSource objectAtIndex:4]).count]; break;
    }
    
    label.text = headerText;
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchString.length) return ((NSArray *)[self.dataSource objectAtIndex:0]).count;
    else return ((NSArray *)[self.dataSource objectAtIndex:section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"CheckinCell";
    
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:reuseIdentifier owner:nil options:nil] objectAtIndex:0];
    }    
    
    UIImageView *view1 = (UIImageView *)[cell viewWithTag:1];
    UILabel *view2 = (UILabel *)[cell viewWithTag:2];
    UILabel *view3 = (UILabel *)[cell viewWithTag:3];
    UIButton *view4 = (UIButton *)[cell viewWithTag:4];
    
    Company *company = [((NSArray *)[self.dataSource objectAtIndex:indexPath.section]) objectAtIndex:indexPath.row];
    
    view1.image = kPLACEHOLDER_IMAGE;
    if (company.logoURL) {
        [view1 setImageWithURL:company.logoURL placeholderImage:kPLACEHOLDER_IMAGE];
    }
    view2.text = company.name;
    view3.text = company.address;
    //CLLocation *cl = [[CLLocation alloc] initWithLatitude:company.coordinate.latitude longitude:company.coordinate.longitude];
    //double distance = [self.locationManager.location distanceFromLocation:cl];
    double distance = company.distance;
    if (distance < 1000) {
        [view4 setTitle:[NSString stringWithFormat:@"%.0lf м", distance] forState:UIControlStateNormal];
    }
    else {
        [view4 setTitle:[NSString stringWithFormat:@"%.1lf км", distance / 1000] forState:UIControlStateNormal];
    }
    [view4 sizeToFit];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Company *company = [((NSArray *)[self.dataSource objectAtIndex:indexPath.section]) objectAtIndex:indexPath.row];
    CheckinItemView *view = [[CheckinItemView alloc] init];
    view.company = company;
    view.isFeedbackMode = self.isFeedbackMode;
    [self.navigationController pushViewController:view animated:YES];
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


- (void)getCatalogByName {
    [Catalog getCatalogByName:self.searchString nearCoordinate:self.locationManager.location.coordinate withDelegate:self];
}


#pragma mark - CatalogDelegate
- (void)catalogDidLoad:(NSArray *)companies {
    //self.scrollView.hidden = YES;
    self.tableView.hidden = NO;
    
    NSMutableArray *c1 = [NSMutableArray array];
    NSMutableArray *c2 = [NSMutableArray array];
    NSMutableArray *c3 = [NSMutableArray array];
    NSMutableArray *c4 = [NSMutableArray array];
    NSMutableArray *c5 = [NSMutableArray array];
    for (Company *c in companies) {
        //CLLocation *cl = [[CLLocation alloc] initWithLatitude:c.coordinate.latitude longitude:c.coordinate.longitude];
        //double distance = [cl distanceFromLocation:self.locationManager.location];
        if (c.distance < 50) [c1 addObject:c];
        else if (c.distance < 100) [c2 addObject:c];
        else if (c.distance < 150) [c3 addObject:c];
        else if (c.distance < 300) [c4 addObject:c];
        else [c5 addObject:c];
    }
    self.allCompanies = companies;
    self.companies = [NSArray arrayWithObjects:c1, c2, c3, c4, c5, nil];
    self.dataSource = [self.companies copy];
    [self.tableView reloadData];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)catalogDidFailWithError:(NSString *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
