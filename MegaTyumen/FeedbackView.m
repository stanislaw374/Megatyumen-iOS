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

@interface FeedbackView()
@property (nonatomic, strong) AuthorizationView *authorizationView;
@property (nonatomic, strong) CheckinCatalogView *checkinView;
@property (nonatomic, strong) Feedbacks *feedback;
@property (nonatomic, strong) UIView *feedbackView;
@property (nonatomic, strong) MainMenu *mainMenu;
- (void)didPassAuthorization:(NSNotification *)notification;
- (void)didGetFeedback:(NSNotification *)notification;
@end

@implementation FeedbackView
@synthesize btnAddFeedback;
@synthesize scrollView = _scrollView;
@synthesize borderButton = _borderButton;
@synthesize authorizationView = _authorizationView;
@synthesize checkinView = _checkinView;
@synthesize feedback = _feedback;
@synthesize feedbackView = _feedbackView;
@synthesize hud = _hud;
@synthesize mainMenu = _mainMenu;

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
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addMainButton];
    [self.mainMenu addAuthorizeButton];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPassAuthorization:) name:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetFeedback:) name:kNOTIFICATION_DID_GET_FEEDBACK object:nil];
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.feedback = [[Feedbacks alloc] init];
    [self.feedback getItems];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //[self performSelectorInBackground:@selector(getFeedback) withObject:nil];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_GET_FEEDBACK object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];
    [self setBtnAddFeedback:nil];
    [self setScrollView:nil];
    [self setBorderButton:nil];
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
    
    if (!self.checkinView) {
        self.checkinView = [[CheckinCatalogView alloc] init];
    }
    [self.navigationController pushViewController:self.checkinView animated:YES];
    self.checkinView.isFeedbackMode = YES;
}

- (void)didPassAuthorization:(NSNotification *)notification {
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)getFeedback {
    @autoreleasepool {
        [self.feedback getItems];
    }    
}

- (void)didGetFeedback:(NSNotification *)notification {
    NSLog(@"Did get Feedback");
    
    if (self.feedbackView) {
        for (UIView *view in self.feedbackView.subviews) {
            [view removeFromSuperview];
        }
    }
    else {
        self.feedbackView = [[UIView alloc] init];
        [self.scrollView addSubview:self.feedbackView];
    }
    
    int height = 0;
    for (int i = 0; i < self.feedback.items.count; i++) {
        int dy = 10;
        int ySpace = 8;
        Feedback *item = [self.feedback.items objectAtIndex:i];
        
        // Отношение к заведению
        UIImageView *view1 = [[UIImageView alloc] initWithFrame:CGRectMake(10, height + dy, 32, 32)];
        UIImage *image1;
        switch (item.attitude) {
            case -1: image1 = [UIImage imageNamed:@"checkin_negativeButton.png"]; break;
            case 1: image1 = [UIImage imageNamed:@"checkin_positiveButton.png"]; break;
            default: image1 = [UIImage imageNamed:@"checkin_neutralButton.png"];
        }
        view1.image = image1;
        [self.feedbackView addSubview:view1];
        
//        // Ава
//        UIImageView *view1 = [[UIImageView alloc] initWithFrame:CGRectMake(10, height + dy, 32, 32)];
//        [view1 setImageWithURL:item.imageUrl placeholderImage:kPLACEHOLDER_IMAGE andScaleTo:CGSizeMake(32, 32)];
//        [self.feedbackView addSubview:view1];
        
        // Автор отзыва
        UILabel *view2 = [[UILabel alloc] initWithFrame:CGRectMake(view1.frame.origin.x + view1.frame.size.width + 8, view1.frame.origin.y, 280 - view1.frame.size.width, 20)];
        view2.font = [UIFont boldSystemFontOfSize:14];
        view2.text = item.user;
        view2.backgroundColor = [UIColor clearColor];
        [self.feedbackView addSubview:view2];
        
        // Название заведения
        UILabel *view225 = [[UILabel alloc] initWithFrame:CGRectMake(view2.frame.origin.x, view2.frame.origin.y + view2.frame.size.height + ySpace, view2.frame.size.width, 20)];
        view225.font = [UIFont italicSystemFontOfSize:14];
        view225.text = item.to;
        view225.backgroundColor = [UIColor clearColor];
        [self.feedbackView addSubview:view225];
        
        // Характер отзыва
        UIImageView *view25 = [[UIImageView alloc] initWithFrame:CGRectMake(view225.frame.origin.x, view225.frame.origin.y + view225.frame.size.height + ySpace, 200, 3)];
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
        view4.font = [UIFont systemFontOfSize:14];
        view4.textColor = [UIColor grayColor];
        view4.backgroundColor = [UIColor clearColor];
        view4.text = [df stringFromDate:item.date];
        [view4 sizeToFit];
        [self.feedbackView addSubview:view4];
        
        // Просто линия
        UIImageView *view5 = [[UIImageView alloc] initWithFrame:CGRectMake(0, view4.frame.origin.y + view4.frame.size.height + ySpace, 300, 1)];
        view5.backgroundColor = [UIColor colorWithRed:228/255.0 green:212/255.0 blue:196/255.0 alpha:1];
        if (i != self.feedback.items.count - 1) {
            [self.feedbackView addSubview:view5];
        }
        
        height += dy + view2.frame.size.height + ySpace + view225.frame.size.height + ySpace + view25.frame.size.height + ySpace + view3.frame.size.height + ySpace + view4.frame.size.height + ySpace + view5.frame.size.height;
    }
    
    self.feedbackView.frame = CGRectMake(10, 10, 300, height);
    self.feedbackView.layer.borderWidth = 1;
    self.feedbackView.layer.borderColor = [[UIColor colorWithRed:228/255.0 green:212/255.0 blue:196/255.0 alpha:1] CGColor];
    self.feedbackView.layer.cornerRadius = 10;
    self.feedbackView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6f];
    self.scrollView.contentSize = CGSizeMake(320, height + 10);
    
    [self.hud hide:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.mainMenu onAuthorizeButtonClick];
    }
}


@end