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

@interface Event : New

//@property (nonatomic) int ID;
//@property (nonatomic, strong) NSURL *image;
//@property (nonatomic, copy) NSString *text;
//@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *companyName;
@property (nonatomic) int companyID;
//@property (nonatomic, strong) NSDate *date;
//@property (nonatomic, strong) NSMutableArray *images;
//@property (nonatomic, strong) NSMutableArray *comments;
//@property (nonatomic, strong) NSURL *link;
//@property (nonatomic, strong) NSString *user;


// Получение детальной информации о новости
- (void)getContent;
//
// Загрузка фотографий новости
- (void)getImages;
//
// Добавление комментария к новости
- (BOOL)addCommentWithName:(NSString *)name andText:(NSString *)text;

@end