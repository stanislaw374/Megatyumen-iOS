//
//  MainMenu.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 25.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenu.h"
#import "Authorization.h"
#import "AuthorizationView.h"
#import "Network.h"
#import "Alerts.h"
#import "User.h"
#import "Reachability.h"

@interface MainMenu()
@property (nonatomic, unsafe_unretained) UIViewController *viewController;
@property (nonatomic, strong) AuthorizationView *authorizationView;
@end

@implementation MainMenu
@synthesize viewController = _viewController;
@synthesize authorizationView = _authorizationView;

#pragma mark - Lazy Instantiation

- (AuthorizationView *)authorizationView {
    if (!_authorizationView) {
        _authorizationView = [[AuthorizationView alloc] init];
    }
    return _authorizationView;
}

- (id)initWithViewController:(UIViewController *)viewController {
    if (self = [super init]) {
        _viewController = viewController;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin:) name:kNOTIFICATION_USER_DID_LOGIN object:nil];
    }
    return self;
}

- (void)addMainButton {
    UIButton *mainButton = [[UIButton alloc] init];
    [mainButton addTarget:self action:@selector(onMainButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [mainButton setBackgroundImage:[UIImage imageNamed:@"menuButton.png"] forState:UIControlStateNormal];
    [mainButton sizeToFit];
    
    UIView *leftButton;
    
    if (self.viewController.navigationItem.leftBarButtonItem == nil) {
        leftButton = [[UIView alloc] initWithFrame:mainButton.frame];
        [leftButton addSubview:mainButton];
    }
    else {
        UIButton *backButton = [[UIButton alloc] init];
        [backButton addTarget:self action:@selector(onBackButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [backButton setBackgroundImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateNormal];
        backButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [backButton setTitle:@"Назад" forState:UIControlStateNormal];
        [backButton sizeToFit];
        
        CGRect leftButtonRect = CGRectMake(0, 0, mainButton.frame.size.width + 5 + backButton.frame.size.width, backButton.frame.size.height);
        leftButton = [[UIView alloc] initWithFrame:leftButtonRect];
        
        [leftButton addSubview:backButton];
        [leftButton addSubview:mainButton];
        
        CGRect frame = mainButton.frame;
        frame.origin.x = backButton.frame.origin.x + backButton.frame.size.width + 5;
        mainButton.frame = frame;
    }   
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.viewController.navigationItem.leftBarButtonItem = leftButtonItem;
}

- (void)onMainButtonClick {
    [self.viewController.navigationController popToRootViewControllerAnimated:YES];
}

- (void)addBackButton {
    UIButton *backButton = [[UIButton alloc] init];
    [backButton addTarget:self action:@selector(onBackButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [backButton setTitle:@"Назад" forState:UIControlStateNormal];
    [backButton sizeToFit];    
    
    UIView *leftButton;
    
    if (self.viewController.navigationController.navigationItem.leftBarButtonItem == nil) {
        leftButton = [[UIView alloc] initWithFrame:backButton.frame];
        [leftButton addSubview:backButton];
    }
    else {
        UIButton *mainButton = [[UIButton alloc] init];
        [mainButton addTarget:self action:@selector(onMainButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [mainButton setBackgroundImage:[UIImage imageNamed:@"menuButton.png"] forState:UIControlStateNormal];
        [mainButton sizeToFit];
        
        CGRect leftButtonRect = CGRectMake(0, 0, mainButton.frame.size.width + 5 + backButton.frame.size.width, backButton.frame.size.height);
        leftButton = [[UIView alloc] initWithFrame:leftButtonRect];
        
        [leftButton addSubview:backButton];
        [leftButton addSubview:mainButton];
    }   
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.viewController.navigationItem.leftBarButtonItem = leftButtonItem;
}

- (void)onBackButtonClick {
    [self.viewController.navigationController popViewControllerAnimated:YES];
}

- (void)addAuthorizeButton {    
    UIBarButtonItem *authorizeButton = [[UIBarButtonItem alloc] initWithTitle:@"Войти" style:UIBarButtonItemStyleBordered target:self action:@selector(onAuthorizeButtonClick)];
    self.viewController.navigationItem.rightBarButtonItem = ([User sharedUser].token) ? nil : authorizeButton;
}

- (void)onAuthorizeButtonClick {
    if (![Reachability reachabilityForInternetConnection].isReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Нет доступа в Интернет" message:@"Для работы данного приложения необходим доступ в интернет" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self.viewController.navigationController pushViewController:self.authorizationView animated:YES];
}

-(void)addLogoutButton{
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Выйти" style:UIBarButtonItemStyleBordered target:self action:@selector(onLogoutButtonClick)];
    self.viewController.navigationItem.rightBarButtonItem = nil;
    self.viewController.navigationItem.rightBarButtonItem = logoutButton;
}

-(void)onLogoutButtonClick{    
    [[User sharedUser] clear];
    self.viewController.navigationItem.rightBarButtonItem = nil;
    [self addAuthorizeButton];
}

- (void)addHiddenBackButton {
    self.viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Назад" style:UIBarButtonItemStyleBordered target:self action:nil];
}

- (void)userDidLogin:(NSNotification *)notification {
    self.viewController.navigationItem.rightBarButtonItem = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_USER_DID_LOGIN object:nil];
}

@end
