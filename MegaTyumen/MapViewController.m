/*
 * MapViewController.m
 *
 * This file is a part of the Yandex Map Kit.
 *
 * Version for iOS © 2011 YANDEX
 * 
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://legal.yandex.ru/mapkit/
 */

#import "MapViewController.h"
#import "Authorization.h"
#import "AuthorizationView.h"
#import "MBProgressHUD.h"

@interface MapViewController()
- (void)configureAndInstallMapView;
@property (nonatomic, strong) MainMenu *mainMenu;
- (void)didPassAuthorization:(NSNotification *)notification;
@end

@implementation MapViewController
@synthesize mainMenu = _mainMenu;
@synthesize showBackButton = _showBackButton;

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:@"MapViewController" bundle:nibBundleOrNil];
    if (self) {
        self.title = @"На карте";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPassAuthorization:) name:kNOTIFICATION_DID_AUTHORIZE object:nil];
    
    [self configureAndInstallMapView];
    
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    if (self.showBackButton) {
        [self.mainMenu addBackButton];
    }
    
    [self.mainMenu addMainButton];
    [self.mainMenu addAuthorizeButton];
}

- (void)viewDidUnload {
    self.mapView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_AUTHORIZE object:nil];
    [super viewDidUnload];
}

#pragma mark - Helpers

- (void)configureAndInstallMapView {
    // Replace with your own Yandex Map Kit API key
    self.mapView.apiKey = @"SkJckErzSIu5lPxAMtjpUhKfSWAU7dPt0sNpSAgkp8dzvQp0UnHnXK7xuJh8kTjW83Dg8CdYkm5hm31q59HeDLQxEwCef0gKAwXD2vyDrms=";
}

- (void)didPassAuthorization:(NSNotification *)notification {
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - Properties

@synthesize mapView;

@end
