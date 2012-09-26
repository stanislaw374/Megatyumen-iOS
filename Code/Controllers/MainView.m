//
//  MainView.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 18.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MainView.h"
#import "AuthorizationView.h"
#import "Authorization.h"
#import "NewsView.h"
#import "News.h"
#import "SBJson.h"
#import "CheckinCatalogView.h"
#import "Alerts.h"
#import "CatalogView.h"
#import "EventsView.h"
#import "FeedbackView.h"
#import "AnnouncesView.h"
#import "Announces.h"
#import "Feedbacks.h"
#import "Events.h"
#import "YMapView.h"
#import "Catalog.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "ASIFormDataRequest.h"
#import "Config.h"
#import "Items.h"

#import "Reachability.h"
#import "User.h"
#import "MapViewController.h"
#import "News.h"
#import "New.h"

@interface MainView() <NewsDelegate>
//@property (nonatomic, strong) News *news;
//@property (nonatomic, strong) Announces *announces;
//@property (nonatomic, strong) Events *events;
//@property (nonatomic, strong) Feedbacks *feedback;
//@property (strong, nonatomic) NewsView *newsView;
//@property (strong, nonatomic) CheckinCatalogView *checkinView;
//@property (nonatomic, strong) CatalogView *catalogView;
//@property (nonatomic, strong) EventsView *eventsView;
//@property (nonatomic, strong) FeedbackView *feedbackView;
//@property (nonatomic, strong) AnnouncesView *announcesView;
//@property (nonatomic, strong) YMapView *yMapView;
//@property (nonatomic, strong) Catalog *catalog;
@property (nonatomic, strong) MainMenu *mainMenu;
@property (nonatomic) int timer;
- (void)refreshBadges;
- (void)refreshNewsBadge:(int)value;
- (void)refreshFeedbacksBadge:(int)value;
- (void)refreshAnnouncesBadge:(int)value;
- (void)refreshEventsBadge:(int)value;
- (void)userDidCheckin:(NSNotification *)notification;
- (void)onTimerFired:(NSTimer *)timer;
@end

@implementation MainView
@synthesize newsButton = _newsButton;
@synthesize feedbackButton = _feedbackButton;
@synthesize announcesButton = _announcesButton;
@synthesize eventsButton = _eventsButton;
@synthesize seenNews = _seenNews;
@synthesize seenAnnounces = _seenAnnounces;
@synthesize seenFeedbacks = _seenFeedbacks;
@synthesize seenCompaniesNews = _seenCompaniesNews;

@synthesize newsBadge = _newsBadge;
//@synthesize data = _data;
//@synthesize newsView = _newsView;
//@synthesize authorizationView = _authorizationView;
//@synthesize navController = _navController;
@synthesize checkinButton = _checkinButton;
@synthesize checkinLabel = _checkinLabel;
//@synthesize checkinView = _checkinView;
//@synthesize news = _news;
//@synthesize catalogView = _catalogView;
//@synthesize eventsView = _eventsView;
//@synthesize feedbackView = _feedbackView;
//@synthesize announcesView = _announcesView;
@synthesize feedbackBadge = _feedbackBadge;
@synthesize announceBadge = _announceBadge;
@synthesize eventsBadge = _eventsBadge;
//@synthesize announces = _announces;
//@synthesize feedback = _feedback;
//@synthesize events = _events;
//@synthesize yMapView = _yMapView;
//@synthesize catalog = _catalog;
//@synthesize hud = _hud;
@synthesize mainMenu = _mainMenu;
@synthesize timer = _timer;

#pragma mark - Lazy Instantiation

//- (CatalogView *)catalogView {
//    if (!_catalogView) {
//        _catalogView = [[CatalogView alloc] init];
//    }
//    return _catalogView; 
//}
//
//- (NewsView *)newsView {
//    if (!_newsView) {
//        _newsView = [[NewsView alloc] init];
//    }
//    return _newsView;
//}
//
//- (YMapView *)yMapView {
//    if (!_yMapView) {
//        _yMapView = [[YMapView alloc] init];
//        _yMapView.title = @"Карта";
//    }
//    return _yMapView;
//}
//
//- (FeedbackView *)feedbackView {
//    if (!_feedbackView) {
//        _feedbackView = [[FeedbackView alloc] init];
//    }
//    return _feedbackView;
//}
//
//- (AnnouncesView *)announcesView {
//    if (!_announcesView) {
//        _announcesView = [[AnnouncesView alloc] init];
//    }
//    return _announcesView;
//}
//
//- (EventsView *)eventsView {
//    if (!_eventsView) {
//        _eventsView = [[EventsView alloc] init];
//    }
//    return _eventsView;
//}
//
//- (CheckinCatalogView *)checkinView {
//    if (!_checkinView) {
//        _checkinView = [[CheckinCatalogView alloc] init];
//    }
//    return _checkinView;
//}
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
    
    [User sharedUser].delegate = self;
    [[User sharedUser] login];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    if ([User sharedUser].token != nil)
        [self.mainMenu addLogoutButton];
    else
        [self.mainMenu addAuthorizeButton];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPassAuthorization:) name:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCheckin:) name:kNOTIFICATION_DID_CHECKIN object:nil];
    
    [self refreshBadges];
    self.title = @"МегаЕда";
    
    self.seenNews = NO;
    self.seenFeedbacks = NO;
    self.seenCompaniesNews = NO;
    self.seenAnnounces = NO;
}


