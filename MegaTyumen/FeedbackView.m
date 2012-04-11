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
#import "Constants.h"
#import "UIImage+Thumbnail.h"
#import "CatalogItemView.h"
#import "CatalogItem.h"

@interface FeedbackView()
//@property (nonatomic, strong) AuthorizationView *authorizationView;
@property (nonatomic, strong) CheckinCatalogView *checkinView;
@property (nonatomic, strong) Feedbacks *feedbacks;
@property (nonatomic, strong) UIView *feedbackView;
@property (nonatomic, strong) MainMenu *mainMenu;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (nonatomic) int offset;
@property (nonatomic) int height;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) CatalogItemView *companyView;
//- (void)didPassAuthorization:(NSNotification *)notification;
//- (void)didGetFeedback;
//- (void)getFeedback;
@end

@implementation FeedbackView
@synthesize btnAddFeedback;
//@synthesize scrollView = _scrollView;
//@synthesize borderButton = _borderButton;
@synthesize tableView = _tableView;
@synthesize borderView = _borderView;
//@synthesize authorizationView = _authorizationView;
@synthesize checkinView = _checkinView;
@synthesize feedbacks = _feedbacks;
@synthesize feedbackView = _feedbackView;
@synthesize hud = _hud;
@synthesize mainMenu = _mainMenu;
@synthesize offset = _offset;
@synthesize height = _height;
@synthesize isLoading = _isLoading;
@synthesize companyView = _companyView;

- (Feedbacks *)feedbacks {
    if (!_feedbacks) {
        _feedbacks = [[Feedbacks alloc] init];
    }
    return _feedbacks;
}

- (UIView *)feedbackView {
    if (!_feedbackView) {
        _feedbackView = [[UIView alloc] init];
    }
    return _feedbackView;
}

- (CheckinCatalogView *)checkinView {
    if (!_checkinView) {
        _checkinView = [[CheckinCatalogView alloc] init];
    }
    return _checkinView;
}

- (CatalogItemView *)companyView {
    if (!_companyView) {
        _companyView = [[CatalogItemView alloc] init];
    }
    return _companyView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Отзывы";
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
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetFeedback:) name:kNOTIFICATION_DID_GET_FEEDBACK object:nil];
    
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addMainButton];
    [self.mainMenu addAuthorizeButton];

    //self.height = 0;
    //self.tableView.rowHeight = 180;
    
    self.borderView.layer.borderWidth = 1;
    self.borderView.layer.borderColor = [[UIColor colorWithRed:228/255.0 green:212/255.0 blue:196/255.0 alpha:1] CGColor];
    self.borderView.layer.cornerRadius = 10;
    
    NSUserDefaults *userDefauls = [NSUserDefaults standardUserDefaults];
    [userDefauls setObject:[NSDate date] forKey:@"LastLaunchDate"];
    
    NSLog(@"Set last launch date");
    
    [userDefauls synchronize];
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    
//    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self.feedback getItems];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self didGetFeedback];
//        });
//    });
//}

- (void)viewDidUnload
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_GET_FEEDBACK object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];
    [self setBtnAddFeedback:nil];
    //[self setScrollView:nil];
    //[self setBorderButton:nil];
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
    if (![Authorization sharedAuthorization].isAuthorized) {
        [Alerts showAuthorizationAlertViewWithTitle:@"Ошибка" message:@"Для того, чтобы добавить отзыв, нужно авторизоваться" delegate:self];
        return;
    }
    
    [self.navigationController pushViewController:self.checkinView animated:YES];
    self.checkinView.isFeedbackMode = YES;
}

