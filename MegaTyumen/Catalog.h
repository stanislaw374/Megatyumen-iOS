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
@property (nonatomic, strong) CLLocation *userLocation;

- (id)initWithUserLocation:(CLLocation *)location;

// Запрос заведений по расстоянию
- (void)getCatalogByDistance;  

// Запрос типов заведений
- (NSArray *)getTypes; 

// Запрос типов кухонь
- (NSArray *)getCuisines; 

// Запрос чеков
- (NSArray *)getBills; 

// Запрос каталога по категории
- (void)getCatalogByCategory:(NSDictionary *)category;

// Запрос каталога по названию заведения
- (void)getCatalogByName:(NSString *)name;

@end
