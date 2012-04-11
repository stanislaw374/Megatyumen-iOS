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
#import "Constants.h"

@interface YMapView()
@property (nonatomic, strong) NSMutableArray *annonations;
@property (nonatomic, strong) CatalogItemView *catalogItemView;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) Catalog *catalog;
@property (nonatomic, strong) CLLocationManager *locationManager;
- (void)configureMapView;
- (void)loadCatalog;
@end

@implementation YMapView
@synthesize loadEntireCatalog = _loadEntireCatalog;
@synthesize hud = _hud;
@synthesize catalog = _catalog;
@synthesize annonations = _annonations;
@synthesize showDisclosureButton = _showDisclosureButton;
@synthesize catalogItemView = _catalogItemView;
@synthesize locationManager = _locationManager;

- (NSMutableArray *)catalogItems {
    if (!_annonations) {
        _annonations = [[NSMutableArray alloc] init];
    }
    return _annonations;
}

- (CatalogItemView *)catalogItemView {
    if (!_catalogItemView) {
        _catalogItemView = [[CatalogItemView alloc] init];
    }
    return _catalogItemView;
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

- (Catalog *)catalog {
    if (!_catalog) {
        _catalog = [[Catalog alloc] init];
    }
    return _catalog;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [manager stopUpdatingLocation]; 
    //[self.mapView setCenterCoordinate:newLocation.coordinate atZoomLevel:13 animated:YES];
    self.catalog.userLocation = newLocation;
    [self loadCatalog];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [manager stopUpdatingLocation];
    //[self.mapView setCenterCoordinate:kDEFAULT_LOCATION.coordinate atZoomLevel:13 animated:YES];
    //self.locationManager.delegate = nil;
    //[self.locationManager stopUpdatingLocation];
    [self loadCatalog];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureMapView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.mapView.showsUserLocation = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.mapView.showsUserLocation = NO;
    [self.mapView removeAnnotations:self.annonations];
}

- (void)viewDidUnload {    
    self.annonations = nil;
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
        view.image = [UIImage imageNamed:@"map_pin.png"];
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
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        self.mapView.showsUserLocation = YES;   
        //[self.locationManager startUpdatingLocation];
    }
    [self.mapView setCenterCoordinate:kDEFAULT_LOCATION.coordinate atZoomLevel:13 animated:YES];
    self.mapView.showTraffic = NO;
}

- (void)addAnnotationForCatalogItem:(CatalogItem *)catalogItem center:(BOOL)center {
    PointAnnotation *pointAnnotation = [PointAnnotation pointAnnotation];
    pointAnnotation.title = catalogItem.name;
    pointAnnotation.subtitle = catalogItem.address;
    pointAnnotation.coordinate = YMKMapCoordinateMake(catalogItem.location.coordinate.latitude, catalogItem.location.coordinate.longitude);    
    pointAnnotation.catalogItem = catalogItem;
    
    if (center) {
        [self.mapView setCenterCoordinate:catalogItem.location.coordinate atZoomLevel:13 animated:NO];
    }
    
    [self.mapView addAnnotation:pointAnnotation];
    [self.annonations addObject:pointAnnotation];
    
    NSLog(@"Catalog item location: %@", catalogItem.location.description);
}

- (void)setLoadEntireCatalog:(BOOL)loadEntireCatalog {
    _loadEntireCatalog = loadEntireCatalog;
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];    
    
    if (self.loadEntireCatalog) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if ([CLLocationManager locationServicesEnabled] && status != kCLAuthorizationStatusDenied) {
            [self.locationManager startUpdatingLocation];
        }
        else {
            [self loadCatalog];
        }
    }
}

- (void)loadCatalog {
    //dispatch_queue_t queue = dispatch_queue_create("Map loading queue", 0);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        [self.catalog getCatalogByDistance];
        dispatch_async(dispatch_get_main_queue(), ^{           
            for (CatalogItem *item in self.catalog.items.allValues) {
                [self addAnnotationForCatalogItem:item center:NO]; 
            }
            [self.hud hide:YES];
        });
    });
}

@end