- (void)viewDidUnload
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_CHECKIN object:nil];

    [self setNewsButton:nil];
    [self setCheckinButton:nil];
    [self setCheckinLabel:nil];
    [self setFeedbackButton:nil];
    [self setAnnouncesButton:nil];
    [self setEventsButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self refreshBadges];
    [super viewWillAppear:YES];
        
    
}

#pragma mark - UserDelegate
- (void)userLoginDidFailWithError:(NSString *)error {
    [User sharedUser].delegate = nil;
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
//    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
}

- (void)userDidLoginWithMesssage:(NSString *)message {
    
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Badges loading
- (void)refreshBadges {        
    [News get:0 withDelegate:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSDictionary *items = [Items getCount];
        //int newsCount = [[items objectForKey:KEY_NEWS_COUNT] intValue];
        int eventsCount = [[items objectForKey:KEY_EVENTS_COUNT] intValue];
        int feedbacksCount = [[items objectForKey:KEY_FEEDBACKS_COUNT] intValue];
        int announcesCount = [[items objectForKey:KEY_ANNOUNCES_COUNT] intValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self refreshNewsBadge:newsCount];
            [self refreshAnnouncesBadge:announcesCount];
            [self refreshFeedbacksBadge:feedbacksCount];
            [self refreshEventsBadge:eventsCount];
        });
    });
}

- (void)refreshFeedbacksBadge:(int)value {
    if (value != 0 && self.seenFeedbacks == NO)
    {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (![appDelegate isFirstTimeLaunch]) {    
            self.feedbackBadge = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%d", value]];
            self.feedbackBadge.badgeInsetColor = [UIColor colorWithRed:1 green:172 / 255.0 blue:53 / 255.0 alpha:1];
            self.feedbackBadge.badgeFrameColor = [UIColor redColor];
            CGRect frame = self.feedbackBadge.frame;
            frame.origin.x = self.feedbackButton.frame.origin.x + self.feedbackButton.frame.size.width - frame.size.width / 2;
            frame.origin.y = self.feedbackButton.frame.origin.y - self.feedbackBadge.frame.size.height / 2;
            self.feedbackBadge.frame = frame;
            [self.view addSubview:self.feedbackBadge];
        }
    } else {
        [self.feedbackBadge setHidden:YES];
    }
    
}

- (void)refreshAnnouncesBadge:(int)value {
    if (value != 0 && self.seenAnnounces == NO) {
        self.announceBadge = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%d", value]];
        self.announceBadge.badgeInsetColor = [UIColor colorWithRed:1 green:172 / 255.0 blue:53 / 255.0 alpha:1];
        self.announceBadge.badgeFrameColor = [UIColor redColor];
        CGRect frame = self.announceBadge.frame;
        frame.origin.x = self.announcesButton.frame.origin.x + self.announcesButton.frame.size.width - frame.size.width / 2;
        frame.origin.y = self.announcesButton.frame.origin.y - self.announceBadge.frame.size.height / 2;
        self.announceBadge.frame = frame;
        [self.view addSubview:self.announceBadge];
    }
    else {
        [self.announceBadge setHidden:YES];
    }
    
}

- (void)refreshEventsBadge:(int)value {
    if (value != 0 && self.seenCompaniesNews == NO) {
        self.eventsBadge = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%d", value]];
        self.eventsBadge.badgeInsetColor = [UIColor colorWithRed:1 green:172 / 255.0 blue:53 / 255.0 alpha:1];
        self.eventsBadge.badgeFrameColor = [UIColor redColor];
        CGRect frame = self.eventsBadge.frame;
        frame.origin.x = self.eventsButton.frame.origin.x + self.eventsButton.frame.size.width - frame.size.width / 2;
        frame.origin.y = self.eventsButton.frame.origin.y - self.eventsBadge.frame.size.height / 2;
        self.eventsBadge.frame = frame;
        [self.view addSubview:self.eventsBadge];
    } else {
        [self.eventsBadge setHidden:YES];
    }
    
}

- (void)refreshNewsBadge:(int)value {
    if (value != 0 && self.seenNews == NO){
        self.newsBadge = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%d", value]];
        self.newsBadge.badgeInsetColor = [UIColor colorWithRed:1 green:172 / 255.0 blue:53 / 255.0 alpha:1];
        self.newsBadge.badgeFrameColor = [UIColor redColor];
        CGRect frame = self.newsBadge.frame;
        frame.origin.x = self.newsButton.frame.origin.x + self.newsButton.frame.size.width - frame.size.width / 2;
        frame.origin.y = self.newsButton.frame.origin.y - self.newsBadge.frame.size.height / 2;
        self.newsBadge.frame = frame;
        [self.view addSubview:self.newsBadge]; 
    } else {
        [self.newsBadge setHidden:YES];
    }
    
}
#pragma mark -

