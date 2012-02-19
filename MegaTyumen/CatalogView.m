//
//  CatalogView.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 13.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CatalogView.h"
#import "Authorization.h"
#import "AuthorizationView.h"
#import "Catalog.h"
#import "CatalogItem.h"
#import <CoreLocation/CoreLocation.h>
#import "CatalogCategory.h"
#import "CheckinCatalogView.h"
#import "Alerts.h"
#import "CatalogCategoryView.h"
#import "CatalogItemView.h"
#import "UIImageView+WebCache.h"

@interface CatalogView()
@property (nonatomic, strong) AuthorizationView *authorizationView;
@property (nonatomic, strong) Catalog *catalog;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) int currentCategory;
@property (nonatomic, strong) CheckinCatalogView *checkinView;
@property (nonatomic, strong) CatalogCategoryView *catalogCategoryView;
@property (nonatomic, strong) CatalogItemView *catalogItemView;
@property (nonatomic, strong) MainMenu *mainMenu;
- (void)loadCatalog;
@end

@implementation CatalogView
@synthesize searchBar;
@synthesize tableView;
@synthesize cell = _cell;
@synthesize checkinLabel = _checkinLabel;
@synthesize checkinButton = _checkinButton;
@synthesize scrollView = _scrollView;
@synthesize borderButton = _borderButton;
@synthesize btnType = _btnType;
@synthesize btnCuisine = _btnCuisine;
@synthesize btnBill = _btnBill;
@synthesize btnNearby = _btnNearby;
@synthesize authorizationView = _authorizationView;
@synthesize catalog = _catalog;
@synthesize locationManager = _locationManager;
@synthesize currentCategory = _currentCategory;
@synthesize checkinView = _checkinView;
@synthesize catalogCategoryView = _catalogCategoryView;
@synthesize catalogItemView = _catalogItemView;
@synthesize hud = _hud;
@synthesize mainMenu = _mainMenu;

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (void)initUI {
    for (UIView *view in self.scrollView.subviews) {
        if (view.tag != 1) {
            [view removeFromSuperview];
        }
    }
    
    NSArray *categories = [self.catalog.categories objectAtIndex:self.currentCategory];
//    switch (self.currentSection) {
//        case 0: categories = self.catalog.establishmentTypes; break;        
//        case 1: categories = self.catalog.cuisineTypes; break;
//        case 2: categories = self.catalog.billTypes; break;
//    }
    
    int row = 0, column = 0;
    for (int i = 0; i < categories.count; i++) {
        CatalogCategory *type = [categories objectAtIndex:i];
        
        CGRect buttonFrame = CGRectMake(28 + column * (64 + 36), 28 + row * (64 + 36 + 21), 64, 64);
        UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
        if (type.image) {
            [button setImage:type.image forState:UIControlStateNormal];
        }
        else { [button setImage:[UIImage imageNamed:@"catalog_button.png"] forState:UIControlStateNormal]; }
        button.tag = i;
        [button addTarget:self action:@selector(onCatalogCategoryButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        
        CGRect labelFrame = CGRectMake(buttonFrame.origin.x - 14, buttonFrame.origin.y + buttonFrame.size.height + 8, 28 + buttonFrame.size.width, 21);
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        label.text = type.name;
        label.font = [UIFont boldSystemFontOfSize:14];
        label.textAlignment = UITextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        label.textColor = [UIColor colorWithRed:116/255.0 green:77/255.0 blue:39/255.0 alpha:1];
        [self.scrollView addSubview:label];
        
        if (++column == 3) {
            column = 0;
            row++;
        }
    }
    
    int height = (row + 1) * (64 + 21 + 36) + 2 * 28 - 36;
    self.borderButton.frame = CGRectMake(self.borderButton.frame.origin.x, self.borderButton.frame.origin.y, self.borderButton.bounds.size.width, height - 16);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, height);
}

- (void)onCatalogCategoryButtonClick:(id)sender {
    if (!self.catalogCategoryView) {
        self.catalogCategoryView = [[CatalogCategoryView alloc] init];
    }
    UIButton *btn = (UIButton *)sender;
    self.catalogCategoryView.catalog = self.catalog;
    self.catalogCategoryView.currentCategory = [[self.catalog.categories objectAtIndex:self.currentCategory] objectAtIndex:btn.tag];
    self.catalogCategoryView.parentCatalogView = self;
    [self.navigationController pushViewController:self.catalogCategoryView animated:YES];
}

- (IBAction)onCheckinButtonClick {
    if (![Authorization sharedAuthorization].isAuthorized) {
        [Alerts showAuthorizationAlertViewWithTitle:@"Ошибка" message:@"Для того, чтобы отметиться, нужно авторизоваться" delegate:self];
        return;
    }
    
    if (!self.checkinView) {
        self.checkinView = [[CheckinCatalogView alloc] init];
    }
    [self.navigationController pushViewController:self.checkinView animated:YES];
}

- (IBAction)onTypeButtonClick {
    [self onButtonClick:self.btnType];
}

- (IBAction)onCuisineButtonClick {
    [self onButtonClick:self.btnCuisine];
}

- (IBAction)onBillButtonClick {
    [self onButtonClick:self.btnBill];
}

- (IBAction)onNearbyButtonClick {
    [self onButtonClick:self.btnNearby];
}

-(void)onMainButtonClick {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)onAuthorizeButtonClick {
    if (!self.authorizationView) {
        self.authorizationView = [[AuthorizationView alloc] init];
    }
    [self.navigationController pushViewController:self.authorizationView animated:YES];
}

- (void)didPassAuthorization:(NSNotification *)notification {
    self.navigationItem.rightBarButtonItem = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Каталог заведений";
        
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPassAuthorization:) name:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCatalogTypes:) name:kNOTIFICATION_DID_GET_CATALOG_TYPES object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCatalogCuisines:) name:kNOTIFICATION_DID_GET_CATALOG_CUISINES object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCatalogBills:) name:kNOTIFICATION_DID_GET_CATALOG_BILLS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCatalogByDistance:) name:kNOTIFICATION_DID_GET_CATALOG_BY_DISTANCE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCatalogByName:) name:kNOTIFICATION_DID_GET_CATALOG_BY_NAME object:nil];
    
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addMainButton];
    [self.mainMenu addAuthorizeButton];
    
    self.tableView.rowHeight = 104;
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        [self.locationManager startUpdatingLocation];
    }
    else {
        [self loadCatalog]; 
    }    
    
    //NSLog(@"user location: %@", self.locationManager.location);
    
    
    //[self.locationManager stopUpdatingLocation];
    
    
    [self.btnType setImage:[UIImage imageNamed:@"catalog_byTypeButtonPressed.png"] forState:UIControlStateSelected];
    [self.btnCuisine setImage:[UIImage imageNamed:@"catalog_byCuisineButtonPressed.png"] forState:UIControlStateSelected];
    [self.btnBill setImage:[UIImage imageNamed:@"catalog_byBillButtonPressed.png"] forState:UIControlStateSelected];
    [self.btnNearby setImage:[UIImage imageNamed:@"catalog_NearbyButtonPressed.png"] forState:UIControlStateSelected];
    self.btnType.selected = YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
    [self loadCatalog];
}

