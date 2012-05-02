//
//  Catalog.h
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 04.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "ASIHTTPRequest.h"
#import "CatalogCategory.h"
#import <CoreLocation/CoreLocation.h>

@protocol CatalogDelegate <NSObject>
@optional
- (void)catalogDidGetTypes:(NSArray *)types;
- (void)catalogDidGetCuisines:(NSArray *)cuisines;
- (void)catalogDidLoad:(NSArray *)companies;
- (void)catalogDidFailWithError:(NSString *)error;
@end

@interface Catalog : NSObject <ASIHTTPRequestDelegate>

// Запрос заведений по расстоянию
+ (void)getCatalogByDistance:(CLLocationCoordinate2D)coordinate withDelegate:(id <CatalogDelegate>)delegate;

// Запрос типов заведений
+ (void)getTypesWithDelegate:(id <CatalogDelegate>)delegate;

// Запрос типов кухонь
+ (void)getCuisinesWithDelegate:(id <CatalogDelegate>)delegate;

// Запрос каталога по названию заведения
+ (void)getCatalogByName:(NSString *)name nearCoordinate:(CLLocationCoordinate2D)coordinate withDelegate:(id <CatalogDelegate>)delegate;

// Запрос каталога по типу заведения
+ (void)getCatalogByTypeID:(NSString *)ID nearCoordinate:(CLLocationCoordinate2D)coordinate withDelegate:(id <CatalogDelegate>)delegate;

// Запрос каталога по кухне
+ (void)getCatalogByCuisineID:(NSString *)ID nearCoordinate:(CLLocationCoordinate2D)coordinate withDelegate:(id <CatalogDelegate>)delegate;

@end