- (IBAction)showNews {
    if (![Reachability reachabilityForInternetConnection].isReachable) {
        [Alerts showAlertViewWithTitle:@"Нет доступа в Интернет" message:@"Для работы данного приложения необходим доступ в Интернет"];
        return;
    }
    NewsView *newsView = [[NewsView alloc] init];
    [self setSeenNews:YES];
    [self.newsBadge setHidden:YES];
    [self.navigationController pushViewController:newsView animated:YES];
}

- (IBAction)onCheckinButtonClick {
    if (![Reachability reachabilityForInternetConnection].isReachable)  {
        [Alerts showAlertViewWithTitle:@"Нет доступа в Интернет" message:@"Для работы данного приложения необходим доступ в Интернет"];
        return;
    }
    if (![User sharedUser].token) {
        [Alerts showAuthorizationAlertViewWithTitle:@"Ошибка" message:@"Для того, чтобы отметиться, нужно авторизоваться" delegate:self];
        return;
    }

    CheckinCatalogView *checkinCatalogView = [[CheckinCatalogView alloc] init];
    [self.navigationController pushViewController:checkinCatalogView animated:YES];
}

- (IBAction)onCatalogButtonClick {
    if (![Reachability reachabilityForInternetConnection].isReachable)  {
        [Alerts showAlertViewWithTitle:@"Нет доступа в Интернет" message:@"Для работы данного приложения необходим доступ в Интернет"];
        return;
    }
    CatalogView *catalogView = [[CatalogView alloc] init];
    [self.navigationController pushViewController:catalogView animated:YES];
}

- (void)didCheckin:(NSNotification *)notification {
    self.checkinLabel.text = @"Вы не можете отмечаться еще 30 минут";
    self.checkinButton.hidden = YES;
    self.checkinLabel.hidden = NO;
    self.timer = 30;
    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(onTimerFired:) userInfo:nil repeats:YES];
}

- (void)onTimerFired:(NSTimer *)timer {
    self.checkinLabel.text = [NSString stringWithFormat:@"Вы не можете отмечаться еще %d минут", --self.timer];
    
    if (!self.timer) {
        self.checkinLabel.hidden = YES;
        self.checkinButton.hidden = NO;
        [timer invalidate];
    }
}

- (IBAction)onMapButtonClick {
    if (![Reachability reachabilityForInternetConnection].isReachable)  {
        [Alerts showAlertViewWithTitle:@"Нет доступа в Интернет" message:@"Для работы данного приложения необходим доступ в Интернет"];
        return;
    }
    
    MapViewController *map = [[MapViewController alloc] init];
    [self.navigationController pushViewController:map animated:YES];
}

- (IBAction)onFeedbackButtonClick {
    if (![Reachability reachabilityForInternetConnection].isReachable)  {
        [Alerts showAlertViewWithTitle:@"Нет доступа в Интернет" message:@"Для работы данного приложения необходим доступ в Интернет"];
        return;
    }
    FeedbackView *feedbackView = [[FeedbackView alloc] init];
    [self setSeenFeedbacks:YES];
    [self.feedbackBadge setHidden:YES];
    [self.navigationController pushViewController:feedbackView animated:YES];
}

- (IBAction)onAnnouncesButtonClick {
    if (![Reachability reachabilityForInternetConnection].isReachable)  {
        [Alerts showAlertViewWithTitle:@"Нет доступа в Интернет" message:@"Для работы данного приложения необходим доступ в Интернет"];
        return;
    }
    AnnouncesView *announcesView = [[AnnouncesView alloc] init];
    [self setSeenAnnounces:YES];
    [self.announceBadge setHidden:YES];
    [self.navigationController pushViewController:announcesView animated:YES];
}

- (IBAction)onEventsButtonClick {
    if (![Reachability reachabilityForInternetConnection].isReachable) {
        [Alerts showAlertViewWithTitle:@"Нет доступа в Интернет" message:@"Для работы данного приложения необходим доступ в Интернет"];
        return;
    }
    EventsView *eventsView = [[EventsView alloc] init];
    [self setSeenCompaniesNews:YES];
    [self.eventsBadge setHidden:YES];
    [self.navigationController pushViewController:eventsView animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.mainMenu onAuthorizeButtonClick];
    }
}

#pragma mark - NewsDelegate
- (void)newsDidLoad:(NSArray *)news {
    int count = 0;
    for (New *n in news) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *ndc = [calendar components:NSDayCalendarUnit fromDate:n.date];
        NSDateComponents *tdc = [calendar components:NSDayCalendarUnit fromDate:[NSDate date]];
        if (ndc.day == tdc.day) count++; 
    }
    [self refreshNewsBadge:count];
}

- (void)newsDidFailWithError:(NSString *)error {
    [self refreshNewsBadge:0];
}

@end
