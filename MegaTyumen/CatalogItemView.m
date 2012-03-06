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
#import "Constants.h"
#import "PhotosView.h"

@interface CatalogItemView()
//@property (nonatomic, strong) AuthorizationView *authorizationView;
@property (nonatomic) int selectedMenuIndex;
@property (nonatomic, strong) CheckinView *checkinView;
@property (nonatomic, strong) YMapView *catalogItemMapView;
//@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) PhotosView *photosViewController;
@property (nonatomic, strong) MainMenu *mainMenu;
@property (nonatomic) BOOL hasMenu;
@property (nonatomic) BOOL hasFeedbacks;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) CLLocationManager *locationManager;
//@property (nonatomic) BOOL isLoading;

- (void)showInfo;
- (void)setInfo;
- (void)showCommon;
- (void)showPhotos;
//- (void)didGetPhotos:(NSNotification *)notification;
- (void)showMenu;
//- (void)didGetMenu:(NSNotification *)notification;
- (void)showFeedback;
//- (void)didGetFeedback:(NSNotification *)notification;
- (void)showEvents;
//- (void)didGetEvents:(NSNotification *)notification;
- (void)showMap;
- (void)hideUI;
@end

@implementation CatalogItemView
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
@synthesize currentItem = _currentItem;
//@synthesize authorizationView = _authorizationView;
@synthesize photosView = _photosView;
@synthesize lblPhotosCount;
@synthesize scrollView2;
@synthesize borderButton2;
@synthesize tableView;
@synthesize menuCell;
@synthesize btnAddFeedback;
@synthesize selectedMenuIndex = _selectedMenuIndex;
@synthesize feedbackView = _feedbackView;
@synthesize eventCell;
@synthesize checkinView = _checkinView;
@synthesize catalogItemMapView = _catalogItemMapView;
@synthesize hud = _hud;
//@synthesize locationManager = _locationManager;
@synthesize parentCatalogCategoryView = _parentCatalogCategoryView;
@synthesize catalog = _catalog;
@synthesize photosViewController = _photosViewController;
@synthesize mainMenu = _mainMenu;
@synthesize hasMenu = _hasMenu;
@synthesize hasFeedbacks = _hasFeedbacks;
@synthesize locationManager = _locationManager;

#pragma mark - Lazy Instantiation
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.hud];
    }
    return _hud;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.currentItem getDetailsWithLocation:newLocation]; 
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setInfo];
            //[self.hud hide:YES];            
        });
    });
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.currentItem getDetails]; 
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setInfo];
            //[self.hud hide:YES];            
        });
    });
}

#pragma mark -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPassAuthorization:) name:@"didPassAuthorization" object:nil]; 
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetPhotos:) name:@"didGetPhotos" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetMenu:) name:@"didGetMenu" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetFeedback:) name:@"didGetCatalogItemFeedback" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetEvents:) name:@"didGetCatalogItemEvents" object:nil];
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
    
//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    self.locationManager.distanceFilter = kCLDistanceFilterNone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.nameLabel.text = @"";
    self.thumbnailImageView.image = nil;
    self.addressLabel.text = @"";
    //[self.distanceButton setTitle:@"" forState:UIControlStateNormal];
    self.distanceButton.hidden = YES;
    self.lblType.text = self.lblPhone.text = self.lblAddress.text = self.lblWebsite.text = self.lblBusinessHours.text = self.lblAbout.text = @"";
    
    [self hideUI];    
    [self showInfo];
    //[self showCommon];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
    [self setEventCell:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didPassAuthorization:(NSNotification *)notification {
    self.navigationItem.rightBarButtonItem = nil;
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
    if (![Authorization sharedAuthorization].isAuthorized) {
        [Alerts showAuthorizationAlertViewWithTitle:@"Ошибка" message:@"Для того, чтобы отметиться, нужно авторизоваться" delegate:self];
        return;
    }
    
    if (!self.checkinView) {
        self.checkinView = [[CheckinView alloc] init];
    }
    self.checkinView.currentItem = self.currentItem;
    [self.navigationController pushViewController:self.checkinView animated:YES];
    self.checkinView.isFeedbackMode = NO;
}

- (IBAction)onAddFeedbackButtonClick:(id)sender {
    if (![Authorization sharedAuthorization].isAuthorized) {
        [Alerts showAuthorizationAlertViewWithTitle:@"Ошибка" message:@"Для того, чтобы добавить отзыв, нужно авторизоваться" delegate:self];
        return;
    }
    
    if (!self.checkinView) {
        self.checkinView = [[CheckinView alloc] init];
    }
    self.checkinView.currentItem = self.currentItem;
    [self.navigationController pushViewController:self.checkinView animated:YES];
    self.checkinView.isFeedbackMode = YES;
}

- (IBAction)onTypeButtonClick {
    for (CatalogCategory *category in [self.catalog.categories objectAtIndex:0]) {
        if ([category.name rangeOfString:self.currentItem.type].location != NSNotFound && self.parentCatalogCategoryView) {
            //self.parentCatalogCategoryView.currentCategory = self
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
    }
}

- (IBAction)onPhoneButtonClick {
    NSString *phone = [[self.currentItem.phone componentsSeparatedByString:@","] objectAtIndex:0];
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
    if (!self.currentItem.website.length) return;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", self.currentItem.website]];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)onMenuButtonClick:(id)sender {
    [self hideUI];
    
    UIButton *button = (UIButton *)sender;
    self.selectedMenuIndex = button.tag;
    
    //[self.hud show:YES];
    
    switch (button.tag) {
        case 0: [self showCommon]; break;
        case 1: [self showPhotos]; break;
        case 2: [self showMenu]; break;
        case 3: [self showFeedback]; break;
        case 4: [self showEvents]; break;
        case 5: [self showMap]; break;
    }
}

- (void)showInfo {
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.hud show:YES];
    
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        [self.locationManager startUpdatingLocation];
    }
    else {        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self.currentItem getDetails]; 
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setInfo];    
                //[self showCommon];
            });
        });
    }
}

