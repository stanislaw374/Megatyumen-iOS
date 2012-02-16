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

@interface EventsView()
//@property (nonatomic, strong) AuthorizationView *authorizationView;
@property (nonatomic, strong) CheckinCatalogView *checkinView;
@property (nonatomic, strong) Events *events;
@property (nonatomic, strong) MainMenu *mainMenu;
@property (nonatomic, strong) MBProgressHUD *hud;
- (void)didPassAuthorization:(NSNotification *)notification;
- (void)didGetEvents:(NSNotification *)notification;
@end

@implementation EventsView
@synthesize tableView;
@synthesize btnCheckin;
//@synthesize authorizationView = _authorizationView;
@synthesize checkinView = _checkinView;
@synthesize eventCell = _eventCell;
@synthesize events = _events;
@synthesize mainMenu = _mainMenu;
@synthesize hud = _hud;

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
        self.title = @"Новости компаний";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPassAuthorization:) name:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetEvents:) name:kNOTIFICATION_DID_GET_EVENTS object:nil];
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
    [self.mainMenu addMainButton];
    [self.mainMenu addAuthorizeButton];
    
    self.events = [[Events alloc] init];
    self.tableView.rowHeight = 104;
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self.events getItems]; 
//    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    
    //[self performSelectorInBackground:@selector(getEvents) withObject:nil];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_GET_EVENTS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];
    [self setTableView:nil];
    [self setBtnCheckin:nil];
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

//-(void)onAuthorizeButtonClick {
//    if (!self.authorizationView) {
//        self.authorizationView = [[AuthorizationView alloc] init];
//    }
//    [self.navigationController pushViewController:self.authorizationView animated:YES];
//}

- (void)didPassAuthorization:(NSNotification *)notification {
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)didGetEvents:(NSNotification *)notification {
    [self.tableView reloadData];
    [self.hud hide:YES];
}

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
    return self.events.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kEventCell = @"EventCell";
    
    UITableViewCell *cell;
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
    
    [view1 setImageWithURL:item.imageUrl placeholderImage:kPLACEHOLDER_IMAGE andScaleTo:view1.frame.size];
//    view1.image = [Constants placeholderImage];
//    if (item.imageUrl.path) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            UIImage *image = [[UIImage imageWithData:[NSData dataWithContentsOfURL:item.imageUrl]] thumbnailByScalingProportionallyAndCroppingToSize:view1.frame.size];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                view1.image = image;
//            });        
//        });    
//    }
    
//    view2.text = item.user;
//    view3.text = item.text;
    //[view3 sizeToFit];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"dd MMMM MM:ss";
    view4.text = [df stringFromDate:item.date];
    
    return cell;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.mainMenu onAuthorizeButtonClick];
    }
}

@end
