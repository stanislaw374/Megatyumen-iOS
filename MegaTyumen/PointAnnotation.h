/*
 * PointAnnotation.h
 *
 * This file is a part of the Yandex Map Kit.
 *
 * Version for iOS © 2011 YANDEX
 * 
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://legal.yandex.ru/mapkit/
 */

#import <Foundation/Foundation.h>
#import "YandexMapKit.h"
#import "CatalogItem.h"

@interface PointAnnotation : NSObject <YMKAnnotation>

+ (id)pointAnnotation;

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * subtitle;
@property (nonatomic) YMKMapCoordinate coordinate;
@property (nonatomic, unsafe_unretained) CatalogItem *catalogItem;

@end
