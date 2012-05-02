//
//  CatalogItemView.m
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 18.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CatalogItemView.h"
#import "Authorization.h"
#import "AuthorizationView.h"
#import "UIImage+Thumbnail.h"
#import "MenuItem.h"
#import "Feedback.h"
#import "Event.h"
#import "CheckinView.h"
#import "YMapView.h"
#import <CoreLocation/CoreLocation.h>
#import "CatalogCategory.h"
#import "Alerts.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "Config.h"
#import "PhotosView.h"
#import "User.h"
#import "PhotosView.h"

@interface CatalogItemView() <CompanyDelegate> 
{
    int _toLoad;
}
@property (nonatomic) int selectedMenuIndex;
@property (nonatomic, strong) YMapView *catalogItemMapView;
@property (nonatomic, strong) MainMenu *mainMenu;
@property (nonatomic) BOOL hasMenu;
@property (nonatomic) BOOL hasFeedbacks;

- (void)loadCompany;

- (void)showDetails;
- (void)showPhotos;
- (void)showMenu;
- (void)showFeedback;
- (void)showEvents;
- (void)showMap;
- (void)hideUI;
@end

@implementation CatalogItemView
@synthesize fieldType;
@synthesize fieldPhone;
@synthesize fieldAddress;
@synthesize fieldSite;
@synthesize fieldHours;
@synthesize lblAboutTitle;
@synthesize thumbnailImageView;
@synthesize nameLabel;
@synthesize addressLabel;
@synthesize distanceButton;
@synthesize btnCommon;
@synthesize btnPhoto;
@synthesize btnMenu;
@synthesize btnFeedback;
@synthesize btnEvents;
@synthesize btnMap;
@synthesize lblType;
@synthesize lblPhone;
@synthesize lblAddress;
@synthesize lblWebsite;
@synthesize lblBusinessHours;
@synthesize lblAbout;
@synthesize btnCheckin;
@synthesize lblCheckin;
@synthesize scrollView0;
@synthesize borderButton0;
@synthesize scrollView1;
@synthesize borderButton1;

@synthesize photosView = _photosView;
@synthesize lblPhotosCount;
@synthesize scrollView2;
@synthesize borderButton2;
@synthesize tableView;
@synthesize menuCell;
@synthesize btnAddFeedback;
@synthesize selectedMenuIndex = _selectedMenuIndex;
@synthesize feedbackView = _feedbackView;
@synthesize catalogItemMapView = _catalogItemMapView;
@synthesize parentCatalogCategoryView = _parentCatalogCategoryView;
@synthesize mainMenu = _mainMenu;
@synthesize hasMenu = _hasMenu;
@synthesize hasFeedbacks = _hasFeedbacks;
@synthesize company = _company;

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
    
    [self.btnCommon setBackgroundImage:[UIImage imageNamed:@"catalog_headerPressed.png"] forState:UIControlStateSelected];
    [self.btnPhoto setBackgroundImage:[UIImage imageNamed:@"catalog_headerPressed.png"] forState:UIControlStateSelected];
    [self.btnMenu setBackgroundImage:[UIImage imageNamed:@"catalog_headerPressed.png"] forState:UIControlStateSelected];
    [self.btnFeedback setBackgroundImage:[UIImage imageNamed:@"catalog_headerPressed.png"] forState:UIControlStateSelected];
    [self.btnEvents setBackgroundImage:[UIImage imageNamed:@"catalog_headerPressed.png"] forState:UIControlStateSelected];
    [self.btnMap setBackgroundImage:[UIImage imageNamed:@"catalog_headerPressed.png"] forState:UIControlStateSelected];
    
    [self.btnCommon setTitleColor:[UIColor colorWithRed:106/255.0 green:2/255.0 blue:12/255.0 alpha:1] forState:UIControlStateSelected];
    [self.btnCommon setTitle:@"Общее" forState:UIControlStateSelected];
    [self.btnPhoto setTitleColor:[UIColor colorWithRed:106/255.0 green:2/255.0 blue:12/255.0 alpha:1] forState:UIControlStateSelected];
    [self.btnPhoto setTitle:@"Фото" forState:UIControlStateSelected];
    [self.btnFeedback setTitleColor:[UIColor colorWithRed:106/255.0 green:2/255.0 blue:12/255.0 alpha:1] forState:UIControlStateSelected];
    [self.btnFeedback setTitle:@"Отзывы" forState:UIControlStateSelected];
    [self.btnMenu setTitleColor:[UIColor colorWithRed:106/255.0 green:2/255.0 blue:12/255.0 alpha:1] forState:UIControlStateSelected];
    [self.btnMenu setTitle:@"Меню" forState:UIControlStateSelected];
    [self.btnEvents setTitleColor:[UIColor colorWithRed:106/255.0 green:2/255.0 blue:12/255.0 alpha:1] forState:UIControlStateSelected];
    [self.btnEvents setTitle:@"События" forState:UIControlStateSelected];
    [self.btnMap setTitleColor:[UIColor colorWithRed:106/255.0 green:2/255.0 blue:12/255.0 alpha:1] forState:UIControlStateSelected];
    [self.btnMap setTitle:@"На карте" forState:UIControlStateSelected];
    
    self.tableView.rowHeight = 104;
    
    self.title = @"Просмотр заведения"; 
    
    // -------
    self.nameLabel.text = @"";
    self.thumbnailImageView.image = nil;
    self.addressLabel.text = @"";
    self.distanceButton.hidden = YES;
    self.lblType.text = self.lblPhone.text = self.lblAddress.text = self.lblWebsite.text = self.lblBusinessHours.text = self.lblAbout.text = @"";
    
    [self hideUI];    
    
    self.thumbnailImageView.image = kPLACEHOLDER_IMAGE;
    if (self.company.logoURL) {
        [self.thumbnailImageView setImageWithURL:self.company.logoURL placeholderImage:kPLACEHOLDER_IMAGE]; 
    }
    self.nameLabel.text = self.company.name;
    self.addressLabel.text = self.company.address;
    if (self.company.distance < 1000) {
        [self.distanceButton setTitle:[NSString stringWithFormat:@"%.0lf м", self.company.distance] forState:UIControlStateNormal];
    }
    else {
        [self.distanceButton setTitle:[NSString stringWithFormat:@"%.1lf км", self.company.distance / 1000] forState:UIControlStateNormal];
    }
    self.distanceButton.hidden = NO;
    [self.distanceButton sizeToFit];
    
    [self loadCompany];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self hideUI];
    [self showDetails];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.company.delegate = nil;
}

