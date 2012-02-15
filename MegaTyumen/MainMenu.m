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
    self.viewController.navigationItem.rightBarButtonItem = ([Authorization sharedAuthorization].isAuthorized) ? nil : authorizeButton;
}

- (void)onAuthorizeButtonClick {
    [self.viewController.navigationController pushViewController:self.authorizationView animated:YES];
}

- (void)addHiddenBackButton {
    self.viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Назад" style:UIBarButtonItemStyleBordered target:self action:nil];
}

//--------------------------------------------------------------------------------------------

//+ (void)addMainButtonForViewController:(UIViewController<MainMenuDelegate> *)viewController {
//    
//}
//
//+ (void)addBackButtonForViewController:(UIViewController<MainMenuDelegate> *)viewController {
//    UIButton *backButton = [[UIButton alloc] init];
//    [backButton addTarget:viewController action:@selector(onBackButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    [backButton setBackgroundImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateNormal];
//    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
//    [backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
//    [backButton setTitle:@"Назад" forState:UIControlStateNormal];
//    [backButton sizeToFit];
//    
//    UIView *leftButton;
//    if (viewController.navigationItem.leftBarButtonItem == nil) {
//        leftButton = [[UIView alloc] initWithFrame:backButton.frame];
//    }
//    else {
//        leftButton = viewController.navigationItem.leftBarButtonItem.customView;
//        if (leftButton.subviews.count > 1) return;
//        UIView *view = [leftButton.subviews objectAtIndex:0];
//        CGRect frame = view.frame;
//        frame.origin.x += backButton.frame.size.width + 5;
//        view.frame = frame;
//        
//        frame = leftButton.frame;
//        frame.size.width += backButton.frame.size.width + 5;
//        leftButton.frame = frame;
//    }
//    [leftButton addSubview:backButton];
//    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
//    
//    viewController.navigationItem.leftBarButtonItem = leftButtonItem;
//}
//
//+ (void)addAuthorizeButtonForViewController:(UIViewController<MainMenuDelegate> *)viewController {
//    UIBarButtonItem *authorizeButton = [[UIBarButtonItem alloc] initWithTitle:@"Войти" style:UIBarButtonItemStyleBordered target:viewController action:@selector(onAuthorizeButtonClick)];
//    viewController.navigationItem.rightBarButtonItem = ([Authorization sharedAuthorization].isAuthorized) ? nil : authorizeButton;
//    
//    [self addHiddenBackButtonForViewController:viewController];
//}
//
//+ (void)addHiddenBackButtonForViewController:(UIViewController<MainMenuDelegate> *)viewController {
//    viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Назад" style:UIBarButtonItemStyleBordered target:viewController action:nil];
//}
//
////+ (void)setForViewController:(UIViewController<MainMenuDelegate> *)viewController {
////    //UIView *leftButtonView = [[UIView alloc] init];
////    
////    //CGRect backButtonFrame = CGRectMake(6, 7, 56, 30);
////    UIButton *backButton = [[UIButton alloc] init];
////    [backButton addTarget:viewController action:@selector(onBackButtonClick) forControlEvents:UIControlEventTouchUpInside];
////    [backButton setBackgroundImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateNormal];
////    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
////    [backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
////    [backButton setTitle:@"Назад" forState:UIControlStateNormal];
////    [backButton sizeToFit];
////    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
////    //[leftButtonView addSubview:backButton];
////    
////    //CGRect mainButtonFrame = CGRectMake(67, 7, 30, 30);
////    UIButton *mainButton = [[UIButton alloc] init];
////    [mainButton addTarget:viewController action:@selector(onMainButtonClick) forControlEvents:UIControlEventTouchUpInside];
////    [mainButton setBackgroundImage:[UIImage imageNamed:@"menuButton.png"] forState:UIControlStateNormal];
////    [mainButton sizeToFit];
////    UIBarButtonItem *mainButtonItem = [[UIBarButtonItem alloc] initWithCustomView:mainButton];
////    //[leftButtonView addSubview:mainButton];
////    
////    viewController.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:backButtonItem, mainButtonItem, nil];
////    
////    //leftButtonView.frame = CGRectMake(viewController.navigationController.navigationBar.frame.origin.x, viewController.navigationController.navigationBar.frame.origin.y, mainButtonFrame.origin.x + mainButtonFrame.size.width + 5, viewController.navigationController.navigationBar.frame.size.height);
////    
////    //viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButtonView];
////    
////    UIBarButtonItem *authorizeButton = [[UIBarButtonItem alloc] initWithTitle:@"Войти" style:UIBarButtonItemStyleBordered target:viewController action:@selector(onAuthorizeButtonClick)];
////    viewController.navigationItem.rightBarButtonItem = ([Authorization sharedAuthorization].isAuthorized) ? nil : authorizeButton;
////    
////    viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Назад" style:UIBarButtonItemStyleBordered target:viewController action:nil];
////}

@end
