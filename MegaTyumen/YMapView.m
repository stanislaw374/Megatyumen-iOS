//
//  CatalogItemMapView.m
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "YMapView.h"
#import "CatalogItemView.h"
#import "MBProgressHUD.h"
#import "Catalog.h"
#import "CatalogItem.h"

@interface YMapView()
@property (nonatomic, strong) NSMutableArray *catalogItems;
@property (nonatomic, strong) CatalogItemView *catalogItemView;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) Catalog *catalog;
@property (nonatomic, strong) CLLocationManager *locationManager;
- (void)configureMapView;
//- (void)loadMarkers;
@end

@implementation YMapView
//@synthesize loadAllMarkers = _loadAllMarkers;
@synthesize hud = _hud;
@synthesize catalog = _catalog;
@synthesize catalogItems = _catalogItems;
@synthesize showDisclosureButton = _showDisclosureButton;
@synthesize catalogItemView = _catalogItemView;
@synthesize locationManager = _locationManager;

- (NSMutableArray *)catalogItems {
    if (!_catalogItems) {
        _catalogItems = [[NSMutableArray alloc] init];
    }
    return _catalogItems;
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

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.catalog = [[Catalog alloc] initWithUserLocation:newLocation];
        [self.catalog getCatalogByDistance];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (CatalogItem *item in self.catalog.items.allValues) {
                [self addAnnotationForCatalogItem:item]; 
            }
            [self.hud hide:YES];
        });
    });
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureMapView];
}

- (void)loadCatalog {
    if (![CLLocationManager locationServicesEnabled]) return;
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidUnload {    
    self.catalogItems = nil;
    [super viewDidUnload];
}

#pragma mark - YMKMapViewDelegate

- (YMKAnnotationView *)mapView:(YMKMapView *)mapView viewForAnnotation:(id<YMKAnnotation>)annotation
{
    static NSString * identifier = @"pointAnnotation";
    YMKPinAnnotationView * view = (YMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (view == nil) {
        view = [[YMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        view.canShowCallout = YES;
        
        if (self.showDisclosureButton) {
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            view.rightCalloutAccessoryView = rightButton;            
        }
    }
    
    return view;
}

- (void)mapView:(YMKMapView *)mapView annotationView:(YMKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if (!self.catalogItemView) {
        self.catalogItemView = [[CatalogItemView alloc] init];
    }
    PointAnnotation *annotaion = (PointAnnotation *)view.annotation;
    self.catalogItemView.currentItem = annotaion.catalogItem;
    [self.navigationController pushViewController:self.catalogItemView animated:YES];
}

#pragma mark - Helpers

- (void)configureMapView {
    self.mapView.showsUserLocation = NO;
    self.mapView.showTraffic = NO;
}

- (void)addAnnotationForCatalogItem:(CatalogItem *)catalogItem {
    PointAnnotation *pointAnnotation = [PointAnnotation pointAnnotation];
    pointAnnotation.title = catalogItem.name;
    pointAnnotation.subtitle = catalogItem.address;
    pointAnnotation.coordinate = YMKMapCoordinateMake(catalogItem.location.coordinate.latitude, catalogItem.location.coordinate.longitude);
    pointAnnotation.catalogItem = catalogItem;
    
    [self.mapView setCenterCoordinate:catalogItem.location.coordinate atZoomLevel:13 animated:NO];
    [self.mapView addAnnotation:pointAnnotation];
    
    [self.catalogItems addObject:pointAnnotation];
}

@end
