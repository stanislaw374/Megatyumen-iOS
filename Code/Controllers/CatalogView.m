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
#import "Config.h"
#import "Company.h"
#import "User.h"

typedef enum { CATEGORY_TYPES, CATEGORY_CUISINES, CATEGORY_NEARBY, CATEGORY_BY_NAME } Category;

@interface CatalogView() <CatalogDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MainMenu *mainMenu;
@property (nonatomic, strong) NSArray *types;
@property (nonatomic, strong) NSArray *cuisines;
@property (nonatomic) Category category;
@property (nonatomic, strong) NSArray *allCompanies;
@property (nonatomic, strong) NSArray *companies;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSString *searchString;
- (void)initUI;
- (void)getCatalogTypes; 
- (void)getCatalogByCuisine;
- (void)getCatalogByBill;
- (void)getCatalogByDistance;
- (void)getCatalogByName;
@end

@implementation CatalogView
@synthesize searchBar;
@synthesize tableView;
//@synthesize cell = _cell;
@synthesize checkinLabel = _checkinLabel;
@synthesize checkinButton = _checkinButton;
@synthesize scrollView = _scrollView;
@synthesize borderButton = _borderButton;
@synthesize btnType = _btnType;
@synthesize btnCuisine = _btnCuisine;
@synthesize btnBill = _btnBill;
@synthesize btnNearby = _btnNearby;
//@synthesize authorizationView = _authorizationView;
//@synthesize catalog = _catalog;
@synthesize locationManager = _locationManager;
//@synthesize checkinView = _checkinView;
//@synthesize catalogCategoryView = _catalogCategoryView;
//@synthesize catalogItemView = _catalogItemView;
//@synthesize hud = _hud;
@synthesize mainMenu = _mainMenu;
//@synthesize categories = _categories;
@synthesize category = _category;
@synthesize types = _types;
@synthesize cuisines = _cuisines;
@synthesize allCompanies = _allCompanies;
@synthesize companies = _companies;
@synthesize searchString = _searchString;
@synthesize dataSource = _dataSource;

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
    
    int row = 0, column = 0;
    NSArray *categories = self.category == CATEGORY_TYPES ? self.types : self.cuisines;
    for (int i = 0; i < categories.count; i++) {
        NSDictionary *category = [categories objectAtIndex:i];
        
        CGRect buttonFrame = CGRectMake(28 + column * (64 + 36), 28 + row * (64 + 36 + 21), 64, 64);
        UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
        UIImage *image = [category objectForKey:@"image"];
        if (image) {
            [button setImage:image forState:UIControlStateNormal];
        }
        else { [button setImage:[UIImage imageNamed:@"catalog_button.png"] forState:UIControlStateNormal]; }
        button.tag = i;
        [button addTarget:self action:@selector(onCatalogCategoryButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        
        CGRect labelFrame = CGRectMake(buttonFrame.origin.x - 14, buttonFrame.origin.y + buttonFrame.size.height + 8, 28 + buttonFrame.size.width, 21);
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        label.text = [category objectForKey:@"name"];
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
    UIButton *btn = (UIButton *)sender;
    
    CatalogCategoryView *view = [[CatalogCategoryView alloc] init];
    view.parentCatalogView = self;
    
    NSDictionary *type;
    switch (self.category) {
        case CATEGORY_TYPES:
            type = [self.types objectAtIndex:btn.tag];
            break;
        case CATEGORY_CUISINES:
            type = [self.cuisines objectAtIndex:btn.tag];
            break;
        default: break;
    }
    view.type = type;
    [self.navigationController pushViewController:view animated:YES];    
}

- (IBAction)onCheckinButtonClick {
    if (![User sharedUser].token) {
        [Alerts showAlertViewWithTitle:@"Ошибка" message:@"Для того, чтобы отметиться, нужно авторизоваться"];
        return;
    }    
    CheckinCatalogView *view = [[CheckinCatalogView alloc] init];
    [self.navigationController pushViewController:view animated:YES];
}

- (IBAction)onTypeButtonClick {
    self.category = CATEGORY_TYPES;
    [self onButtonClick:self.btnType];
}

- (IBAction)onCuisineButtonClick {
    self.category = CATEGORY_CUISINES;
    [self onButtonClick:self.btnCuisine];
}

- (IBAction)onNearbyButtonClick {
    self.category = CATEGORY_NEARBY;
    [self onButtonClick:self.btnNearby];
}

-(void)onMainButtonClick {
    [self.navigationController popToRootViewControllerAnimated:YES];
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

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
    
    if (self.category == CATEGORY_BY_NAME) {
        [self getCatalogByName];
    }
    else {        
        [self getCatalogByDistance];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
    
    if (self.category == CATEGORY_BY_NAME) {
        [self getCatalogByName];
    }
    else {        
        [self getCatalogByDistance];
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addMainButton];
    if ([User sharedUser].token != nil)
        [self.mainMenu addLogoutButton];
    else
        [self.mainMenu addAuthorizeButton];
    
    self.tableView.rowHeight = 104;  
    
    self.btnType.selected = YES;
    
    [self onTypeButtonClick];
}

- (void)viewDidUnload
{ 
    [self setSearchBar:nil];
    [self setTableView:nil];
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
    [Catalog getTypesWithDelegate:self];
}

- (void)getCatalogByCuisine {
    [Catalog getCuisinesWithDelegate:self];
}

- (void)getCatalogByDistance {   
    [Catalog getCatalogByDistance:self.locationManager.location.coordinate withDelegate:self];
}

- (void)getCatalogByName {
    [Catalog getCatalogByName:self.searchString nearCoordinate:self.locationManager.location.coordinate withDelegate:self];
}

- (IBAction)onButtonClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    self.btnType.selected = NO;
    self.btnCuisine.selected = NO;
    self.btnBill.selected = NO;
    self.btnNearby.selected = NO;
    button.selected = YES;    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (self.category == CATEGORY_NEARBY || self.category == CATEGORY_BY_NAME) {
        self.scrollView.hidden = YES;
        self.tableView.hidden = NO;
    }
    else {
        self.tableView.hidden = YES; 
        self.scrollView.hidden = NO;
    }
    
    switch (self.category) {
        case CATEGORY_TYPES: 
            [self getCatalogTypes];
            break;
        case CATEGORY_CUISINES: 
            [self getCatalogByCuisine];
            break;
        case CATEGORY_NEARBY: 
        {
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            if ([CLLocationManager locationServicesEnabled] && status != kCLAuthorizationStatusDenied) {        
                [self.locationManager startUpdatingLocation];
            }
            else {
                [self getCatalogByDistance];
            }
            break;
        }
        default: break;
    }    
}

#pragma mark - UITableVewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
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
            headerText = [NSString stringWithFormat:@"Рядом со мной (%d)", ((NSArray *)[self.dataSource objectAtIndex:0]).count]; 
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
    return ((NSArray *)[self.dataSource objectAtIndex:section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"CatalogCell";
    
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:reuseIdentifier owner:nil options:nil] objectAtIndex:0];
    }    
    
    Company *company = [((NSArray *)[self.dataSource objectAtIndex:indexPath.section]) objectAtIndex:indexPath.row];
    
    UIImageView *view1 = (UIImageView *)[cell viewWithTag:1];
    UILabel *view2 = (UILabel *)[cell viewWithTag:2];
    UILabel *view3 = (UILabel *)[cell viewWithTag:3];
    UIButton *view4 = (UIButton *)[cell viewWithTag:4];
    //UILabel *view5 = (UILabel *)[cell viewWithTag:5];
    //UILabel *view6 = (UILabel *)[cell viewWithTag:6];    
    
    view1.image = kPLACEHOLDER_IMAGE;
    if (company.logoURL) {
        [view1 setImageWithURL:company.logoURL placeholderImage:kPLACEHOLDER_IMAGE];
    }
    view2.text = company.name;
    view3.text = company.address;
    
    //CLLocation *cl = [[CLLocation alloc] initWithLatitude:company.coordinate.latitude longitude:company.coordinate.longitude];
    //double distance = [self.locationManager.location distanceFromLocation:cl];
    if (company.distance < 1000) {
        [view4 setTitle:[NSString stringWithFormat:@"%.0lf м", company.distance] forState:UIControlStateNormal];
    }
    else {
        [view4 setTitle:[NSString stringWithFormat:@"%.1lf км", company.distance / 1000] forState:UIControlStateNormal];
    }
    [view4 sizeToFit];
        
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CatalogItemView *view = [[CatalogItemView alloc] init];
    view.company = [((NSArray *)[self.dataSource objectAtIndex:indexPath.section]) objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:view animated:YES];
    return indexPath;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_ {
    searchBar_.showsCancelButton = searchBar_.text.length != 0;
}

- (void)searchBar:(UISearchBar *)searchBar_ textDidChange:(NSString *)searchText {
    searchBar_.showsCancelButton = searchText.length != 0;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_ {
    searchBar_.showsCancelButton = NO;
    [searchBar_ resignFirstResponder];
    self.searchString = searchBar_.text;
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

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar_ {
    searchBar_.text = @"";
    [searchBar_ resignFirstResponder];
    self.searchString = searchBar_.text;
    
    self.tableView.hidden = YES;
    self.scrollView.hidden = NO;
}
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.mainMenu onAuthorizeButtonClick];
    }
}

#pragma mark - CatalogDelegate
- (void)catalogDidGetTypes:(NSArray *)types {
    self.types = types;
    [self initUI];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)catalogDidFailWithError:(NSString *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)catalogDidGetCuisines:(NSArray *)cuisines {
    self.cuisines = cuisines;
    [self initUI];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)catalogDidLoad:(NSArray *)companies {
    self.scrollView.hidden = YES;
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

@end