- (void)viewDidUnload
{
    [self setThumbnailImageView:nil];
    [self setNameLabel:nil];
    [self setAddressLabel:nil];
    [self setDistanceButton:nil];
    [self setBtnCommon:nil];
    [self setBtnPhoto:nil];
    [self setBtnMenu:nil];
    [self setBtnFeedback:nil];
    [self setBtnEvents:nil];
    [self setBtnMap:nil];
    [self setLblType:nil];
    [self setLblPhone:nil];
    [self setLblAddress:nil];
    [self setLblWebsite:nil];
    [self setLblBusinessHours:nil];
    [self setLblAbout:nil];
    [self setBtnCheckin:nil];
    [self setLblCheckin:nil];
    [self setScrollView0:nil];
    [self setScrollView1:nil];
    [self setBorderButton0:nil];
    [self setBorderButton1:nil];
    [self setLblPhotosCount:nil];
    [self setTableView:nil];
    [self setMenuCell:nil];
    [self setBtnFeedback:nil];
    [self setBtnAddFeedback:nil];
    [self setScrollView2:nil];
    [self setBorderButton2:nil];
    [self setFieldPhone:nil];
    [self setFieldAddress:nil];
    [self setFieldSite:nil];
    [self setFieldHours:nil];
    [self setLblAboutTitle:nil];
    [self setFieldType:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Loading
- (void)loadCompany {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.company.delegate = self;
    [self.company getDetails];
    [self.company getEvents];
    [self.company getFeedbacks];
    [self.company getMenu];
    [self.company getImages];
    _toLoad = 5;
}

- (void)hideUI {    
    self.btnCommon.selected = NO;
    self.btnPhoto.selected = NO;
    self.btnMenu.selected = NO;
    self.btnFeedback.selected = NO;
    self.btnEvents.selected = NO;
    self.btnMap.selected = NO;
    
    self.scrollView0.hidden = YES;
    self.scrollView1.hidden = YES;
    self.scrollView2.hidden = YES;
    self.tableView.hidden = YES;
    
    self.btnCheckin.hidden = YES;
    self.lblCheckin.hidden = YES;
    self.btnAddFeedback.hidden = YES;
}

- (IBAction)onCheckinButtonClick {
    if (![User sharedUser].token) {
        [Alerts showAuthorizationAlertViewWithTitle:@"Ошибка" message:@"Для того, чтобы отметиться, нужно авторизоваться" delegate:self];
        return;
    }
    
    CheckinView *view = [[CheckinView alloc] init];
    view.isFeedbackMode = NO;
    view.company = self.company;
    [self.navigationController pushViewController:view animated:YES];
}

- (IBAction)onAddFeedbackButtonClick:(id)sender {
    if (![User sharedUser].token) {
        [Alerts showAuthorizationAlertViewWithTitle:@"Ошибка" message:@"Для того, чтобы отметиться, нужно авторизоваться" delegate:self];
        return;
    }
    
    CheckinView *view = [[CheckinView alloc] init];
    view.isFeedbackMode = YES;
    view.company = self.company;
    [self.navigationController pushViewController:view animated:YES];
}

- (IBAction)onTypeButtonClick {
//    for (CatalogCategory *category in [self.catalog.categories objectAtIndex:0]) {
//        if ([category.name rangeOfString:self.currentItem.type].location != NSNotFound && self.parentCatalogCategoryView) {
//            //self.parentCatalogCategoryView.currentCategory = self
//            [self.navigationController popViewControllerAnimated:YES];
//            break;
//        }
//    }
}

- (IBAction)onPhoneButtonClick {
    NSString *phone = [[self.company.phone componentsSeparatedByString:@","] objectAtIndex:0];
    NSString *cleanedString = [[phone componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789+"] invertedSet]] componentsJoinedByString:@""];
    NSString *escapedPhoneNumber = [cleanedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", escapedPhoneNumber]];
    NSLog(@"phone: %@", escapedPhoneNumber);
    if ([[UIApplication sharedApplication] canOpenURL:telURL]) {
        [[UIApplication sharedApplication] openURL:telURL];
    }
    else {
        [Alerts showAlertViewWithTitle:@"Ошибка" message:@"Устройство не поддерживает телефонные вызовы"];
    }
}

- (IBAction)onAddressButtonClick {
    [self showMap];
}

- (IBAction)onWebsiteButtonClick {
    if (!self.company.website.length) return;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", self.company.website]];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)onMenuButtonClick:(id)sender {
    [self hideUI];
    
    UIButton *button = (UIButton *)sender;
    self.selectedMenuIndex = button.tag;
    
    switch (button.tag) {
        case 0: [self showDetails]; break;
        case 1: [self showPhotos]; break;
        case 2: [self showMenu]; break;
        case 3: [self showFeedback]; break;
        case 4: [self showEvents]; break;
        case 5: [self showMap]; break;
    }
}

- (void)showDetails {
    self.title = @"Просмотр заведения";
    
    self.thumbnailImageView.image = kPLACEHOLDER_IMAGE;
    if (self.company.logoURL) {
        [self.thumbnailImageView setImageWithURL:self.company.logoURL placeholderImage:kPLACEHOLDER_IMAGE]; 
    }
    
    self.btnCommon.selected = YES;
    self.scrollView0.hidden = NO;
    self.btnCheckin.hidden = NO;
         
        
    UIView *fieldVisible = self.fieldType;            
    self.lblType.text = self.company.type;
    self.lblPhone.text = self.company.phone;
    if (self.company.phone.length == 0) {
        self.fieldPhone.hidden = YES;
    }
    else {
        self.fieldPhone.hidden = NO;
        fieldVisible = self.fieldPhone;
    }
    self.lblAddress.text = self.company.address;
    if (self.company.address.length == 0) {
        self.fieldAddress.hidden = YES;
    }
    else {
        self.fieldAddress.hidden = NO;
        CGRect frame = self.fieldAddress.frame;
        frame.origin.y = fieldVisible.frame.origin.y + fieldVisible.frame.size.height;
        self.fieldAddress.frame = frame;
        fieldVisible = self.fieldAddress;
    }
    self.lblWebsite.text = self.company.website;
    if (self.company.website.length == 0) {
        self.fieldSite.hidden = YES;
    }
    else {
        self.fieldSite.hidden = NO;
        CGRect frame = self.fieldSite.frame;
        frame.origin.y = fieldVisible.frame.origin.y + fieldVisible.frame.size.height;
        self.fieldSite.frame = frame;
        fieldVisible = self.fieldSite;
    }
    self.lblBusinessHours.text = self.company.hours;
    if (self.company.hours.length == 0) {
        self.fieldHours.hidden = YES;
    }   
    else {
        self.fieldHours.hidden = NO;
        CGRect frame = self.fieldHours.frame;
        frame.origin.y = fieldVisible.frame.origin.y + fieldVisible.frame.size.height;
        self.fieldHours.frame = frame;
        fieldVisible = self.fieldHours;
    }
    
    int sy = 8;

    CGRect frame = self.lblAboutTitle.frame;
    frame.origin.y = fieldVisible.frame.origin.y + fieldVisible.frame.size.height + sy;
    self.lblAboutTitle.frame = frame;
    
    self.lblAbout.text = self.company.description;
    frame = self.lblAbout.frame;
    frame.origin.y = self.lblAboutTitle.frame.origin.y + self.lblAboutTitle.frame.size.height + sy;
    frame.size.width = 280;
    self.lblAbout.frame = frame;
    [self.lblAbout sizeToFit];
    
    int height = self.lblAbout.frame.origin.y + self.lblAbout.frame.size.height;
    
    self.scrollView0.contentSize = CGSizeMake(320, height + 10 + 8);
    self.borderButton0.frame = CGRectMake(10, -10, 300, self.scrollView0.contentSize.height);
}

- (void)showPhotos {
    self.title = @"Фото заведения";
    self.btnPhoto.selected = YES;
    self.scrollView1.hidden = NO;
    self.btnCheckin.hidden = NO;
    
    self.lblPhotosCount.text = [NSString stringWithFormat:@"%d фотографий", self.company.images.count];
    
    if (self.photosView) {
        for (UIView *view in self.photosView.subviews) {
            [view removeFromSuperview];
        }
    }
    else {
        self.photosView = [[UIView alloc] init];
        [self.scrollView1 addSubview:self.photosView];
    }
    
    int row = 0, column = 0;
    for (int i = 0; i < self.company.images.count; i++) {
        UIButton *btn = [[UIButton alloc] init];
        btn.frame = CGRectMake(column * 72 + 20, row * 72, 64, 64);
        UIActivityIndicatorView *hud = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        hud.center = CGPointMake(btn.frame.size.width / 2, btn.frame.size.height / 2);
        [btn addSubview:hud];
        [hud startAnimating];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[self.company.thumbnails objectAtIndex:i]];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:data];
                [btn setImage:image forState:UIControlStateNormal];
                [hud removeFromSuperview];
                [hud stopAnimating];
            });
        });
        [btn addTarget:self action:@selector(onPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        btn.tag = i;
        [self.photosView addSubview:btn];
        
        if (++column == 4) {
            row++;
            column = 0;
        }
    }
    self.photosView.frame = CGRectMake(0, self.lblPhotosCount.frame.origin.y + lblPhotosCount.frame.size.height + 8, 320, (row + 1) * 72);
    self.scrollView1.contentSize = CGSizeMake(320, self.photosView.frame.origin.y + self.photosView.frame.size.height + 20);
    self.borderButton1.frame = CGRectMake(10, -10, 300, self.scrollView1.contentSize.height);
}

- (void)onPhotoButtonClick:(id)sender {
    PhotosView *view = [[PhotosView alloc] init];
    view.photosURLs = self.company.images;
    view.currentPhoto = ((UIButton *)sender).tag;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)showMenu {
    self.title = @"Меню";
    self.btnMenu.selected = YES;
    self.tableView.hidden = NO;
    self.btnCheckin.hidden = NO;
    [self.tableView reloadData];
}

- (void)showFeedback {
    self.title = @"Отзывы";
    
    self.btnFeedback.selected = YES;
    self.scrollView2.hidden = NO;
    self.btnAddFeedback.hidden = NO;
    
    if (self.feedbackView) {
        for (UIView *view in self.feedbackView.subviews) {
            [view removeFromSuperview];
        }
    }
    else {
        self.feedbackView = [[UIView alloc] init];
        [self.scrollView2 addSubview:self.feedbackView];
    }
    
    if (!self.company.feedbacks.count) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 280, 1)];
        lbl.text = @"У данного заведения нету отзывов, разместите первый отзыв при помощи кнопки внизу";
        lbl.numberOfLines = 0;
        lbl.lineBreakMode = UILineBreakModeWordWrap;
        lbl.font = [UIFont boldSystemFontOfSize:16];
        lbl.backgroundColor = [UIColor clearColor];
        [lbl sizeToFit];
        [self.feedbackView addSubview:lbl];
    }
    
    int height = 0;
    for (int i = 0; i < self.company.feedbacks.count; i++) {
        int dy = 10;
        int ySpace = 8;
        Feedback *item = [self.company.feedbacks objectAtIndex:i];
        
        // Отношение к заведению
        UIImageView *view1 = [[UIImageView alloc] initWithFrame:CGRectMake(20, height + dy, 32, 32)];
        UIImage *image1;
        switch (item.attitude) {
            case -1: image1 = [UIImage imageNamed:@"checkin_negativeButton.png"]; break;
            case 1: image1 = [UIImage imageNamed:@"checkin_positiveButton.png"]; break;
            default: image1 = [UIImage imageNamed:@"checkin_neutralButton.png"];
        }
        view1.image = image1;
        [self.feedbackView addSubview:view1];
        
        // Автор отзыва
        UILabel *view2 = [[UILabel alloc] initWithFrame:CGRectMake(view1.frame.origin.x + view1.frame.size.width + 8, view1.frame.origin.y, 280 - view1.frame.size.width, 0)];
        view2.font = [UIFont boldSystemFontOfSize:14];
        view2.text = item.userName;
        [view2 sizeToFit];
        [self.feedbackView addSubview:view2];
        
        // Характер отзыва
        UIImageView *view25 = [[UIImageView alloc] initWithFrame:CGRectMake(view2.frame.origin.x, view2.frame.origin.y + view2.frame.size.height + ySpace, 200, 3)];
        UIColor *color;
        switch (item.attitude) {
            case -1: color = [UIColor colorWithRed:217/255.0 green:6/255.0 blue:27/255.0 alpha:1]; break;
            case 0: color = [UIColor colorWithRed:205/255.0 green:205/255.0 blue:205/255.0 alpha:1]; break;
            case 1: color = [UIColor colorWithRed:0 green:127/255.0 blue:62/255.0 alpha:1]; break;
        }
        view25.backgroundColor = color;
        [self.feedbackView addSubview:view25];
        
        // Текст отзыва
        UILabel *view3 = [[UILabel alloc] initWithFrame:CGRectMake(view25.frame.origin.x, view25.frame.origin.y + view25.frame.size.height + ySpace, 280 - view1.frame.size.width - 8, 0)];
        view3.font = [UIFont systemFontOfSize:14];
        view3.text = item.text;
        view3.numberOfLines = 0;
        view3.lineBreakMode = UILineBreakModeWordWrap;
        [view3 sizeToFit];
        view3.backgroundColor = [UIColor clearColor];
        [self.feedbackView addSubview:view3];
        
        // Дата отзыва
        UILabel *view4 = [[UILabel alloc] initWithFrame:CGRectMake(view3.frame.origin.x, view3.frame.origin.y + view3.frame.size.height + ySpace, view3.frame.size.width, 0)];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"dd MMMM MM:ss";
        view4.font = [UIFont systemFontOfSize:12];
        view4.textColor = [UIColor grayColor];
        view4.text = [df stringFromDate:item.date];
        view4.backgroundColor = [UIColor clearColor];
        [view4 sizeToFit];
        [self.feedbackView addSubview:view4];
        
        // Просто линия
        UIImageView *view5 = [[UIImageView alloc] initWithFrame:CGRectMake(10, view4.frame.origin.y + view4.frame.size.height + ySpace, 300, 1)];
        view5.backgroundColor = [UIColor colorWithRed:228/255.0 green:212/255.0 blue:196/255.0 alpha:1];
        if (i != self.company.feedbacks.count - 1) {
            [self.feedbackView addSubview:view5];
        }
        
        height += dy + view2.frame.size.height + ySpace + view25.frame.size.height + ySpace + view3.frame.size.height + ySpace + view4.frame.size.height + ySpace + view5.frame.size.height;
    }
    
    self.feedbackView.frame = CGRectMake(0, 0, 320, height);
    self.scrollView2.contentSize = CGSizeMake(320, height + 10);
    self.borderButton2.frame = CGRectMake(10, -10, 300, self.scrollView2.contentSize.height);
}

