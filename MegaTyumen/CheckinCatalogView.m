//
//  CheckinCatalogView.m
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 04.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CheckinCatalogView.h"
#import "Authorization.h"
#import "Alerts.h"
#import "CatalogItem.h"
#import "CheckinItemView.h"
#import "UIImage+Thumbnail.h"
#import "UIImageView+WebCache.h"

@interface CheckinCatalogView()
@property (nonatomic, strong) CheckinItemView *chechinItemView;
@property (nonatomic, strong) MainMenu *mainMenu;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) Catalog *catalog;
@property (strong, nonatomic) MBProgressHUD *hud;
- (void)didGetCatalog:(NSNotification *)notification;
@end

@implementation CheckinCatalogView
@synthesize tableView;
@synthesize locationManager = _locationManager;
@synthesize catalog = _catalog;
@synthesize cell = _cell;
@synthesize hud = _hud;
//@synthesize searchDataSource = _searchDataSource;
@synthesize chechinItemView = _chechinItemView;
@synthesize isFeedbackMode = _isFeedbackMode;
@synthesize mainMenu = _mainMenu;

- (CheckinItemView *)chechinItemView {
    if (!_chechinItemView) {
        _chechinItemView = [[CheckinItemView alloc] init];
    }
    return _chechinItemView;
}

- (Catalog *)catalog {
    if (!_catalog) {
        _catalog = [[Catalog alloc] initWithUserLocation:self.locationManager.location];
    }
    return _catalog;
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
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.catalog getCatalogByDistanceWithLat:self.locationManager.location.coordinate.latitude andLng:self.locationManager.location.coordinate.longitude];
}

- (void)didGetCatalog:(NSNotification *)notification {
    NSLog(@"View каталог получил!");
    
    [self.tableView reloadData];
    
    [self.hud hide:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Отметиться";
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
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCatalog:) name:kNOTIFICATION_DID_GET_CATALOG_BY_DISTANCE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCatalogByName:) name:kNOTIFICATION_DID_GET_CATALOG_BY_NAME object:nil];
    
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addMainButton];
    
    self.tableView.rowHeight = 104;
}

-(void)viewWillAppear:(BOOL)animated {
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
    }
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.locationManager stopUpdatingLocation];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_GET_CATALOG_BY_NAME object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_GET_CATALOG_BY_DISTANCE object:nil];
    [self setTableView:nil];
    [self setCell:nil];
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

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    return YES;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    self.catalog.searchString = searchBar.text;
    [self.tableView reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    self.catalog.searchString = searchBar.text;
    [self.tableView reloadData];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (!searchText.length) {
        self.catalog.searchString = @"";
        [self.tableView reloadData];
    }
}

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"New location: %.4lf, %.4lf speed = %.4lf", newLocation.coordinate.latitude, newLocation.coordinate.longitude, newLocation.speed);
    [self.locationManager stopUpdatingLocation];
    [self getCatalog];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"catalog sections: %d", self.catalog.sections);
    return self.catalog.sections;
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
            if (self.catalog.searchString.length) {
                headerText = [NSString stringWithFormat:@"Найдено (%d)", [[self.catalog.rows objectAtIndex:section] intValue]];
            }
            else
            {
                headerText = [NSString stringWithFormat:@"Рядом со мной (%d)", [[self.catalog.rows objectAtIndex:section] intValue]]; 
            }
            break;
        case 1: headerText = [NSString stringWithFormat:@"В радиусе 100 метров (%d)", [[self.catalog.rows objectAtIndex:section] intValue]]; break;
        case 2: headerText = [NSString stringWithFormat:@"В радиусе 150 метров (%d)", [[self.catalog.rows objectAtIndex:section] intValue]]; break;
        }
    
    label.text = headerText;
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = [[self.catalog.rows objectAtIndex:section] intValue];
    NSLog(@"number of rows in section: %d : %d", section, rows);
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CheckinCell";
    
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = self.cell;
        self.cell = nil;
    }    
    
    UIImageView *view1 = (UIImageView *)[cell viewWithTag:1];
    UILabel *view2 = (UILabel *)[cell viewWithTag:2];
    UILabel *view3 = (UILabel *)[cell viewWithTag:3];
    UIButton *view4 = (UIButton *)[cell viewWithTag:4];
    
    CatalogItem *item = [self.catalog.items objectForKey:indexPath];
    
    if (item) {
        //[view1 setImageWithURL:[item.photosUrls objectAtIndex:0] placeholderImage:[UIImage imageNamed:@"placeholder.png"] andScaleTo:view1.frame.size];
        view2.text = item.name;
        view3.text = item.address;
        int distance = item.distance;
        NSString *distanceStr;
        if (distance < 1000) {
            distanceStr = @"м";
        }
        else {
            distance /= 1000;
            distanceStr = @"км";
        }
        [view4 setTitle:[NSString stringWithFormat:@"%d %@", distance, distanceStr] forState:UIControlStateNormal];
        [view4 sizeToFit];
    }
    else {
        view1.image = nil;
        view2.text = @"";
        view3.text = @"";
        [view4 setTitle:@"" forState:UIControlStateNormal];
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CatalogItem *catalogItem = [self.catalog.items objectForKey:indexPath];
    self.chechinItemView.currentItem = catalogItem;
    [self.navigationController pushViewController:self.chechinItemView animated:YES];
    self.chechinItemView.isFeedbackMode = self.isFeedbackMode;
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
