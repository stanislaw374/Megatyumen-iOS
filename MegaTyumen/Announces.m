//
//  PartyAnnounces.m
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Announces.h"
#import "Announce.h"
#import "Constants.h"
#import "ASIFormDataRequest.h"
#import "SBJSON.h"

@interface Announces()
//- (void)didGetItems:(ASIHTTPRequest *)request;
@end

@implementation Announces
@synthesize items = _items;

- (NSMutableArray *)items {
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}

//+ (int)readCount {
//    static NSString *kAnnouncesCount = @"AnnouncesReadCount";
//    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    int read = 0;
//    if ([defaults objectForKey:kAnnouncesCount]) {
//        read = [defaults integerForKey:kAnnouncesCount];
//    }    
//    return read;
//}
//
//+ (int)count {
//    return 5;
//}

- (void)getItems {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self didGetItems:nil];
//    });  
    int limit = 100;
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"food_announces", @"request", [NSNumber numberWithInt:limit], @"limit", nil];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
    
    NSString *jsonData = [writer stringWithObject:dict];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:jsonData forKey:@"jsonData"];
    [request startSynchronous];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict2 = [parser objectWithString:request.responseString];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict2.description);
    
    BOOL result = [[dict2 objectForKey:@"response"] intValue];
    if (result) {
        NSArray *announces = [dict2 objectForKey:@"announces"];
        for (NSDictionary *announce in announces) {
            Announce *a = [[Announce alloc] init];
            a.title = [announce objectForKey:@"title"];
            a.text = [announce objectForKey:@"text"];
            a.image = [NSURL URLWithString:[dict2 objectForKey:@"image"] relativeToURL:kWEBSITE_URL];
            
            [self.items addObject:a];
        }
    }
}

//- (void)didGetItems:(ASIHTTPRequest *)request {
//    Announce *announce = [[Announce alloc] init];
//    announce.description = @"Мохито взболтают по-новому";
//    //announce.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://megatyumen.ru/public/content/images/origs/1324664789810.jpg"]]];
//    announce.imageUrl = [NSURL URLWithString:@"http://megatyumen.ru/public/content/images/origs/1324664789810.jpg"];
//    announce.what = @"Новое меню от шеф-повара из Екатеринбурга";
//    announce.where = @"В баре-ресторане \"Мохито\"";
//    announce.when = @"В середине января";
//    announce.comments = 1;
//    [self.items insertObject:announce atIndex:0];
//
//    announce = [[Announce alloc] init];
//    announce.description = @"Кофе-Чае-Мания вновь собирает друзей!";
//    //announce.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://megatyumen.ru/public/content/images/xl/1324445873462.jpg"]]];
//    announce.imageUrl = [NSURL URLWithString:@"http://megatyumen.ru/public/content/images/xl/1324445873462.jpg"];
//    announce.what = @"Клуб «Кофе-Чае-Мания» приглашает на 27 встречу «Шоколад и специи кладем… в мыло и свечи!»";
//    announce.where = @"В кофейне «Шоколандия»";
//    announce.when = @"25 декабря в 14 часов";
//    announce.comments = 1;
//    [self.items insertObject:announce atIndex:1];
//    
//    announce = [[Announce alloc] init];
//    announce.description = @"Сельсоветовский литрбол";
//    //announce.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://megatyumen.ru/public/content/images/xl/1324439361500.jpg"]]];
//    announce.imageUrl = [NSURL URLWithString:@"http://megatyumen.ru/public/content/images/xl/1324439361500.jpg"];
//    announce.what = @"За каждый литр фирменного пенного напитка участник литрбола получает наклейку. А от числа наклеек зависит ценность награды";
//    announce.where = @"Пивная «Ермолаевъ Сельсовет»";
//    announce.when = @" С сегодняшнего дня и до 31 января";
//    announce.comments = 0;
//    [self.items insertObject:announce atIndex:2];
//    
//    announce = [[Announce alloc] init];
//    announce.description = @"Вечеринка в стиле «Вокруг Света»";
//    //announce.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://megatyumen.ru/public/content/images/xl/132430490015.jpg"]]];
//    announce.imageUrl = [NSURL URLWithString:@"http://megatyumen.ru/public/content/images/xl/132430490015.jpg"];
//    announce.what = @"За 4 часа вас ждет путешествие «Вокруг Света». Яркую шоу-программу для Вас проведут Паспарту и Мистер Фогг. После полуночи Супер-DJ и лучшие бармены ";
//    announce.where = @"Ресторан GRUNGE";
//    announce.when = @"28 декабря в 19.00";
//    announce.comments = 0;
//    [self.items insertObject:announce atIndex:3];
//    
//    announce = [[Announce alloc] init];
//    announce.description = @"Новогодний подарок для любителей пенного напитка";
//    //announce.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://megatyumen.ru/public/content/images/xl/1323762263786.jpg"]]];
//    announce.imageUrl = [NSURL URLWithString:@"http://megatyumen.ru/public/content/images/xl/1323762263786.jpg"];
//    announce.what = @"В Новый год с новым ассортиментом пива и специальными ценами. 8 сортов уже ждут!";
//    announce.where = @"Кафе-бар «Старый Арбат»";
//    announce.when = @"Уже сегодня";
//    announce.comments = 1;
//    [self.items insertObject:announce atIndex:4];
//    
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_ANNOUNCES object:nil];
//    });
//    
//}

@end
