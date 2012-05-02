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
#import "Config.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "UIImage+Thumbnail.h"
#import "New.h"
#import "NewDetailView.h"
#import "CatalogItem.h"
#import "CatalogItemView.h"
#import "User.h"
#import "Company.h"

@interface EventsView() <EventDelegate>
{
    BOOL _isLoading;
    int _eventsCount[5];
}
@property (nonatomic, strong) NSMutableArray *events;
@property (nonatomic, strong) MainMenu *mainMenu;
@property (nonatomic) int page;
- (void)getEvents;
- (void)showEvents;
@end

@implementation EventsView
@synthesize tableView;
@synthesize btnCheckin;
@synthesize events = _events;
@synthesize mainMenu = _mainMenu;
@synthesize page = _page;

- (NSMutableArray *)events {
    if (!_events) {
        _events = [NSMutableArray array];
    }
    return _events;
}

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

    self.title = @"Новости компаний";
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addMainButton];
    [self.mainMenu addAuthorizeButton];
    
    self.tableView.rowHeight = 104;
}

- (void)viewDidUnload
{
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
    if (![User sharedUser].token) {
        [Alerts showAuthorizationAlertViewWithTitle:@"Ошибка" message:@"Для того, чтобы отметиться, нужно авторизоваться" delegate:self];
        return;
    }
    
    CheckinCatalogView *view = [[CheckinCatalogView alloc] init];
    [self.navigationController pushViewController:view animated:YES];
}

-(void)onMainButtonClick {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Event *event = [self.events objectAtIndex:indexPath.row];
    Company *company = [[Company alloc] init];
    company.ID = event.companyID;
    company.name = event.companyName;
    CatalogItemView *catalogItemView = [[CatalogItemView alloc] init];
    catalogItemView.company = company;
    [self.navigationController pushViewController:catalogItemView animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    Event *selectedEvent = [self.events objectAtIndex:indexPath.row];
    NewDetailView *view = [[NewDetailView alloc] init];
    view.currentNew = selectedEvent;
    [self.navigationController pushViewController:view animated:YES];
}

#pragma mark - UITableViewDataSource
- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kEventCell = @"EventCell";
    static NSString *kLoadingCell = @"LoadingCell";
    
    UITableViewCell *cell;
    if (indexPath.row == self.events.count) {
        cell = [tableView_ dequeueReusableCellWithIdentifier:kLoadingCell];
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:kLoadingCell owner:self options:nil];
        cell = [nibs objectAtIndex:0];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:cell animated:YES];
        UILabel *lbl = (UILabel *)[cell viewWithTag:1];
        hud.xOffset = -lbl.frame.size.width / 2;

        if (!_isLoading) {
            _isLoading = YES;
            [Event get:self.page++ withDelegate:self];
        }
    }
    else {
        cell = [tableView_ dequeueReusableCellWithIdentifier:kEventCell];
        if (!cell) {
            NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:kEventCell owner:nil options:nil];
            cell = [nibs objectAtIndex:0];
        }
        Event *event = [self.events objectAtIndex:indexPath.row];
        UIImageView *view1 = (UIImageView *)[cell viewWithTag:1];
        UILabel *view2 = (UILabel *)[cell viewWithTag:2];
        UITextView *view3 = (UITextView *)[cell viewWithTag:3];
        UILabel *view4 = (UILabel *)[cell viewWithTag:4];
        
        view1.image = kPLACEHOLDER_IMAGE;
        if (event.thumbnailURL) {
            [view1 setImageWithURL:event.thumbnailURL placeholderImage:kPLACEHOLDER_IMAGE];
//            [view1 setImageWithURL:event.thumbnailURL placeholderImage:kPLACEHOLDER_IMAGE success:^(UIImage *image) {
//                if (image) view1.image = image;
//                else view1.image = kPLACEHOLDER_IMAGE;
//            } failure:^(NSError *error) {
//                
//            }];
        }
        
        view2.text = event.companyName;
        view3.text = event.title;

        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"dd MMMM HH:mm";
        view4.text = [df stringFromDate:event.date];
    }
    
    return cell;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.mainMenu onAuthorizeButtonClick];
    }
}

#pragma mark - EventDelegate
- (void)eventsDidLoad:(NSArray *)events {
    [self.events addObjectsFromArray:events];
    [self.tableView reloadData];
    _isLoading = NO;
}

- (void)eventsDidFailWithError:(NSString *)error {
    _isLoading = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