- (void)showEvents {
    self.title = @"События";
    self.btnEvents.selected = YES;
    self.btnCheckin.hidden = NO;
    self.tableView.hidden = NO;
    [self.tableView reloadData];
}

- (void)showMap {
    //self.btnCheckin.hidden = NO;
    self.btnMap.selected = YES;
    
    MapViewController *map = [[MapViewController alloc] init];
    map.company = self.company;
    [self.navigationController pushViewController:map animated:YES];
}

#pragma mark - UITableViewDataSource
//- (int)numberOfSectionsInTableView:(UITableView *)tableView {
//    //if (self.selectedMenuIndex == 4) return self.company.events.count;
//    //else return 1;
//}

//- (UIView *)tableView:(UITableView *)tableView_ viewForHeaderInSection:(NSInteger)section {
//    if (self.selectedMenuIndex != 4) return [[UIView alloc] initWithFrame:CGRectZero];
//    
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
//        case 0: headerText = @"Сегодня"; break;
//        case 1: headerText = @"Вчера"; break;
//        case 2: headerText = @"3 дня назад"; break;
//        case 3: headerText = @"На прошлой неделе"; break;
//        case 4: headerText = @"Давно"; break;
//    }
//    label.text = headerText;
//    
//    return view;
//}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.selectedMenuIndex) {
        case 2: return (self.company.menu.count) ? self.company.menu.count : 1;
        case 4: return self.company.events.count ? self.company.events.count : 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kMenuCell = @"MenuCell";
    static NSString *kEventCell = @"EventCell";
    static NSString *kOrdinaryCell = @"OrdinaryCell";
    
    UITableViewCell *cell;
    
    if (self.selectedMenuIndex == 2) {
        if (!self.company.menu.count) {
            cell = [tableView_ dequeueReusableCellWithIdentifier:kOrdinaryCell];
            if (!cell) { cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kOrdinaryCell]; }
            cell.textLabel.text = @"У заведения не добавлено меню";
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
        }
        else {
            cell = [tableView_ dequeueReusableCellWithIdentifier:kMenuCell];
            if (!cell) {
                [[NSBundle mainBundle] loadNibNamed:kMenuCell owner:self options:nil];
                cell = self.menuCell;
                self.menuCell = nil;
            }
            MenuItem *menuItem = [self.company.menu objectAtIndex:indexPath.row];
            UIImageView *view1 = (UIImageView *)[cell viewWithTag:1];
            UILabel *view2 = (UILabel *)[cell viewWithTag:2];
            UILabel *view3 = (UILabel *)[cell viewWithTag:3];
            
            view1.image = kPLACEHOLDER_IMAGE;
            if (menuItem.imageURL) {
                [view1 setImageWithURL:menuItem.imageURL placeholderImage:kPLACEHOLDER_IMAGE];
            }
            view2.text = menuItem.title;
            view3.text = [NSString stringWithFormat:@"%.2f руб.", menuItem.price]; 
        }
    }
    else if (self.selectedMenuIndex == 4) {
        if (!self.company.events.count) {
            cell = [tableView_ dequeueReusableCellWithIdentifier:kOrdinaryCell];
            if (!cell) { cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kOrdinaryCell]; }
            cell.textLabel.text = @"У заведения нет событий";
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
        }
        else {
            cell = [tableView_ dequeueReusableCellWithIdentifier:kEventCell];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:kEventCell owner:self options:nil] objectAtIndex:0];
            }
            Event *event = [self.company.events objectAtIndex:indexPath.row];
            UIImageView *view1 = (UIImageView *)[cell viewWithTag:1];
            UILabel *view2 = (UILabel *)[cell viewWithTag:2];
            UITextView *view3 = (UITextView *)[cell viewWithTag:3];
            UILabel *view4 = (UILabel *)[cell viewWithTag:4];
            
            view1.image = kPLACEHOLDER_IMAGE;
            if (event.imageURL) {
                [view1 setImageWithURL:event.imageURL placeholderImage:kPLACEHOLDER_IMAGE];
            }
            view2.text = event.title;
            view3.text = event.text;
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"dd MMMM MM:ss";
            view4.text = [df stringFromDate:event.date];
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Event *event = [self.company.events objectAtIndex:indexPath.row];
    NSString *title = event.title;
    NSString *text = event.text;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:text delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.mainMenu onAuthorizeButtonClick];
    }
}

#pragma mark - CatalogDelegate
- (void)handleLoading {
    if (--_toLoad == 0) {
        self.company.delegate = nil;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

- (void)companyDidFailWithError:(NSString *)error {
    [self handleLoading];
}

- (void)companyDetailsDidLoad {
    [self showDetails];
    [self handleLoading];
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)companyImagesDidLoad {
    [self handleLoading];
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)companyMenuDidLoad {
    [self handleLoading];
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)companyFeedbacksDidLoad {
    [self handleLoading];
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)companyEventsDidLoad {
    [self handleLoading];
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end
