//
//  CatalogItemMapView.h
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "CatalogItem.h"

@interface YMapView : MapViewController

@property (nonatomic) BOOL showDisclosureButton;
@property (nonatomic) BOOL loadAllMarkers;

- (void)addAnnotationForCatalogItem:(CatalogItem *)catalogItem;


@end
