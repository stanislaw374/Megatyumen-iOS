//
//  EventsView.m
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EventsView.h"
#import "Authorization.h"
#import "AuthorizationView.h"
#import "Alerts.h"
#import "CheckinCatalogView.h"
#import "Events.h"
#import "Event.h"
#import "Constants.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "UIImage+Thumbnail.h"
#import "New.h"
#import "NewDetailView.h"

@interface EventsView()
@property (nonatomic, strong) CheckinCatalogView *checkinView;
@property (nonatomic, strong) Events *events;
@property (nonatomic, strong) MainMenu *mainMenu;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic) int offset;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) NewDetailView *newDetailView;
- (void)didPassAuthorization:(NSNotification *)notification;
- (void)didGetEvents:(NSNotification *)notification;
- (void)getEvents;
@end

@implementation EventsView
@synthesize tableView;
@synthesize btnCheckin;
@synthesize checkinView = _checkinView;
@synthesize eventCell = _eventCell;
//@synthesize loadingCell = _loadingCell;
@synthesize events = _events;
@synthesize mainMenu = _mainMenu;
@synthesize hud = _hud;
@synthesize offset = _offset;
@synthesize isLoading = _isLoading;
@synthesize newDetailView = _newDetailView;

- (CheckinCatalogView *)checkinView {
    if (!_checkinView) {
        _checkinView = [[CheckinCatalogView alloc] init];
    }
    return _checkinView;
}

- (NewDetailView *)newDetailView {
    if (!_newDetailView) {
        _newDetailView = [[NewDetailView alloc] init];
    }
    return _newDetailView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Новости компаний";
        
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
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPassAuthorization:) name:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetEvents:) name:kNOTIFICATION_DID_GET_EVENTS object:nil];
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addMainButton];
    [self.mainMenu addAuthorizeButton];
    
    self.events = [[Events alloc] init];
    self.tableView.rowHeight = 104;
    
    //[self.events getItems:self.offset];
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];    
//    
//    //[self performSelectorInBackground:@selector(getEvents) withObject:nil];
//}

- (void)viewDidUnload
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_GET_EVENTS object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];
    [self setTableView:nil];
    [self setBtnCheckin:nil];
    //[self setLoadingCell:nil];
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
    if (![Authorization sharedAuthorization].isAuthorized) {
        [Alerts showAuthorizationAlertViewWithTitle:@"Ошибка" message:@"Для того, чтобы отметиться, нужно авторизоваться" delegate:self];
        return;
    }
    
    if (!self.checkinView) {
        self.checkinView = [[CheckinCatalogView alloc] init];
    }
    [self.navigationController pushViewController:self.checkinView animated:YES];
}

-(void)onMainButtonClick {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//- (void)didPassAuthorization:(NSNotification *)notification {
//    self.navigationItem.rightBarButtonItem = nil;
//}

//- (void)didGetEvents:(NSNotification *)notification {
//    self.isLoading = NO;
//    [self.tableView reloadData];
//    [self.hud hide:YES];
//}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Event *event = [self.events.items objectAtIndex:indexPath.row];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:event.title message:event.text delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    Event *selectedEvent = [self.events.items objectAtIndex:indexPath.row];
    self.newDetailView.currentNew = selectedEvent;
    [self.navigationController pushViewController:self.newDetailView animated:YES];
}

//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//    return indexPath;
//}

#pragma mark - UITableViewDataSource

//- (int)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}

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
    return (!self.events.isLoaded) ? 1 : self.events.items.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kEventCell = @"EventCell";
    static NSString *kLoadingCell = @"LoadingCell";
    
    UITableViewCell *cell;
    if ((!self.events.isLoaded && !self.isLoading) || indexPath.row == self.events.items.count) {
        cell = [tableView_ dequeueReusableCellWithIdentifier:kLoadingCell];
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:kLoadingCell owner:self options:nil];
        //cell = self.loadingCell;
        //self.loadingCell = nil;
        cell = [nibs objectAtIndex:0];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:cell animated:YES];
        UILabel *lbl = (UILabel *)[cell viewWithTag:1];
        //CGSize winSize = [UIScreen mainScreen].bounds.size;
        hud.xOffset = -lbl.frame.size.width / 2;
        self.isLoading = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.events getItems];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isLoading = NO;
                [self.tableView reloadData];
                [self.hud hide:YES]; 
            });
        });
    }
    else {
        cell = [tableView_ dequeueReusableCellWithIdentifier:kEventCell];
        if (!cell) {
            [[NSBundle mainBundle] loadNibNamed:kEventCell owner:self options:nil];
            cell = self.eventCell;
            self.eventCell = nil;
        }
        Event *item = [self.events.items objectAtIndex:indexPath.row];
        UIImageView *view1 = (UIImageView *)[cell viewWithTag:1];
        UILabel *view2 = (UILabel *)[cell viewWithTag:2];
        UITextView *view3 = (UITextView *)[cell viewWithTag:3];
        UILabel *view4 = (UILabel *)[cell viewWithTag:4];
        
        [view1 setImageWithURL:item.image placeholderImage:kPLACEHOLDER_IMAGE andScaleTo:view1.frame.size];
        view2.text = item.companyName;
        view3.text = item.title;
        //view3.text = item.announce;

        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"dd MMMM hh:mm";
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

@end
