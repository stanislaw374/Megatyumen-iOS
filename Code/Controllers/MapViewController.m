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
#import "MBProgressHUD.h"
#import "Catalog.h"
#import <CoreLocation/CoreLocation.h>
#import "Config.h"
#import "CompanyAnnotation.h"
#import "CatalogItemView.h"

@interface MapViewController() <CLLocationManagerDelegate, CatalogDelegate>
- (void)configureAndInstallMapView;
@property (nonatomic, strong) MainMenu *mainMenu;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *annotations;
@end

@implementation MapViewController
@synthesize mainMenu = _mainMenu;
@synthesize showBackButton = _showBackButton;
@synthesize locationManager = _locationManager;
//@synthesize showAll = _showAll;
@synthesize company = _company;
@synthesize annotations = _annotations;

#pragma mark - Lazy instantiation
- (NSArray *)annotations {
    if (!_annotations) {
        _annotations = [NSArray array];
    }
    return _annotations;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (void)setAnnotations:(NSArray *)annotations {
    _annotations = annotations;
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:self.annotations];
    self.mapView.showsUserLocation = YES;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [manager stopUpdatingLocation];
    [Catalog getCatalogByDistance:kDEFAULT_LOCATION.coordinate withDelegate:self];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [manager stopUpdatingLocation];
    
    [Catalog getCatalogByDistance:manager.location.coordinate withDelegate:self];
}

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
    
    [self configureAndInstallMapView];
    
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    if (self.company) {
        [self.mainMenu addBackButton];
    }
    
    [self.mainMenu addMainButton];
    [self.mainMenu addAuthorizeButton];
}

- (void)viewDidUnload {
    self.mapView = nil;

    [super viewDidUnload];
}

#pragma mark - Helpers

- (void)configureAndInstallMapView {
    // Replace with your own Yandex Map Kit API key
    self.mapView.apiKey = @"SkJckErzSIu5lPxAMtjpUhKfSWAU7dPt0sNpSAgkp8dzvQp0UnHnXK7xuJh8kTjW83Dg8CdYkm5hm31q59HeDLQxEwCef0gKAwXD2vyDrms=";
    self.mapView.showsUserLocation = YES;
    self.mapView.showTraffic = NO;    
    
    if (self.company) {
        [self.mapView setCenterCoordinate:self.company.coordinate atZoomLevel:15 animated:YES];
        CompanyAnnotation *annotation = [CompanyAnnotation annotationForCompany:self.company];
        self.annotations = [NSArray arrayWithObject:annotation];
    }
    else {
        [self.mapView setCenterCoordinate:kDEFAULT_LOCATION.coordinate atZoomLevel:13 animated:YES];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
            [self.locationManager startUpdatingLocation];
        }
        else {
            [Catalog getCatalogByDistance:kDEFAULT_LOCATION.coordinate withDelegate:self];
        }             
    }
}

#pragma mark - CatalogDelegate
- (void)catalogDidLoad:(NSArray *)companies {
    NSMutableArray *result = [NSMutableArray array];
    for (Company *c in companies) {
        CompanyAnnotation *a = [CompanyAnnotation annotationForCompany:c];
        [result addObject:a];
    }
    self.annotations = result;
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)catalogDidFailWithError:(NSString *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - YMKMapViewDelegate
- (YMKAnnotationView *)mapView:(YMKMapView *)mapView_ viewForAnnotation:(id<YMKAnnotation>)annotation {
    static NSString * identifier = @"CompanyAnnotation";
    YMKPinAnnotationView * view = (YMKPinAnnotationView *)[mapView_ dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (1) {
        view = [[YMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        view.canShowCallout = YES;
        
        if (!self.company) {
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            view.rightCalloutAccessoryView = rightButton; 
        }
        view.image = [UIImage imageNamed:@"map_pin.png"];
    }
    
    return view;
}

- (void)mapView:(YMKMapView *)mapView annotationView:(YMKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    CatalogItemView *cview = [[CatalogItemView alloc] init];
    CompanyAnnotation *annotaion = (CompanyAnnotation *)view.annotation;
    cview.company = annotaion.company;
    [self.navigationController pushViewController:cview animated:YES];
}

#pragma mark - Properties

@synthesize mapView;

@end
