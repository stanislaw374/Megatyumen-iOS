//
//  CatalogItem.h
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 04.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import <CoreLocation/CoreLocation.h>

//#define kNOTIFI @"didGetDetails"
#define kNOTIFICATION_DID_CHECKIN @"megatyumen.didCheckin"

@interface CatalogItem : NSObject
{
    BOOL gotDetails;
    BOOL gotCommon;
    BOOL gotPhotos;
    BOOL gotMenu;
    BOOL gotFeedbacks;
    BOOL gotEvents;
}
@property (nonatomic) int ID;                           // ID заведения
@property (nonatomic, strong) NSString *name;           // Название заведения
@property (nonatomic, strong) NSURL *logo;              // Логотип
@property (nonatomic, strong) NSString *type;           // Тип заведения
@property (nonatomic, strong) NSString *cuisine;        // Кухня заведения
@property (nonatomic, strong) NSString *address;        // Адрес заведения
@property (nonatomic, strong) NSString *description;    // Описание заведения
@property (nonatomic) int checkinCount;                 // Количество чекинов
@property (nonatomic, strong) NSString *phone;          // Телефон
@property (nonatomic, strong) NSString *website;        // Сайт
@property (nonatomic, strong) NSString *weekdayHours;   // Часы работ в будни
//@property (nonatomic, strong) NSString *breakHours;     // Часы работ в перерывы
//@property (nonatomic, strong) NSString *saturdayHours;  // Часы работ в субботу
//@property (nonatomic, strong) NSString *sundayHours;    // Часы работ в воскресенье
@property (nonatomic, strong) NSMutableArray *menu;     // Меню
@property (nonatomic, strong) NSMutableArray *feedbacks;// Отзывы
@property (nonatomic, strong) NSMutableArray *events;   // События
@property (nonatomic, strong) NSMutableArray *photos;   // Фотки
@property (nonatomic, strong) CLLocation *location;     // Географические координаты
@property (nonatomic) int bill;                         // Средний чек
@property (nonatomic) double distance;                  // Расстояние до заведения в метрах
@property (nonatomic, strong) NSString *distanceString;     

- (void)getDetails;

- (NSDictionary *)checkinWithFeedBack:(NSString *)feedback andAttitude:(int)attitude;

- (void)getCommon;
- (void)getPhotos;
- (void)getMenu;
- (void)getFeedbacks;
- (void)getEvents;

@end
