//
//  UserAgreementView.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 18.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UserAgreementView.h"
#import "Alerts.h"
#import "Authorization.h"
#import "MainMenu.h"

@interface UserAgreementView()
@property (nonatomic, strong) MainMenu *mainMenu;
@property (strong, nonatomic) MBProgressHUD *hud;
- (void)getUserAgreement;
//- (void)didGetUserAgreement:(NSNotification *)notification;
@end

@implementation UserAgreementView
@synthesize textView;
@synthesize hud = _hud;
@synthesize mainMenu = _mainMenu;

- (void)getUserAgreement {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *userAgreement = [[Authorization sharedAuthorization] getUserAgreement];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textView.text = userAgreement;
            [self.hud hide:YES];
        });
    });
}

//- (void)didGetUserAgreement:(NSNotification *)notification {
//    Authorization *authorization = notification.object;
//    //self.textView.text = [notification.userInfo objectForKey:@"result"];
//    self.textView.text = authorization.userAgreement;
//    
//    [self.hud hide:YES];
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Пользовательское соглашение";
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
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetUserAgreement:) name:kNOTIFICATION_DID_GET_USER_AGREEMENT object:nil];
    
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addBackButton];
    
    [self getUserAgreement];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidUnload {
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_GET_USER_AGREEMENT object:nil];
    [self setTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
