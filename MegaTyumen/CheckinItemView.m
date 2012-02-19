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

@interface CheckinItemView()
@property (nonatomic, strong) CheckinView *checkinView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MainMenu *mainMenu;
@end

@implementation CheckinItemView
@synthesize currentItem = _currentItem;
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
@synthesize checkinView = _checkinView;
@synthesize hud = _hud;
@synthesize isFeedbackMode = _isFeedbackMode;
@synthesize locationManager = _locationManager;
@synthesize mainMenu = _mainMenu;

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
    //[self.imageView setImageWithURL:[self.currentItem.photosUrls objectAtIndex:0] placeholderImage:[UIImage imageNamed:@"placeholder.png"] andScaleTo:CGSizeMake(80, 80)];
    self.nameLabel.text = self.currentItem.name;
    self.addressLabel.text = self.currentItem.address;
    int distance = self.currentItem.distance;
    [self.distanceButton setTitle:[NSString stringWithFormat:@"%d м", distance] forState:UIControlStateNormal];
    [self.distanceButton sizeToFit];
    
    self.descriptionTextView.text = self.currentItem.description;
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
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self.currentItem getDetails];
}

- (void)didGetDetails:(NSNotification *)notification { 
    [self initUI];
    
    [self.hud hide:YES];
    
    //NSLog(@"Получил уведомление ");
}

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetDetails:) name:@"didGetDetails" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCheckin:) name:@"didCheckinSuccessfully" object:nil];
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
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.locationManager startUpdatingLocation];
    [self initUI];
    [self getDetails];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.locationManager stopUpdatingLocation];
}

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
    if (!self.checkinView) {
        self.checkinView = [[CheckinView alloc] init];
    }
    self.checkinView.currentItem = self.currentItem;
    [self.navigationController pushViewController:self.checkinView animated:YES];
    self.checkinView.isFeedbackMode = NO;
}

- (IBAction)onAddFeedbackButtonClick {
    [self onCheckinButtonClick];
    self.checkinView.isFeedbackMode = YES;
}

@end
