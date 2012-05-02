//
//  CheckinItemView.m
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 05.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CheckinItemView.h"
#import "UIImage+Thumbnail.h"
#import <CoreLocation/CoreLocation.h>
#import "UIImageView+WebCache.h"
#import "Config.h"
#import "PhotosView.h"

@interface CheckinItemView() <CompanyDelegate>
//@property (nonatomic, strong) CheckinView *checkinView;
//@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MainMenu *mainMenu;
//@property (nonatomic, strong) MBProgressHUD *hud;
- (void)initUI;
- (void)getDetails;
- (void)didCheckin:(NSNotification *)notification;
- (void)onTimerFired:(NSTimer *)timer;
- (void)showImages;
- (void)onImageClick:(UIButton *)sender;
@end

@implementation CheckinItemView
//@synthesize currentItem = _currentItem;
@synthesize imageView = _imageView;
@synthesize nameLabel = _nameLabel;
@synthesize addressLabel = _addressLabel;
@synthesize distanceButton = _distanceButton;
//@synthesize descriptionWebView = _descriptionWebView;
@synthesize borderButton = _borderButton;
@synthesize scrollView = _scrollView;
//@synthesize descriptionLabel = _descriptionLabel;
@synthesize checkinButton = _checkinButton;
@synthesize addFeedbackButton = _addFeedbackButton;
@synthesize checkinLabel = _checkinLabel;
@synthesize descriptionTextView = _descriptionTextView;
//@synthesize checkinView = _checkinView;
//@synthesize hud = _hud;
@synthesize isFeedbackMode = _isFeedbackMode;
//@synthesize locationManager = _locationManager;
@synthesize mainMenu = _mainMenu;
@synthesize userLocation = _userLocation;
@synthesize company = _company;

- (void)setIsFeedbackMode:(BOOL)isFeedbackMode {
    _isFeedbackMode = isFeedbackMode;
    
    if (self.isFeedbackMode) {
        self.checkinButton.hidden = YES;
        self.addFeedbackButton.hidden = NO;
        self.title = @"Добавить отзыв";
    }
    else {
        self.addFeedbackButton.hidden = YES;
        self.checkinButton.hidden = NO;
        self.title = @"Отметиться";
    }
}

- (void)initUI {
    self.imageView.image = kPLACEHOLDER_IMAGE;
    if (self.company.logoURL) {
        [self.imageView setImageWithURL:self.company.logoURL placeholderImage:kPLACEHOLDER_IMAGE];
    }
    self.nameLabel.text = self.company.name;
    self.addressLabel.text = self.company.address;
    //CLLocation *cl = [[CLLocation alloc] initWithLatitude:self.company.coordinate.latitude longitude:self.company.coordinate.longitude];
    //double distance = [self.userLocation distanceFromLocation:cl];
    if (self.company.distance < 1000) {
        [self.distanceButton setTitle:[NSString stringWithFormat:@"%.0lf м", self.company.distance] forState:UIControlStateNormal];
    }
    else {
        [self.distanceButton setTitle:[NSString stringWithFormat:@"%.1lf км", self.company.distance / 1000] forState:UIControlStateNormal];
    }
    [self.distanceButton sizeToFit];
    
    self.descriptionTextView.text = self.company.description;
    [self.descriptionTextView sizeToFit];
    //self.descriptionLabel.text = self.currentItem.description;
    //[self.descriptionLabel sizeToFit];
    
    //int height = 30 + self.descriptionLabel.frame.origin.y + self.descriptionLabel.frame.size.height;
    
    //self.borderButton.frame = CGRectMake(self.borderButton.frame.origin.x, self.borderButton.frame.origin.y, self.borderButton.frame.size.width, height);
    //self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, height);
}

- (void)onMainButtonClick {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)onBackButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getDetails {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self.currentItem getDetails];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self initUI];
//            [self.hud hide:YES];
//        });
//    });
}

//- (void)didGetDetails:(NSNotification *)notification { 
//    [self initUI];
//    [self.hud hide:YES];
//    
//    //NSLog(@"Получил уведомление ");
//}

- (void)didCheckin:(NSNotification *)notification {
    NSLog(@"Получил уведомление didCheckin O_O");
    
    self.checkinButton.hidden = YES;
    self.checkinLabel.hidden = NO;
    self.checkinLabel.text = @"Вы не можете отмечаться еще 30 минут";
    
    timerCounter = 30;
    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(onTimerFired:) userInfo:nil repeats:YES];
}

- (void)onTimerFired:(NSTimer *)timer {
    self.checkinLabel.text = [NSString stringWithFormat:@"Вы не можете отмечаться еще %d минут", --timerCounter];
    
    if (!timerCounter) {
        self.checkinLabel.hidden = YES;
        self.checkinButton.hidden = NO;
        [timer invalidate];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Отметиться";
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetDetails:) name:@"didGetDetails" object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCheckin:) name:@"didCheckinSuccessfully" object:nil];
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
    
//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    [self initUI];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.company.delegate = self;
    [self.company getImages];
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    
//    //[self.locationManager stopUpdatingLocation];
//}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setNameLabel:nil];
    [self setAddressLabel:nil];
    [self setDistanceButton:nil];
    //[self setDescriptionWebView:nil];
    [self setBorderButton:nil];
    [self setScrollView:nil];
    //[self setDescriptionLabel:nil];
    [self setCheckinButton:nil];
    [self setCheckinLabel:nil];
    [self setDescriptionTextView:nil];
    [self setAddFeedbackButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onCheckinButtonClick {
    CheckinView *view = [[CheckinView alloc] init];
    view.company = self.company;
    [self.navigationController pushViewController:view animated:YES];
    view.isFeedbackMode = NO;
}

- (IBAction)onAddFeedbackButtonClick {
    CheckinView *view = [[CheckinView alloc] init];
    view.company = self.company;
    [self.navigationController pushViewController:view animated:YES];
    view.isFeedbackMode = YES;
}

- (void)showImages {
    int row = 0, column = 0, height = 0;
    for (int i = 0; i < self.company.images.count; i++) {        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(column * 72 + 20, row * 72 + 8 + self.descriptionTextView.frame.size.height + self.descriptionTextView.frame.origin.y, 64, 64);
        button.tag = i;
        button.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [button addTarget:self action:@selector(onImageClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicatorView.center = CGPointMake(button.frame.size.width / 2, button.frame.size.height / 2);
        [button addSubview:activityIndicatorView];
        [activityIndicatorView startAnimating];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:[self.company.thumbnails objectAtIndex:i]];
            UIImage *image = [UIImage imageWithData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [button setImage:image forState:UIControlStateNormal];
                [activityIndicatorView stopAnimating];
                [activityIndicatorView removeFromSuperview];
            });
        });
        
        [self.scrollView addSubview:button];
        
        if (column == 3) {
            row++;
            column = 0;
            height += 72;
        }
        else {
            column++;
        }
    }
    CGRect frame = self.borderButton.frame;
    frame.size.height += height - 10;
    self.borderButton.frame = frame;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + height);
}

- (void)onImageClick:(UIButton *)sender {
    PhotosView *view = [[PhotosView alloc] init];
    view.photosURLs = self.company.images;
    view.currentPhoto = sender.tag;
    [self.navigationController pushViewController:view animated:YES];
}

#pragma mark - CompanyDelegate
- (void)companyImagesDidLoad {
    [self showImages];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.company.delegate = nil;
}

- (void)companyImagesDidFailWithError:(NSString *)error {
    self.company.delegate = nil;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
