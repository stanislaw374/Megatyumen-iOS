//
//  New.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIHTTPRequestDelegate.h"

@protocol NewDelegate <NSObject>
@optional
- (void)newDidLoad;
- (void)newDidFailWithError:(NSString *)error;
- (void)newDidGetImages;
- (void)newImagesDidFailWithError:(NSString *)error;
- (void)newDidAddCommentWithMessage:(NSString *)message;
@end

@interface New : NSObject <ASIHTTPRequestDelegate>
@property (nonatomic, unsafe_unretained) id <NewDelegate> delegate;

@property (nonatomic) int ID;                               // Идентификатор новости
@property (nonatomic, strong) NSString *title;              // Заголовок новости
@property (nonatomic, strong) NSURL *thumbnailURL;

@property (nonatomic, strong) NSString *text;               // Текст новости
@property (nonatomic, strong) NSDate *date;                 // Дата
@property (nonatomic, strong) NSURL *imageURL;              // URL фотографии новости
@property (nonatomic, strong) NSString *user;               // Автор
@property (nonatomic, strong) NSMutableArray *images;       // URLs фотографий новости
@property (nonatomic, strong) NSMutableArray *thumbnails;
@property (nonatomic, strong) NSMutableArray *comments;     // Массив комментариев к новости
@property (nonatomic, strong) NSString *link;               // Ссылка новости
@property (nonatomic, strong) NSString *type;
// Получение детальной информации о новости
- (void)getContent;

// Загрузка фотографий новости
- (void)getImages;

// Добавление комментария к новости
- (void)addCommentWithName:(NSString *)name andText:(NSString *)text;

@end