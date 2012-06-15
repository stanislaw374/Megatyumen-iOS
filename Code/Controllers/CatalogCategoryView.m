//
//  CatalogSubcategoryView.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 14.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CatalogCategoryView.h"
#import "Authorization.h"
#import "AuthorizationView.h"
#import "CatalogItem.h"
#import <CoreLocation/CoreLocation.h>
#import "CatalogItemView.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Thumbnail.h"
#import "Config.h"

@interface CatalogCategoryView() <CatalogDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MainMenu *mainMenu;
@property (nonatomic, strong) NSArray *companies;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSString *searchString;
- (void)getCatalogByCategory;
@end

@implementation CatalogCategoryView
@synthesize redImageView;
@synthesize headerLabel;
@synthesize tableView;
@synthesize btnType;
@synthesize btnCuisine;
@synthesize btnBill;
@synthesize btnNearby;
@synthesize locationManager = _locationManager;
@synthesize parentCatalogView = _parentCatalogView;
@synthesize mainMenu = _mainMenu;
@synthesize companies = _companies;
@synthesize type = _type;
@synthesize dataSource = _dataSource;
@synthesize searchString = _searchString;

- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSArray array];
    }
    return _dataSource;
}

- (void)setSearchString:(NSString *)searchString {
    _searchString = searchString;
    if (!self.searchString.length) {
        self.dataSource = self.companies;
    }
    else {
        NSIndexSet *indexes = [self.companies indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            Company *c = (Company *)obj;
            if ([c.name rangeOfString:self.searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
                return YES;
            }
            else return NO;
        }];
        self.dataSource = [self.companies objectsAtIndexes:indexes];
    }
}

- (NSArray *)companies {
    if (!_companies) {
        _companies = [NSArray array];
    }
    return _companies;
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

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];    
    [self getCatalogByCategory];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
    [self getCatalogByCategory];
}

#pragma mark - 

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addBackButton];
    [self.mainMenu addMainButton];
    [self.mainMenu addAuthorizeButton];
    
    self.tableView.rowHeight = 104;
    
    self.btnType.selected = NO;
    self.btnCuisine.selected = NO;
    self.btnBill.selected = NO;
    self.btnNearby.selected = NO;
    self.title = @"";
    self.headerLabel.text = @"";
    
    self.btnType.selected = NO;
    self.btnCuisine.selected = NO;
    self.btnBill.selected = NO;
    self.btnNearby.selected = NO;
    self.title = @"";
    self.headerLabel.text = @"";
    
    NSString *category = [self.type objectForKey:@"category"];
    if ([category isEqualToString:@"type"]) {
        btnType.selected = YES;
    }
    else if ([category isEqualToString:@"cuisine"]) {
        btnCuisine.selected = YES;
    }
    
    self.title = [self.type objectForKey:@"name"];
    self.headerLabel.text = [self.type objectForKey:@"name"];
    self.redImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.redImageView.image = [self.type objectForKey:@"image"];
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if ([CLLocationManager locationServicesEnabled] && status != kCLAuthorizationStatusDenied) {
        [self.locationManager startUpdatingLocation];
    }
    else {
        [self getCatalogByCategory];
    }

}

- (void)viewDidUnload
{
    [self setRedImageView:nil];
    [self setHeaderLabel:nil];
    [self setTableView:nil];
    [self setBtnType:nil];
    [self setBtnCuisine:nil];
    [self setBtnBill:nil];
    [self setBtnNearby:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onRefreshButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onButtonClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    [self.navigationController popViewControllerAnimated:NO];
    switch (btn.tag) {
        case 0: [self.parentCatalogView onTypeButtonClick]; break;
        case 1: [self.parentCatalogView onCuisineButtonClick]; break;
        //case 2: [self.parentCatalogView onBillButtonClick]; break;
        case 3: [self.parentCatalogView onNearbyButtonClick]; break;
    }
}

- (void)getCatalogByCategory {    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *category = [self.type objectForKey:@"category"];
    if ([category isEqualToString:@"type"]) {
        [Catalog getCatalogByTypeID:[self.type objectForKey:@"id"] nearCoordinate:self.locationManager.location.coordinate withDelegate:self];
    }
    if ([category isEqualToString:@"cuisine"]) {
        [Catalog getCatalogByCuisineID:[self.type objectForKey:@"id"] nearCoordinate:self.locationManager.location.coordinate withDelegate:self];
    } 
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"CatalogCategoryCell";
    
    UITableViewCell *_cell = [tableView_ dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!_cell) {
        _cell = [[[NSBundle mainBundle] loadNibNamed:reuseIdentifier owner:self options:nil] objectAtIndex:0];
    }    
    
    UIImageView *view1 = (UIImageView *)[_cell viewWithTag:1];
    UILabel *view2 = (UILabel *)[_cell viewWithTag:2];
    UILabel *view3 = (UILabel *)[_cell viewWithTag:3];
    UIButton *view4 = (UIButton *)[_cell viewWithTag:4];
    UILabel *view5 = (UILabel *)[_cell viewWithTag:5];
    UILabel *view6 = (UILabel *)[_cell viewWithTag:6];    
    
    Company *company = [self.dataSource objectAtIndex:indexPath.row];
    view1.image = kPLACEHOLDER_IMAGE;
    if (company.logoURL) {
        [view1 setImageWithURL:company.logoURL placeholderImage:kPLACEHOLDER_IMAGE];
    }
    view2.text = company.name;
    view3.text = company.address;
//    if (company.distance < 1000) {
//        [view4 setTitle:[NSString stringWithFormat:@"%.0lf м", company.distance] forState:UIControlStateNormal];
//    }
//    else {
//        [view4 setTitle:[NSString stringWithFormat:@"%.1lf км", company.distance / 1000] forState:UIControlStateNormal];
//    }
    [view4 sizeToFit];
    view5.text = [NSString stringWithFormat:@"%d", company.checkinCount];
    view6.text = [NSString stringWithFormat:@"%d", company.feedbacksCount];
    
    return _cell;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CatalogItemView *view = [[CatalogItemView alloc] init];
    view.company = [self.dataSource objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:view animated:YES];
    return indexPath;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_ {
    searchBar_.showsCancelButton = searchBar_.text.length != 0;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar_ {
    searchBar_.showsCancelButton = NO;
}

- (void)searchBar:(UISearchBar *)searchBar_ textDidChange:(NSString *)searchText {
    searchBar_.showsCancelButton = searchText.length != 0;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_ {
    searchBar_.showsCancelButton = NO;
    [searchBar_ resignFirstResponder];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];    
    self.searchString = searchBar_.text;
    [self.tableView reloadData];    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar_ {
    searchBar_.text = @"";
    [searchBar_ resignFirstResponder];
    self.searchString = searchBar_.text;
    [self.tableView reloadData];
}

#pragma mark - CatalogDelegate
- (void)catalogDidLoad:(NSArray *)companies {
    self.companies = companies;
    self.dataSource = companies;
    [self.tableView reloadData];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)catalogDidFailWithError:(NSString *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
