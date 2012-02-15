//
//  MainView.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 18.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

/*
 jsonData={"request":"items_count"}
 [14.02.12 16:42:00] Кунст Кирилл: количество отзывов анонсов новостей
 [14.02.12 16:42:09] Кунст Кирилл: {"comments_count":"1176","events_count":"482","announces_count":"0"} 
 */

#import "MainView.h"
#import "AuthorizationView.h"
#import "Authorization.h"
#import "NewsView.h"
#import "CustomBadge.h"
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
#import "Constants.h"

#define KEY_REQUEST @"request"
#define VALUE_ITEMS_COUNT @"items_count"
#define KEY_FEEDBACK_COUNT @"comments_count"
#define KEY_ANNOUNCES_COUNT @"announces_count"
#define KEY_COMPANY_NEWS_COUNT @"events_count"
#define KEY_JSON_DATA @"jsonData"

@interface MainView()

@property (nonatomic, strong) News *news;
@property (nonatomic, strong) Announces *announces;
@property (nonatomic, strong) Events *events;
@property (nonatomic, strong) Feedbacks *feedback;
@property (strong, nonatomic) NewsView *newsView;
@property (strong, nonatomic) CheckinCatalogView *checkinView;
@property (nonatomic, strong) CatalogView *catalogView;
@property (nonatomic, strong) EventsView *eventsView;
@property (nonatomic, strong) FeedbackView *feedbackView;
@property (nonatomic, strong) AnnouncesView *announcesView;
@property (nonatomic, strong) YMapView *yMapView;
@property (nonatomic, strong) Catalog *catalog;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) MainMenu *mainMenu;
@property (nonatomic) int timer;

- (void)refreshBadges;
- (void)refreshNewsBadge:(int)value;
- (void)refreshFeedbacksBadge:(int)value;
- (void)refreshAnnouncesBadge:(int)value;
- (void)refreshEventsBadge:(int)value;
- (BOOL)checkNetworkAvailability;
- (void)didCheckin:(NSNotification *)notification;
- (void)onTimerFired:(NSTimer *)timer;
- (void)didPassAuthorization:(NSNotification *)notification;
@end

@implementation MainView
@synthesize newsButton = _newsButton;
@synthesize feedbackButton = _feedbackButton;
@synthesize announcesButton = _announcesButton;
@synthesize eventsButton = _eventsButton;
//@synthesize newsBadge = _newsBadge;
//@synthesize data = _data;
@synthesize newsView = _newsView;
//@synthesize authorizationView = _authorizationView;
//@synthesize navController = _navController;
@synthesize checkinButton = _checkinButton;
@synthesize checkinLabel = _checkinLabel;
@synthesize checkinView = _checkinView;
@synthesize news = _news;
@synthesize catalogView = _catalogView;
@synthesize eventsView = _eventsView;
@synthesize feedbackView = _feedbackView;
@synthesize announcesView = _announcesView;
//@synthesize feedbackBadge = _feedbackBadge;
//@synthesize announceBadge = _announceBadge;
//@synthesize eventsBadge = _eventsBadge;
@synthesize announces = _announces;
@synthesize feedback = _feedback;
@synthesize events = _events;
@synthesize yMapView = _yMapView;
@synthesize catalog = _catalog;
@synthesize hud = _hud;
@synthesize mainMenu = _mainMenu;
@synthesize timer = _timer;

#pragma mark - Lazy Instantiation

- (CatalogView *)catalogView {
    if (!_catalogView) {
        _catalogView = [[CatalogView alloc] init];
    }
    return _catalogView; 
}

- (NewsView *)newsView {
    if (!_newsView) {
        _newsView = [[NewsView alloc] init];
    }
    return _newsView;
}

- (YMapView *)yMapView {
    if (!_yMapView) {
        _yMapView = [[YMapView alloc] init];
        _yMapView.loadAllMarkers = YES;
        _yMapView.showDisclosureButton = YES;
        _yMapView.title = @"Карта";
    }
    return _yMapView;
}

- (FeedbackView *)feedbackView {
    if (!_feedbackView) {
        _feedbackView = [[FeedbackView alloc] init];
    }
    return _feedbackView;
}

- (AnnouncesView *)announcesView {
    if (!_announcesView) {
        _announcesView = [[AnnouncesView alloc] init];
    }
    return _announcesView;
}