- (void)setInfo {
    [self.thumbnailImageView setImageWithURL:self.currentItem.logo placeholderImage:kPLACEHOLDER_IMAGE andScaleTo:self.thumbnailImageView.frame.size]; 
    self.nameLabel.text = self.currentItem.name;
    self.addressLabel.text = self.currentItem.address;
    [self.distanceButton setTitle:self.currentItem.distanceString forState:UIControlStateNormal];
    self.distanceButton.hidden = NO;
    [self.distanceButton sizeToFit]; 
    
    [self.hud hide:YES];
    
    [self showCommon];
}

- (void)showCommon {
    self.btnCommon.selected = YES;
    self.scrollView0.hidden = NO;
    self.btnCheckin.hidden = NO;
    self.title = @"Просмотр заведения";    
    
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //[self.hud show:YES];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.currentItem getCommon];        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lblType.text = self.currentItem.type;
            self.lblPhone.text = self.currentItem.phone;
            self.lblAddress.text = self.currentItem.address;
            self.lblWebsite.text = self.currentItem.website;
            self.lblBusinessHours.text = self.currentItem.weekdayHours;
            
            self.lblAbout.text = self.currentItem.description;
            CGRect frame = self.lblAbout.frame;
            frame.size.width = 280;
            self.lblAbout.frame = frame;
            NSLog(@"%@ : description width: %lf", NSStringFromSelector(_cmd), self.lblAbout.frame.size.width);
            [self.lblAbout sizeToFit];
            
            int height = self.lblAbout.frame.origin.y + self.lblAbout.frame.size.height;
            
            self.scrollView0.contentSize = CGSizeMake(320, height + 10 + 8);
            self.borderButton0.frame = CGRectMake(10, -10, 300, self.scrollView0.contentSize.height);
            
            [self.hud hide:YES];
        });
    });    
}

- (void)showPhotos {
    self.title = @"Фото заведения";
    
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.hud show:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.currentItem getPhotos];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.btnPhoto.selected = YES;
            self.scrollView1.hidden = NO;
            self.btnCheckin.hidden = NO;
            
            self.lblPhotosCount.text = [NSString stringWithFormat:@"%d фотографий", self.currentItem.photos.count];
            
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
            for (int i = 0; i < self.currentItem.photos.count; i++) {
                UIButton *btn = [[UIButton alloc] init];
                [btn setImageWithURL:[self.currentItem.photos objectAtIndex:i] placeholderImage:kPLACEHOLDER_IMAGE andScaleTo:CGSizeMake(64, 64)];
                [btn addTarget:self action:@selector(onPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                btn.frame = CGRectMake(column * 72 + 20, row * 72, 64, 64);
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
            
            //[MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.hud hide:YES];
        });
    });    
}

- (void)onPhotoButtonClick:(id)sender {
    if (1) {
        //self.photosViewController = [[PhotosView alloc] initWithPhotosUrls:self.currentItem.photosUrls];
    }
    [self.navigationController pushViewController:self.photosViewController animated:YES];
    self.photosViewController.page = ((UIButton *)sender).tag;
}

- (void)showMenu {
    self.title = @"Меню";
    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.hud show:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.currentItem getMenu];
        dispatch_async(dispatch_get_main_queue(), ^{    
            self.btnMenu.selected = YES;
            self.tableView.hidden = NO;
            self.btnCheckin.hidden = NO;
            [self.tableView reloadData];
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.hud hide:YES];
        });
    });    
}

