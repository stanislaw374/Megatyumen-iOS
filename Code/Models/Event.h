//
//  EventItem.h
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebImageDownloader.h"
#import "New.h"

@protocol EventDelegate <NSObject>
- (void)eventsDidLoad:(NSArray *)events;
- (void)eventsDidFailWithError:(NSString *)error;
- (void)eventDidLoad;
- (void)eventDidFailWithError:(NSString *)error;
- (void)eventDidGetImages;
@end

@interface Event : New
//@property (nonatomic, unsafe_unretained) id <EventDelegate> delegate;

@property (nonatomic) int companyID;
@property (nonatomic, strong) NSString *companyName;

+ (void)get:(int)page withDelegate:(id <EventDelegate>)delegate;

// Получение детальной информации о новости
- (void)getContent;
//
// Загрузка фотографий новости
- (void)getImages;
//
// Добавление комментария к новости
- (BOOL)addCommentWithName:(NSString *)name andText:(NSString *)text;

@end