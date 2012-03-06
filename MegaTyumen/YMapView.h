//
//  CatalogItemMapView.h
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "CatalogItem.h"
#import <CoreLocation/CoreLocation.h>

@interface YMapView : MapViewController <CLLocationManagerDelegate>

@property (nonatomic) BOOL showDisclosureButton;
@property (nonatomic) BOOL loadEntireCatalog;

//- (void)loadCatalog;
- (void)addAnnotationForCatalogItem:(CatalogItem *)catalogItem center:(BOOL)center;

@end
