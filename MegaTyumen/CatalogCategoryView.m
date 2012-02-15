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

@interface CatalogCategoryView()
@property (nonatomic, strong) AuthorizationView *authorizationView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CatalogItemView *catalogItemView;
@property (nonatomic, strong) MainMenu *mainMenu;
@end

@implementation CatalogCategoryView
@synthesize redImageView;
@synthesize headerLabel;
@synthesize tableView;
@synthesize cell;
@synthesize btnType;
@synthesize btnCuisine;
@synthesize btnBill;
@synthesize btnNearby;
@synthesize authorizationView = _authorizationView;
@synthesize currentCategory = _currentCategory;
@synthesize catalog = _catalog;
@synthesize locationManager = _locationManager;
@synthesize catalogItemView = _catalogItemView;
@synthesize hud = _hud;
@synthesize parentCatalogView = _parentCatalogView;
@synthesize mainMenu = _mainMenu;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPassAuthorization:) name:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil]; 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCatalogByCategory:) name:@"didGetCatalogByCategory" object:nil]; 
    
    [self.btnType setImage:[UIImage imageNamed:@"catalog_byTypeButtonPressed.png"] forState:UIControlStateSelected];
    [self.btnCuisine setImage:[UIImage imageNamed:@"catalog_byCuisineButtonPressed.png"] forState:UIControlStateSelected];
    [self.btnBill setImage:[UIImage imageNamed:@"catalog_byBillButtonPressed.png"] forState:UIControlStateSelected];
    [self.btnNearby setImage:[UIImage imageNamed:@"catalog_NearbyButtonPressed.png"] forState:UIControlStateSelected];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.btnType.selected = NO;
    self.btnCuisine.selected = NO;
    self.btnBill.selected = NO;
    self.btnNearby.selected = NO;
    self.title = @"";
    self.headerLabel.text = @"";
    
    self.currentCategory = self.currentCategory;
    
    //[self.locationManager startUpdatingLocation];
    [self getCatalogByCategory];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //[self.locationManager stopUpdatingLocation];
}

- (void)viewDidUnload
{
    [self setRedImageView:nil];
    [self setHeaderLabel:nil];
    [self setTableView:nil];
    [self setCell:nil];
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
        case 2: [self.parentCatalogView onBillButtonClick]; break;
        case 3: [self.parentCatalogView onNearbyButtonClick]; break;
    }
}

-(void)didPassAuthorization:(NSNotification *)notification {
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)setCurrentCategory:(CatalogCategory *)currentCategory {
    _currentCategory = currentCategory;
    switch (self.currentCategory.index) {
        case 0: btnType.selected = YES; break;
        case 1: btnCuisine.selected = YES; break;
        case 2: btnBill.selected = YES; break;
    }
    self.title = self.currentCategory.name;
    self.headerLabel.text = self.currentCategory.name;
    self.redImageView.image = [self.currentCategory.image thumbnailByScalingProportionallyAndCroppingToSize:CGSizeMake(64, 64)];
}

- (void)getCatalogByCategory {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    double lat = self.locationManager.location.coordinate.latitude;
    double lng = self.locationManager.location.coordinate.longitude;
    [self.catalog getCatalogByCategory:self.currentCategory andLat:lat andLng:lng];
}

- (void)didGetCatalogByCategory:(NSNotification *)notification {
    [self.hud hide:YES];
    
    [self.tableView reloadData];
}

- (void)setType:(NSString *)type {
    for (CatalogCategory *category in self.catalog.categories) {
        if ([category.name rangeOfString:type].location != NSNotFound) {
            self.currentCategory = category;
            break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.catalog.sections;
}

//- (UIView *)tableView:(UITableView *)tableView_ viewForHeaderInSection:(NSInteger)section {
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView_.frame.size.width, 23)];
//    view.backgroundColor = [UIColor yellowColor];
//    
//    UIImageView *bg = [[UIImageView alloc] initWithFrame:view.frame];
//    bg.image = [UIImage imageNamed:@"sectionHeader.png"];
//    [view addSubview:bg];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
//    label.backgroundColor = [UIColor clearColor];
//    label.textColor = [UIColor whiteColor];
//    label.font = [UIFont boldSystemFontOfSize:18];
//    label.adjustsFontSizeToFitWidth = YES;
//    [view addSubview:label];
//    
//    NSString *headerText;
//    switch (section) {
//        case 0: 
//            if (self.catalog.searchString.length) {
//                headerText = [NSString stringWithFormat:@"Найдено (%d)", [[self.catalog.rows objectAtIndex:section] intValue]];
//            }
//            else
//            {
//                headerText = [NSString stringWithFormat:@"Рядом со мной (%d)", [[self.catalog.rows objectAtIndex:section] intValue]]; 
//            }
//            break;
//        case 1: headerText = [NSString stringWithFormat:@"В радиусе 100 метров (%d)", [[self.catalog.rows objectAtIndex:section] intValue]]; break;
//        case 2: headerText = [NSString stringWithFormat:@"В радиусе 150 метров (%d)", [[self.catalog.rows objectAtIndex:section] intValue]]; break;
//    }
//    
//    label.text = headerText;
//    
//    return view;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.catalog.rows objectAtIndex:section] intValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CatalogCategoryCell";
    
    UITableViewCell *cell_ = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell_ == nil) {
        [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell_ = self.cell;
        self.cell = nil;
    }    
    
    UIImageView *view1 = (UIImageView *)[cell_ viewWithTag:1];
    UILabel *view2 = (UILabel *)[cell_ viewWithTag:2];
    UILabel *view3 = (UILabel *)[cell_ viewWithTag:3];
    UIButton *view4 = (UIButton *)[cell_ viewWithTag:4];
    UILabel *view5 = (UILabel *)[cell_ viewWithTag:5];
    UILabel *view6 = (UILabel *)[cell_ viewWithTag:6];    
    
    CatalogItem *item = [self.catalog.items objectForKey:indexPath];
    
    if (item) {
        [view1 setImageWithURL:[item.photosUrls objectAtIndex:0] placeholderImage:[UIImage imageNamed:@"placeholder.png"] andScaleTo:view1.frame.size];
        view2.text = item.name;
        view3.text = item.address;
        int distance = item.distance;
        [view4 setTitle:[NSString stringWithFormat:@"%d м", distance] forState:UIControlStateNormal];
        //[view4 sizeToFit];
        
        view5.text = [NSString stringWithFormat:@"%d", item.checkins];
        view6.text = [NSString stringWithFormat:@"%d", item.feedbacks.count];
    }
    else {
        view1.image = nil;
        view2.text = @"";
        view3.text = @"";
        [view4 setTitle:@"" forState:UIControlStateNormal];
        view5.text = @"";
        view6.text = @"";
    }
    
    return cell_;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.catalogItemView) {
        self.catalogItemView = [[CatalogItemView alloc] init];
    }
    CatalogItem *item = [self.catalog.items objectForKey:indexPath];
    self.catalogItemView.currentItem = item;
    self.catalogItemView.catalog = self.catalog;
    self.catalogItemView.parentCatalogCategoryView = self;
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
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.catalog.searchString = searchBar_.text;
    [self.tableView reloadData];
    
    [self.hud hide:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar_ {
    searchBar_.text = @"";
    [searchBar_ resignFirstResponder];
    self.catalog.searchString = searchBar_.text;
    [self.tableView reloadData];
}

@end
