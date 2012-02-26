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
- (void)loadCatalog;
@end

@implementation YMapView
@synthesize loadEntireCatalog = _loadEntireCatalog;
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
    
    self.locationManager.delegate = nil;
    [self.locationManager stopUpdatingLocation];
    
    self.catalog.userLocation = newLocation;
    [self loadCatalog];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureMapView];
}

//- (void)loadCatalog {
//    if (![CLLocationManager locationServicesEnabled]) return;
//    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [self.locationManager startUpdatingLocation];
//}

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
    self.mapView.showsUserLocation = YES;
    self.mapView.showTraffic = NO;
}

- (void)addAnnotationForCatalogItem:(CatalogItem *)catalogItem {
    PointAnnotation *pointAnnotation = [PointAnnotation pointAnnotation];
    pointAnnotation.title = catalogItem.name;
    pointAnnotation.subtitle = catalogItem.address;
    pointAnnotation.coordinate = YMKMapCoordinateMake(catalogItem.location.coordinate.latitude, catalogItem.location.coordinate.longitude);
    //pointAnnotation.coordinate = YMKMapCoordinateMake(57, 66);
    pointAnnotation.catalogItem = catalogItem;
    
    [self.mapView setCenterCoordinate:catalogItem.location.coordinate atZoomLevel:13 animated:NO];
    [self.mapView addAnnotation:pointAnnotation];
    
    [self.catalogItems addObject:pointAnnotation];
    
    NSLog(@"Catalog item location: %@", catalogItem.location.description);
}

- (void)setLoadEntireCatalog:(BOOL)loadEntireCatalog {
    _loadEntireCatalog = loadEntireCatalog;
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (self.loadEntireCatalog) {
        if ([CLLocationManager locationServicesEnabled]) {
            [self.locationManager startUpdatingLocation];
        }
        else {
            [self loadCatalog];
        }
    }
}

- (void)loadCatalog {
    dispatch_queue_t queue = dispatch_queue_create("Map loading queue", 0);
    
    //dispatch_async(queue, ^{
    {    [self.catalog getCatalogByDistance];
        //dispatch_async(dispatch_get_main_queue(), ^{
        {   
            for (CatalogItem *item in self.catalog.items.allValues) {
                [self addAnnotationForCatalogItem:item]; 
            }
            [self.hud hide:YES];
        }
    }
    
    dispatch_release(queue);
}

@end