- (void)loadCatalog {
    self.catalog = [[Catalog alloc] initWithUserLocation:self.locationManager.location];
    self.catalog.searchString = @"";
    [self getCatalogTypes];  
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.locationManager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[self.locationManager stopUpdatingLocation];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_GET_CATALOG_TYPES object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];
    
    [self setSearchBar:nil];
    [self setTableView:nil];
    [self setCell:nil];
    [self setCheckinLabel:nil];
    [self setCheckinButton:nil];
    [self setScrollView:nil];
    [self setBorderButton:nil];
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

- (void)getCatalogTypes {    
    [self.catalog getTypes];
}

- (void)didGetCatalogTypes:(NSNotification *)notification {
    NSLog(@"Получил уведомление о получении типов");
    
    [self.hud hide:YES];
    
    [self initUI];
}

- (void)getCatalogByCuisine {
    [self.catalog getCuisines];
}

- (void)didGetCatalogCuisines:(NSNotification *)notification {
    NSLog(@"Получил уведомление о получении кухонь");
    
    [self.hud hide:YES];
    
    [self initUI];
}

- (void)getCatalogByBill {
    [self.catalog getBills];
}

- (void)didGetCatalogBills:(NSNotification *)notification {
    NSLog(@"Получил уведомление о получении чеков");
    
    [self.hud hide:YES];
    
    [self initUI];
}

-(void)getCatalogByDistance {    
    double lat = self.locationManager.location.coordinate.latitude;
    double lng = self.locationManager.location.coordinate.longitude;
    [self.catalog getCatalogByDistanceWithLat:lat andLng:lng];
}

- (void)didGetCatalogByDistance:(NSNotification *)notification {
    [self.tableView reloadData];
    
    [self.hud hide:YES];
}

- (void)didGetCatalogByName:(NSNotification *)notification {
    self.scrollView.hidden = YES;
    self.tableView.hidden = NO;
   
    [self.hud hide:YES];
    
    [self.tableView reloadData];
}

- (IBAction)onButtonClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    self.btnType.selected = NO;
    self.btnCuisine.selected = NO;
    self.btnBill.selected = NO;
    self.btnNearby.selected = NO;
    button.selected = YES;
    
    self.currentCategory = button.tag;
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (self.currentCategory == 3) {
        self.scrollView.hidden = YES;
        self.tableView.hidden = NO;
    }
    else {
        self.tableView.hidden = YES; 
        self.scrollView.hidden = NO;
    }
    
    switch (self.currentCategory) {
        case 0: 
            [self getCatalogTypes];
            break;
        case 1: 
            [self getCatalogByCuisine];
            break;
        case 2: 
            [self getCatalogByBill];
            break;
        case 3: 
            [self getCatalogByDistance];
            break;
    }    
}

#pragma mark - UITableVewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
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
    return [[self.catalog.rows objectAtIndex:section] intValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CatalogCell";
    
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
        //[view4 sizeToFit];
    }
    else {
        view1.image = nil;
        view2.text = @"";
        view3.text = @"";
        [view4 setTitle:@"" forState:UIControlStateNormal];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.catalogItemView) {
        self.catalogItemView = [[CatalogItemView alloc] init];
    }
    CatalogItem *item = [self.catalog.items objectForKey:indexPath];
    self.catalogItemView.currentItem = item;
    [self.navigationController pushViewController:self.catalogItemView animated:YES];
    return indexPath;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_ {
    searchBar_.showsCancelButton = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar_ {
    searchBar_.showsCancelButton = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_ {
    [searchBar_ resignFirstResponder];
    
    double lat = self.locationManager.location.coordinate.latitude;
    double lng = self.locationManager.location.coordinate.longitude;
    [self.catalog getCatalogByName:searchBar_.text andLat:lat andLng:lng];
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar_ {
    searchBar_.text = @"";
    [searchBar_ resignFirstResponder];
    
    self.tableView.hidden = YES;
    self.scrollView.hidden = NO;
}
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.mainMenu onAuthorizeButtonClick];
    }
}

@end
