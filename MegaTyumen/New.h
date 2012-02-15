//
//  New.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "SDWebImageManagerDelegate.h"

#define kNOTIFICATION_DID_GET_NEW_DETAILS @"megatyumen.didGetNewDetails"
#define kNOTIFICATION_DID_GET_PHOTOS @"megatyumen.didGetPhotos"
#define kNOTIFICATION_DID_ADD_COMMENT @"megatyumen.didAddComment"

@class ASIHTTPRequest;
@class News;

@interface New : NSObject <ASIHTTPRequestDelegate, SDWebImageManagerDelegate>

@property (nonatomic, unsafe_unretained) News *parent;

@property (nonatomic) int ID;                               // Идентификатор новости
@property (nonatomic, strong) NSString *title;              // Заголовок новости
@property (nonatomic, strong) NSString *text;               // Текст новости
@property (nonatomic, strong) NSDate *date;                 // Дата
@property (nonatomic, strong) NSURL *photoUrl;              // URL фотографии новости
@property (nonatomic, strong) UIImage *thumbnail;           // Thumbnail фотографии
@property (nonatomic, strong) NSString *author;             // Автор
@property (nonatomic) int photosCount;
@property (nonatomic) int commentsCount;
@property (nonatomic, strong) NSMutableArray *photoURLs;    // URLs фотографий новости
@property (nonatomic, strong) NSMutableArray *comments;     // Массив комментариев к новости
@property (nonatomic, strong) NSString *url;                // URL новости

// Загрузка данных для конкретной новости
- (void)loadDataForRow:(int)row inSection:(int)section;

// Получение детальной информации о новости
- (void)getDetails;

// Загрузка фотографий новости
- (void)getPhotos;

// Добавление комментария к новости
- (void)addCommentWithName:(NSString *)name andText:(NSString *)text;// Добавить комментарий к новости

@end
