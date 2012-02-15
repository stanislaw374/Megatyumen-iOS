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

#define kNOTIFICATION_DID_GET_CATALOG_BY_DISTANCE @"megatyumen.didGetCatalogByDistance"
#define kNOTIFICATION_DID_GET_CATALOG_TYPES @"megatyumen.didGetCatalogTypes"
#define kNOTIFICATION_DID_GET_CATALOG_CUISINES @"megatyumen.didGetCatalogCuisines"
#define kNOTIFICATION_DID_GET_CATALOG_BILLS @"megatyumen.didGetCatalogBills"
#define kNOTIFICATION_DID_GET_CATALOG_BY_CATEGORY @"megatyumen.didGetCatalogByCategory"
#define kNOTIFICATION_DID_GET_CATALOG_BY_NAME @"megatyumen.didGetCatalogByName"

@interface Catalog : NSObject <ASIHTTPRequestDelegate>

@property (nonatomic) int sections;                         // Количество секций
@property (nonatomic, strong) NSMutableArray *rows;         // Количество строк в секциях
@property (nonatomic, strong) NSMutableDictionary *items;   // Массив заведений
@property (nonatomic, strong) NSString *searchString;       // Строка поиска по заведениям
@property (nonatomic, strong) NSMutableArray *categories;   // Категории

- (id)initWithUserLocation:(CLLocation *)location;

// Запрос заведений по расстоянию
- (void)getCatalogByDistanceWithLat:(double)lat andLng:(double)lng;  
- (void)didGetCatalogByDistance:(ASIHTTPRequest *)request;

// Запрос типов заведений
- (void)getTypes; 
- (void)didGetTypes:(ASIHTTPRequest *)request;

// Запрос типов кухонь
- (void)getCuisines; 
- (void)didGetCuisines:(ASIHTTPRequest *)request;

// Запрос чеков
- (void)getBills; 

// Запрос каталога по категории
- (void)getCatalogByCategory:(CatalogCategory *)category andLat:(double)lat andLng:(double)lng;
- (void)didGetCatalogByCategory:(ASIHTTPRequest *)request;

// Запрос каталога по названию заведения
- (void)getCatalogByName:(NSString *)name andLat:(double)lat andLng:(double)lng;
- (void)didGetCatalogByName:(ASIHTTPRequest *)request;

+ (int)feedbacksCount;
+ (int)eventsCount;
+ (NSArray *)getAllFeedbacks;
+ (NSArray *)getAllEvents;

@end
