//
//  News.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNOTIFICATION_DID_GET_NEWS_COUNT @"megatyumen.didGetNewsCount"
#define kNOTIFICATION_DID_GET_NEWS @"megatyumen.didGetNews"

@class ASIHTTPRequest;

@interface News : NSObject

@property (nonatomic) int count;                            // Количество новостей всего
@property (nonatomic) int todayCount;                       // Количество новостей сегодня
@property (nonatomic) int yesterdayCount;                   // Вчера
@property (nonatomic) int threeDaysAgoCount;                // 3 дня назад
@property (nonatomic) int weekAgoCount;                     // Неделю назад
@property (nonatomic) int othersCount;                      // Давно
@property (nonatomic) int todayLoaded;                      // Количество загруженных новостей сегодня
@property (nonatomic) int yesterdayLoaded;
@property (nonatomic) int threeDaysAgoLoaded;
@property (nonatomic) int weekAgoLoaded;
@property (nonatomic) int othersLoaded;

@property (strong, nonatomic) NSMutableDictionary *items;   // Словарь с новостями, ключ - объект NSIndexPath

// Получение количества новостей сегодня, вчера...
+ (int)count;

+ (int)readCount;
+ (void)setReadCount:(int)value;

// Получение количества новостей сегодня, вчера и т. д.
- (void)getCount;

// Получение следующей пятерки новостей
- (void)getNextNews;

- (void)didGetNewForRow:(int)row inSection:(int)section;

@end