- (void)showFeedback {
    self.title = @"Отзывы";
    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.hud show:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.currentItem getFeedbacks];
        dispatch_async(dispatch_get_main_queue(), ^{
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
            
            if (!self.currentItem.feedbacks.count) {
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
            for (int i = 0; i < self.currentItem.feedbacks.count; i++) {
                int dy = 10;
                int ySpace = 8;
                Feedback *item = [self.currentItem.feedbacks objectAtIndex:i];
                
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
                if (i != self.currentItem.feedbacks.count - 1) {
                    [self.feedbackView addSubview:view5];
                }
                
                height += dy + view2.frame.size.height + ySpace + view25.frame.size.height + ySpace + view3.frame.size.height + ySpace + view4.frame.size.height + ySpace + view5.frame.size.height;
            }
            
            self.feedbackView.frame = CGRectMake(0, 0, 320, height);
            self.scrollView2.contentSize = CGSizeMake(320, height + 10);
            self.borderButton2.frame = CGRectMake(10, -10, 300, self.scrollView2.contentSize.height);
            
            //[MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.hud hide:YES];
        });
    });    
}

- (void)showEvents {
    self.title = @"События";
    
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.hud show:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.currentItem getEvents];
        dispatch_async(dispatch_get_main_queue(), ^{            
            self.btnEvents.selected = YES;
            self.btnCheckin.hidden = NO;
            self.tableView.hidden = NO;
            [self.tableView reloadData];
            //[MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.hud hide:YES];
        });
    });
}

- (void)showMap {
    self.btnCheckin.hidden = NO;
    self.btnMap.selected = YES;
    
    if (1) {
        self.catalogItemMapView = [[YMapView alloc] init];
        self.catalogItemMapView.showBackButton = YES;
    }
    
    [self.navigationController pushViewController:self.catalogItemMapView animated:YES];
    [self.catalogItemMapView addAnnotationForCatalogItem:self.currentItem center:YES];
}

#pragma mark - UITableViewDataSource

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
//    if (self.selectedMenuIndex == 4) return self.currentItem.events.count;
//    else 
    return 1;
}

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
        case 2: 
            if (self.currentItem.menu.count) {
                self.hasMenu = YES;
                return self.currentItem.menu.count;
            }
            else {
                self.hasMenu = NO;
                return 1;
            }
        case 4: return self.currentItem.events.count; break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kMenuCell = @"MenuCell";
    static NSString *kEventCell = @"EventCell";
    static NSString *kOrdinaryCell = @"OrdinaryCell";
    
    UITableViewCell *cell;
    
    if (self.selectedMenuIndex == 2) {
        if (!self.hasMenu) {
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
            MenuItem *menuItem = [self.currentItem.menu objectAtIndex:indexPath.row];
            UIImageView *view1 = (UIImageView *)[cell viewWithTag:1];
            UILabel *view2 = (UILabel *)[cell viewWithTag:2];
            UILabel *view3 = (UILabel *)[cell viewWithTag:3];
            
            [view1 setImageWithURL:menuItem.image placeholderImage:kPLACEHOLDER_IMAGE andScaleTo:view1.frame.size];
            view2.text = menuItem.title;
            view3.text = [NSString stringWithFormat:@"%.2f руб.", menuItem.price]; 
        }
    }
    else if (self.selectedMenuIndex == 4) {
        cell = [tableView_ dequeueReusableCellWithIdentifier:kEventCell];
        if (!cell) {
            [[NSBundle mainBundle] loadNibNamed:kEventCell owner:self options:nil];
            cell = self.eventCell;
            self.eventCell = nil;
        }
        Event *item = [self.currentItem.events objectAtIndex:indexPath.row];
        UIImageView *view1 = (UIImageView *)[cell viewWithTag:1];
        UILabel *view2 = (UILabel *)[cell viewWithTag:2];
        UITextView *view3 = (UITextView *)[cell viewWithTag:3];
        UILabel *view4 = (UILabel *)[cell viewWithTag:4];
        
        [view1 setImageWithURL:item.image placeholderImage:kPLACEHOLDER_IMAGE andScaleTo:view1.frame.size];
        view2.text = item.title;
        view3.text = item.text;
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"dd MMMM MM:ss";
        view4.text = [df stringFromDate:item.date];
    }
    return cell;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.mainMenu onAuthorizeButtonClick];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Event *event = [self.currentItem.events objectAtIndex:indexPath.row];
    NSString *title = event.title;
    NSString *text = event.text;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:text delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

@end