- (EventsView *)eventsView {
    if (!_eventsView) {
        _eventsView = [[EventsView alloc] init];
    }
    return _eventsView;
}

- (CheckinCatalogView *)checkinView {
    if (!_checkinView) {
        _checkinView = [[CheckinCatalogView alloc] init];
    }
    return _checkinView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"МегаЕда";
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
    [self.mainMenu addAuthorizeButton];
    //[self.mainMenu addBackButton];
    //[self.mainMenu addMainButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPassAuthorization:) name:kNOTIFICATION_DID_AUTHORIZE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCheckin:) name:kNOTIFICATION_DID_CHECKIN object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetNewsCount:) name:@"didGetNewsCount" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetFeedbackCount:) name:@"didGetFeedback" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetAnnouncesCount:) name:@"didGetAnnounces" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetEventsCount:) name:@"didGetEvents" object:nil];

    //[self performSelectorInBackground:@selector(initBadges) withObject:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self refreshBadges];
    });
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_AUTHORIZE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_CHECKIN object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didGetNewsCount" object:nil];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didGetFeedback" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didGetAnnounces" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didGetEvents" object:nil];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Helpers

- (BOOL)checkNetworkAvailability {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (!appDelegate.networkListener.isNetworkAvailable) {
        [Alerts showAlertViewWithTitle:@"Нет подключения к интернету" message:@"Нет подключения к интернету. Для работы данного приложения необходим доступ в Интернет"];
        return NO;
    }
    return YES;
}

- (void)refreshBadges {    
    int newsCount = [News count];// - [News readCount];
    //int feedbackCount = [Feedbacks count];// - [Feedbacks readCount];
    //int announcesCount = [Announces count];// - [Announces readCount];
    //int eventsCount = [Events count];// - [Events readCount];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:VALUE_ITEMS_COUNT, KEY_REQUEST, nil];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    [request setPostValue:[jsonWriter stringWithObject:dict] forKey:KEY_JSON_DATA];
    //request.delegate = self;
    //request.didFinishSelector = @selector(didRegister:);
    [request startSynchronous];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict2 = [parser objectWithString:[request responseString]];
    int feedbackCount = [[dict2 objectForKey:KEY_FEEDBACK_COUNT] intValue];
    int announcesCount = [[dict2 objectForKey:KEY_ANNOUNCES_COUNT] intValue];
    int eventsCount = [[dict2 objectForKey:KEY_COMPANY_NEWS_COUNT] intValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshNewsBadge:newsCount];
        [self refreshFeedbacksBadge:feedbackCount];
        [self refreshAnnouncesBadge:announcesCount];
        [self refreshEventsBadge:eventsCount];
    });
}

- (void)refreshFeedbacksBadge:(int)value {
    CustomBadge *feedbackBadge = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%d", value]];
    CGRect frame = feedbackBadge.frame;
    frame.origin.x = self.feedbackButton.frame.origin.x + self.feedbackButton.frame.size.width - frame.size.width / 2;
    frame.origin.y = self.feedbackButton.frame.origin.y - feedbackBadge.frame.size.height / 2;
    feedbackBadge.frame = frame;
    [self.view addSubview:feedbackBadge];
}

- (void)refreshAnnouncesBadge:(int)value {
    CustomBadge *announcesBadge = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%d", value]];
    CGRect frame = announcesBadge.frame;
    frame.origin.x = self.announcesButton.frame.origin.x + self.announcesButton.frame.size.width - frame.size.width / 2;
    frame.origin.y = self.announcesButton.frame.origin.y - announcesBadge.frame.size.height / 2;
    announcesBadge.frame = frame;
    [self.view addSubview:announcesBadge];
}

- (void)refreshEventsBadge:(int)value {
    CustomBadge *eventsBadge = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%d", value]];
    CGRect frame = eventsBadge.frame;
    frame.origin.x = self.eventsButton.frame.origin.x + self.eventsButton.frame.size.width - frame.size.width / 2;
    frame.origin.y = self.eventsButton.frame.origin.y - eventsBadge.frame.size.height / 2;
    eventsBadge.frame = frame;
    [self.view addSubview:eventsBadge];
}

- (void)refreshNewsBadge:(int)value {
    CustomBadge *newsBadge = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%d", value]];
    CGRect frame = newsBadge.frame;
    frame.origin.x = self.newsButton.frame.origin.x + self.newsButton.frame.size.width - frame.size.width / 2;
    frame.origin.y = self.newsButton.frame.origin.y - newsBadge.frame.size.height / 2;
    newsBadge.frame = frame;
    [self.view addSubview:newsBadge];
}

