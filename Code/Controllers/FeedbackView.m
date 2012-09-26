//
//  FeedbackView.m
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FeedbackView.h"
#import "Authorization.h"
#import "AuthorizationView.h"
#import "Alerts.h"
#import "CheckinCatalogView.h"
#import "Feedbacks.h"
#import "Feedback.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "Config.h"
#import "UIImage+Thumbnail.h"
#import "CatalogItemView.h"
#import "CatalogItem.h"
#import "User.h"
#import "Company.h"

@interface FeedbackView() <FeedbackDelegate>
@property (nonatomic, strong) NSMutableArray *feedbacks;
@property (nonatomic, strong) MainMenu *mainMenu;
@property (nonatomic) int page;
@property (nonatomic) int height;
@property (nonatomic) BOOL isLoading;
@end

@implementation FeedbackView
@synthesize btnAddFeedback;
@synthesize tableView = _tableView;
@synthesize borderView = _borderView;
@synthesize feedbacks = _feedbacks;
@synthesize mainMenu = _mainMenu;
@synthesize page = _page;
@synthesize height = _height;
@synthesize isLoading = _isLoading;

- (NSMutableArray *)feedbacks {
    if (!_feedbacks) {
        _feedbacks = [[NSMutableArray alloc] init];
    }
    return _feedbacks;
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

    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addMainButton];
    [self.mainMenu addAuthorizeButton];
    
    self.borderView.layer.borderWidth = 1;
    self.borderView.layer.borderColor = [[UIColor colorWithRed:228/255.0 green:212/255.0 blue:196/255.0 alpha:1] CGColor];
    self.borderView.layer.cornerRadius = 10;
    
    self.title = @"Отзывы";
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSDate date] forKey:@"LastLaunchDate"];
    
    NSLog(@"Set last launch date");
    
    [userDefaults synchronize];
    
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //[Feedback get:self.page++ withDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (void)viewDidUnload
{
    [self setBtnAddFeedback:nil];
    [self setTableView:nil];
    [self setBorderView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onFeedbackButtonClick {
    if (![User sharedUser].token) {
        [Alerts showAuthorizationAlertViewWithTitle:@"Ошибка" message:@"Для того, чтобы добавить отзыв, нужно авторизоваться" delegate:self];
        return;
    }
    
    CheckinCatalogView *view = [[CheckinCatalogView alloc] init];
    [self.navigationController pushViewController:view animated:YES];
    view.isFeedbackMode = YES;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.mainMenu onAuthorizeButtonClick];
    }
}

#pragma mark - UITableViewDataSource
- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.feedbacks.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 69 + 8 + 21 + 11;
    
    if (indexPath.row == self.feedbacks.count) height = 100;
    else {
        NSString *text = ((Feedback *)[self.feedbacks objectAtIndex:indexPath.row]).text;
        
        CGSize sizeThatFits = [text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(229, 9999) lineBreakMode:UILineBreakModeWordWrap];
        
        NSLog(@"Height that fits: %lf", sizeThatFits.height);
        
        height += sizeThatFits.height;
    }
    
    NSLog(@"%@ : row: %d, height: %f", NSStringFromSelector(_cmd), indexPath.row, height);
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kFeedbackCell = @"FeedbackCell";
    static NSString *kLoadingCell = @"LoadingCell2";
    
    UITableViewCell *cell;
    if (indexPath.row == self.feedbacks.count) {
        if (!cell) {
            NSArray *xibs = [[NSBundle mainBundle] loadNibNamed:kLoadingCell owner:self options:nil];
            cell = [xibs objectAtIndex:0];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:cell animated:YES];
            UILabel *lbl = (UILabel *)[cell viewWithTag:1];
            hud.xOffset = -lbl.frame.size.width / 2;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        if (!_isLoading) {
            _isLoading = YES;
            [Feedback get:self.page++ withDelegate:self];        
        }
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:kFeedbackCell];
        if (!cell) {
            NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:kFeedbackCell owner:nil options:nil];
            cell = [nibs objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        Feedback *f = [self.feedbacks objectAtIndex:indexPath.row];
        int height = 0;
        int dy = 8;
        UIImage *imgAttitude;
        switch (f.attitude) {
            case -1: imgAttitude = [UIImage imageNamed:@"checkin_negativeButton.png"]; break;
            case 1: imgAttitude = [UIImage imageNamed:@"checkin_positiveButton.png"]; break;
            default: imgAttitude = [UIImage imageNamed:@"checkin_neutralButton.png"];
        }
        UIImageView *imgvAttitude = (UIImageView *)[cell viewWithTag:1];
        height += 11 + imgvAttitude.frame.size.height + dy;
        imgvAttitude.image = [imgAttitude thumbnailByScalingProportionallyAndCroppingToSize:CGSizeMake(32, 32)]; 
        
        UILabel *lblUserName = (UILabel *)[cell viewWithTag:2];
        lblUserName.text = f.companyName;
        height += lblUserName.frame.size.height + dy;
        
        UILabel *lblCompanyName = (UILabel *)[cell viewWithTag:3];
        lblCompanyName.text = f.userName;
        height += lblCompanyName.frame.size.height + dy;
        
        UIImageView *imgvAttitude2 = (UIImageView *)[cell viewWithTag:4];
        UIColor *color;
        switch (f.attitude) {
            case -1: color = [UIColor colorWithRed:217/255.0 green:6/255.0 blue:27/255.0 alpha:1]; break;
            case 0: color = [UIColor colorWithRed:205/255.0 green:205/255.0 blue:205/255.0 alpha:1]; break;
            case 1: color = [UIColor colorWithRed:0 green:127/255.0 blue:62/255.0 alpha:1]; break;
        }
        imgvAttitude2.backgroundColor = color;
        height += imgvAttitude2.frame.size.height + dy;
        
        UILabel *lblText = (UILabel *)[cell viewWithTag:5];
        lblText.text = f.text;
        CGRect frame = lblText.frame;
        frame.size.width = 229;
        lblText.frame = frame;
        [lblText sizeToFit];
        height += lblText.frame.size.height + dy;
        
        UILabel *lblDate = (UILabel *)[cell viewWithTag:6];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"dd MMMM hh:mm"];
        lblDate.text = [df stringFromDate:f.date];
        frame = lblDate.frame;
        frame.origin.y = lblText.frame.origin.y + lblText.frame.size.height + 8;
        lblDate.frame = frame;
        height += lblDate.frame.size.height + dy + 11;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    Feedback *f = [self.feedbacks objectAtIndex:indexPath.row];
    Company *company = [[Company alloc] init];
    company.ID = f.companyID;
    company.name = f.companyName;

    CatalogItemView *view = [[CatalogItemView alloc] init];
    view.company = company;
    [self.navigationController pushViewController:view animated:YES];    
}

#pragma mark - FeedbackDelegate
- (void)feedbacksDidLoad:(NSArray *)feedbacks {
    [self.feedbacks addObjectsFromArray:feedbacks];
    [self.tableView reloadData];
    _isLoading = NO;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)feedbacksDidFailWithError:(NSString *)error {
    _isLoading = NO;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