//- (void)didGetFeedback {
//    //NSLog(@"View did get Feedback");
//    
//    if (!self.feedbackView.window) {
//        [self.scrollView addSubview:self.feedbackView];
//    }
//    
//    if (self.feedbackView) {
//        for (UIView *view in self.feedbackView.subviews) {
//            [view removeFromSuperview];
//        }
//    }
//    
//    self.height = 0;
//    
//    
//    for (int i = self.offset; i < self.feedback.items.count; i++) {
//        int dy = 10;
//        int ySpace = 8;
//        Feedback *item = [self.feedback.items objectAtIndex:i];
//        
//        // Отношение к заведению
//        UIImageView *view1 = [[UIImageView alloc] initWithFrame:CGRectMake(10, self.height + dy, 32, 32)];
//        UIImage *image1;
//        switch (item.attitude) {
//            case -1: image1 = [UIImage imageNamed:@"checkin_negativeButton.png"]; break;
//            case 1: image1 = [UIImage imageNamed:@"checkin_positiveButton.png"]; break;
//            default: image1 = [UIImage imageNamed:@"checkin_neutralButton.png"];
//        }
//        view1.image = image1;
//        [self.feedbackView addSubview:view1];
//        
//        // Автор отзыва
//        UILabel *view2 = [[UILabel alloc] initWithFrame:CGRectMake(view1.frame.origin.x + view1.frame.size.width + 8, view1.frame.origin.y, 280 - view1.frame.size.width, 20)];
//        view2.font = [UIFont boldSystemFontOfSize:14];
//        view2.text = item.userName;
//        //view2.text = @"lol";
//        view2.backgroundColor = [UIColor clearColor];
//        [self.feedbackView addSubview:view2];
//        
//        // Название заведения
//        UILabel *view25 = [[UILabel alloc] initWithFrame:CGRectMake(view2.frame.origin.x, view2.frame.origin.y + view2.frame.size.height + ySpace, view2.frame.size.width, 20)];
//        view25.font = [UIFont italicSystemFontOfSize:14];
//        view25.text = item.companyName;
//        view25.backgroundColor = [UIColor clearColor];
//        [self.feedbackView addSubview:view25];
//        
//        // Характер отзыва
//        UIImageView *view3 = [[UIImageView alloc] initWithFrame:CGRectMake(view25.frame.origin.x, view25.frame.origin.y + view25.frame.size.height + ySpace, 200, 3)];
//        UIColor *color;
//        switch (item.attitude) {
//            case -1: color = [UIColor colorWithRed:217/255.0 green:6/255.0 blue:27/255.0 alpha:1]; break;
//            case 0: color = [UIColor colorWithRed:205/255.0 green:205/255.0 blue:205/255.0 alpha:1]; break;
//            case 1: color = [UIColor colorWithRed:0 green:127/255.0 blue:62/255.0 alpha:1]; break;
//        }
//        view3.backgroundColor = color;
//        [self.feedbackView addSubview:view3];
//        
//        // Текст отзыва
//        UILabel *view4 = [[UILabel alloc] initWithFrame:CGRectMake(view3.frame.origin.x, view3.frame.origin.y + view3.frame.size.height + ySpace, 280 - view1.frame.size.width - 8, 0)];
//        view4.font = [UIFont systemFontOfSize:14];
//        view4.text = item.text;
//        view4.numberOfLines = 0;
//        view4.lineBreakMode = UILineBreakModeWordWrap;
//        [view4 sizeToFit];
//        view4.backgroundColor = [UIColor clearColor];
//        [self.feedbackView addSubview:view4];
//        
//        // Дата отзыва
//        UILabel *view5 = [[UILabel alloc] initWithFrame:CGRectMake(view4.frame.origin.x, view4.frame.origin.y + view4.frame.size.height + ySpace, view4.frame.size.width, 0)];
//        NSDateFormatter *df = [[NSDateFormatter alloc] init];
//        df.dateFormat = @"dd MMMM hh:mm";
//        view5.font = [UIFont systemFontOfSize:14];
//        view5.textColor = [UIColor grayColor];
//        view5.backgroundColor = [UIColor clearColor];
//        view5.text = [df stringFromDate:item.date];
//        [view5 sizeToFit];
//        [self.feedbackView addSubview:view5];
//        
//        // Просто линия O_O
//        UIImageView *view6 = [[UIImageView alloc] initWithFrame:CGRectMake(0, view5.frame.origin.y + view5.frame.size.height + ySpace, 300, 1)];
//        view6.backgroundColor = [UIColor colorWithRed:228/255.0 green:212/255.0 blue:196/255.0 alpha:1];
//        if (i != self.feedback.items.count - 1) {
//            [self.feedbackView addSubview:view6];
//        }
//        //NSLog(@"1.self.height = %d", self.height);
//        self.height += dy + view2.frame.size.height + ySpace + view25.frame.size.height + ySpace + view3.frame.size.height + ySpace + view4.frame.size.height + ySpace + view5.frame.size.height + ySpace + view6.frame.size.height;
//        //NSLog(@"2.self.height = %d", self.height);
//    }
//    
//    self.feedbackView.frame = CGRectMake(10, 10, 300, self.height);
//    self.feedbackView.layer.borderWidth = 1;
//    self.feedbackView.layer.borderColor = [[UIColor colorWithRed:228/255.0 green:212/255.0 blue:196/255.0 alpha:1] CGColor];
//    self.feedbackView.layer.cornerRadius = 10;
//    self.feedbackView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6f];
//    self.scrollView.contentSize = CGSizeMake(320, self.height + 20);
//    
//    [self.hud hide:YES];
//    
////    self.offset += 1;
////    if (self.offset <= 9) {
////        [self.feedback getItems:self.offset];
////    }
//}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.mainMenu onAuthorizeButtonClick];
    }
}

#pragma mark - UITableViewDataSource
- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.feedbacks.isEntirelyLoaded) return self.feedbacks.items.count;
    else return self.feedbacks.isLoaded ? self.feedbacks.items.count + 1 : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 69 + 8 + 21 + 11;
    
    if (indexPath.row == self.feedbacks.items.count) height = 100;
    else {
        NSString *text = ((Feedback *)[self.feedbacks.items objectAtIndex:indexPath.row]).text;
        
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
    if (indexPath.row == self.feedbacks.items.count) {
        //cell = [tableView dequeueReusableCellWithIdentifier:kFeedbackCell];
        if (!cell) {
            NSArray *xibs = [[NSBundle mainBundle] loadNibNamed:kLoadingCell owner:self options:nil];
            cell = [xibs objectAtIndex:0];
            //cell.backgroundColor = [UIColor clearColor];
            //cell.backgroundView.backgroundColor = [UIColor clearColor];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:cell animated:YES];
            UILabel *lbl = (UILabel *)[cell viewWithTag:1];
            hud.xOffset = -lbl.frame.size.width / 2;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        
        if (!self.isLoading) {
            self.isLoading = YES;
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                [self.feedbacks getItems];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData]; 
                    self.isLoading = NO;
                });
            });
        }
        
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:kFeedbackCell];
        if (!cell) {
            NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:kFeedbackCell owner:nil options:nil];
            cell = [nibs objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        Feedback *f = [self.feedbacks.items objectAtIndex:indexPath.row];
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
        lblUserName.text = f.userName;
        height += lblUserName.frame.size.height + dy;
        
        UILabel *lblCompanyName = (UILabel *)[cell viewWithTag:3];
        lblCompanyName.text = f.companyName;
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
        
        //frame = cell.frame;
        //frame.size.height = height;
        //cell.frame = frame;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    Feedback *f = [self.feedbacks.items objectAtIndex:indexPath.row];
    CatalogItem *company = [[CatalogItem alloc] initWithID:f.companyID];
    self.companyView.currentItem = company;
    [self.navigationController pushViewController:self.companyView animated:YES];    
}

@end