-(void)didPassAuthorization:(NSNotification *)notification {
    self.navigationItem.rightBarButtonItem = nil;
}

//- (void)didGetNewsCount:(NSNotification *)notification {
//    CustomBadge *newsBadge = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%d", self.news.todayCount]];
//    CGRect frame = newsBadge.frame;
//    frame.origin.x = self.newsButton.frame.origin.x + self.newsButton.frame.size.width - frame.size.width / 2;
//    frame.origin.y = self.newsButton.frame.origin.y - newsBadge.frame.size.height / 2;
//    newsBadge.frame = frame;
//    [self.view addSubview:newsBadge];
//    
//    //if (++self.loadedBadges == 4) [self.hud hide:YES];
//}

//- (void)didGetFeedbackCount:(NSNotification *)notification {
//    CustomBadge *feedbackBadge = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%d", self.feedback.items.count]];
//    CGRect frame = feedbackBadge.frame;
//    frame.origin.x = self.feedbackButton.frame.origin.x + self.feedbackButton.frame.size.width - frame.size.width / 2;
//    frame.origin.y = self.feedbackButton.frame.origin.y - feedbackBadge.frame.size.height / 2;
//    feedbackBadge.frame = frame;
//    [self.view addSubview:feedbackBadge];
//    
//    //if (++self.loadedBadges == 4) [self.hud hide:YES];
//}
//
//- (void)didGetAnnouncesCount:(NSNotification *)notification {
//    CustomBadge *announcesBadge = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%d", self.announces.items.count]];
//    CGRect frame = announcesBadge.frame;
//    frame.origin.x = self.announcesButton.frame.origin.x + self.announcesButton.frame.size.width - frame.size.width / 2;
//    frame.origin.y = self.announcesButton.frame.origin.y - announcesBadge.frame.size.height / 2;
//    announcesBadge.frame = frame;
//    [self.view addSubview:announcesBadge];
//    
//    //if (++self.loadedBadges == 4) [self.hud hide:YES];
//}
//
//- (void)didGetEventsCount:(NSNotification *)notification {
//    CustomBadge *eventsBadge = [CustomBadge customBadgeWithString:[NSString stringWithFormat:@"%d", self.events.items.count ]];
//    CGRect frame = eventsBadge.frame;
//    frame.origin.x = self.eventsButton.frame.origin.x + self.eventsButton.frame.size.width - frame.size.width / 2;
//    frame.origin.y = self.eventsButton.frame.origin.y - eventsBadge.frame.size.height / 2;
//    eventsBadge.frame = frame;
//    [self.view addSubview:eventsBadge];
//    
//    //if (++self.loadedBadges == 4) [self.hud hide:YES];
//}

- (IBAction)onNewsButtonClick {
    if (![self checkNetworkAvailability]) return;
    [self.navigationController pushViewController:self.newsView animated:YES];
}

- (IBAction)onCheckinButtonClick {
    if (![Authorization sharedAuthorization].isAuthorized) {
        [Alerts showAuthorizationAlertViewWithTitle:@"Ошибка" message:@"Для того, чтобы отметиться, нужно авторизоваться" delegate:self];
        return;
    }

    [self.navigationController pushViewController:self.checkinView animated:YES];
}

- (IBAction)onCatalogButtonClick {
    if (![self checkNetworkAvailability]) return;
    [self.navigationController pushViewController:self.catalogView animated:YES];
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
    if (![self checkNetworkAvailability]) return;
    [self.navigationController pushViewController:self.yMapView animated:YES];
    
//    for (CatalogItem *item in self.catalog.items.allValues) {
//        [self.yMapView addAnnotationForCatalogItem:item];
//    }
}

- (IBAction)onFeedbackButtonClick {
    if (![self checkNetworkAvailability]) return;
    [self.navigationController pushViewController:self.feedbackView animated:YES];
}

- (IBAction)onAnnouncesButtonClick {
    if (![self checkNetworkAvailability]) return;
    [self.navigationController pushViewController:self.announcesView animated:YES];
}

- (IBAction)onEventsButtonClick {
    if (![self checkNetworkAvailability]) return;
    [self.navigationController pushViewController:self.eventsView animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.mainMenu onAuthorizeButtonClick];
    }
}

@end
