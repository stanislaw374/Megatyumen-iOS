//
//  Catalog.m
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 04.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Catalog.h"
#import "Authorization.h"
#import "SBJson.h"
#import "Config.h"
#import "CatalogItem.h"
#import "ASIFormDataRequest.h"
#import "UIImage+Thumbnail.h"
#import "CatalogCategory.h"
#import "MenuItem.h"
#import "Feedback.h"
#import "Event.h"
#import "NSString+HTML.h"
#import "Company.h"

@interface Catalog()
+ (NSArray *)parseCatalog:(NSDictionary *)responseDictionary;
@end

@implementation Catalog

+ (NSArray *)parseCatalog:(NSDictionary *)responseDictionary {
    NSArray *catalog = [responseDictionary objectForKey:@"companies"];
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *company in catalog) {
        Company *c = [[Company alloc] init];
        c.ID = [[company objectForKey:@"id"] intValue];
        c.name = [company objectForKey:@"name"];
        c.address = [company objectForKey:@"address"];
        id logo = [company objectForKey:@"logo"];
        if (![logo isEqual:[NSNull null]]) { 
            c.logoURL = [NSURL URLWithString:[company objectForKey:@"logo"] relativeToURL:kWEBSITE_URL];
        }
        double lat = [[company objectForKey:@"lat"] doubleValue];
        double lng = [[company objectForKey:@"lng"] doubleValue];                               
        c.coordinate = CLLocationCoordinate2DMake(lat, lng);
        c.description = [company objectForKey:@"description"];
        c.feedbacksCount = [[company objectForKey:@"feedbacks_count"] intValue];
        c.distance = [[company objectForKey:@"distance"] doubleValue] * 1000;
        
        [result addObject:c];
    }
    return result;
}

+ (void)getCatalogByDistance:(CLLocationCoordinate2D)coordinate withDelegate:(id<CatalogDelegate>)delegate {
    NSString *params = [[NSString stringWithFormat:@"?request=catalog_by_distance&lat=%lf&lng=%lf", coordinate.latitude, coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];    
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSDictionary *rd = [request.responseString JSONValue];
        BOOL response = [[rd objectForKey:@"response"] boolValue];
        if (response) {
            NSArray *result = [self parseCatalog:rd];
            [delegate catalogDidLoad:result];        
        }
        else {
            [delegate catalogDidFailWithError:[rd objectForKey:@"error"]];
        }
    }];
    [request setFailedBlock:^{
        [delegate catalogDidFailWithError:request.error.localizedDescription];
    }];
    
    [request startAsynchronous];
}

+ (void)getCatalogByName:(NSString *)name nearCoordinate:(CLLocationCoordinate2D)coordinate withDelegate:(id<CatalogDelegate>)delegate {
    NSString *params = [[NSString stringWithFormat:@"?request=catalog_by_name&lat=%lf&lng=%lf&name=%@", coordinate.latitude, coordinate.longitude, name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];    
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSDictionary *rd = [request.responseString JSONValue];
        BOOL response = [[rd objectForKey:@"response"] boolValue];
        if (response) {
            NSArray *result = [self parseCatalog:rd];
            [delegate catalogDidLoad:result];
        }
        else {
            [delegate catalogDidFailWithError:[rd objectForKey:@"error"]];
        }
    }];
    [request setFailedBlock:^{
        [delegate catalogDidFailWithError:request.error.localizedDescription];
    }];
    
    [request startAsynchronous];
}

+ (void)getCatalogByTypeID:(NSString *)ID nearCoordinate:(CLLocationCoordinate2D)coordinate withDelegate:(id<CatalogDelegate>)delegate {
    NSString *params = [[NSString stringWithFormat:@"?request=catalog_by_type&lat=%lf&lng=%lf&id=%@", coordinate.latitude, coordinate.longitude, ID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];    
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSDictionary *rd = [request.responseString JSONValue];
        BOOL response = [[rd objectForKey:@"response"] boolValue];
        if (response) {
            NSArray *result = [self parseCatalog:rd];
            [delegate catalogDidLoad:result];
        }
        else {
            [delegate catalogDidFailWithError:[rd objectForKey:@"error"]];
        }
    }];
    [request setFailedBlock:^{
        [delegate catalogDidFailWithError:request.error.localizedDescription];
    }];
    
    [request startAsynchronous];
}

+ (void)getCatalogByCuisineID:(NSString *)ID nearCoordinate:(CLLocationCoordinate2D)coordinate withDelegate:(id<CatalogDelegate>)delegate {
    NSString *params = [[NSString stringWithFormat:@"?request=catalog_by_cuisine&lat=%lf&lng=%lf&id=%@", coordinate.latitude, coordinate.longitude, ID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];    
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSDictionary *rd = [request.responseString JSONValue];
        BOOL response = [[rd objectForKey:@"response"] boolValue];
        if (response) {
            NSArray *result = [self parseCatalog:rd];
            [delegate catalogDidLoad:result];
        }
        else {
            [delegate catalogDidFailWithError:[rd objectForKey:@"error"]];
        }
    }];
    [request setFailedBlock:^{
        [delegate catalogDidFailWithError:request.error.localizedDescription];
    }];
    
    [request startAsynchronous];
}

+ (void)getTypesWithDelegate:(id<CatalogDelegate>)delegate {
    NSString *params = [[NSString stringWithFormat:@"?request=catalog_types"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSDictionary *dict = [request.responseString JSONValue];
        NSArray *types = [dict objectForKey:@"catalog_types"];
        
        NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
        
        NSMutableArray *result = [[NSMutableArray alloc] init];
        BOOL response = [[dict objectForKey:@"response"] boolValue];
        if (response) {
            for (NSDictionary *type in types) {
                NSDictionary *idDict = [type objectForKey:@"id"];
                NSString *ID = [idDict objectForKey:@"$id"];
                NSString *name = [type objectForKey:@"name"];
                UIImage *image;
                
                if ([name isEqualToString:@"Бары"]) {
                    image = [UIImage imageNamed:@"bars.png"];
                }
                else if ([name isEqualToString:@"Блинные"]) {
                    image = [UIImage imageNamed:@"blin.png"];
                }
                else if ([name isEqualToString:@"Кафе"]) {
                    image = [UIImage imageNamed:@"cafe.png"];
                }
                else if ([name isEqualToString:@"Кофейни"]) {
                    image = [UIImage imageNamed:@"coffee.png"];
                }
                else if ([name isEqualToString:@"Кондитерские"]) {
                    image = [UIImage imageNamed:@"conditer.png"];
                }
                else if ([name isEqualToString:@"Кулинария"]) {
                    image = [UIImage imageNamed:@"kulinaria.png"];
                }
                else if ([name isEqualToString:@"Пекарня"]) {
                    image = [UIImage imageNamed:@"pekar.png"];
                }
                else if ([name isEqualToString:@"Пиццерии"]) {
                    image = [UIImage imageNamed:@"pizza.png"];
                }
                else if ([name isEqualToString:@"Рестораны"]) {
                    image = [UIImage imageNamed:@"restaurants.png"];
                }
                else if ([name isEqualToString:@"Столовые"]) {
                    image = [UIImage imageNamed:@"stolovie.png"];
                }
                else if ([name isEqualToString:@"Фаст-фуды"]) {
                    image = [UIImage imageNamed:@"fastfood.png"];
                }
                
                NSDictionary *t = [NSDictionary dictionaryWithObjectsAndKeys:ID, @"id", name, @"name", image, @"image", @"type", @"category", nil];
                [result addObject:t];
            }    
            [delegate catalogDidGetTypes:result];
        }
        else {
            [delegate catalogDidFailWithError:[dict objectForKey:@"error"]];
        }
    }];
    [request setFailedBlock:^{
        [delegate catalogDidFailWithError:request.error.localizedDescription];
    }];
                    
    [request startAsynchronous];
}

+ (void)getCuisinesWithDelegate:(id<CatalogDelegate>)delegate {
    NSString *params = [[NSString stringWithFormat:@"?request=catalog_cuisines"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSDictionary *dict = [request.responseString JSONValue];
        NSArray *cuisines = [dict objectForKey:@"catalog_cuisines"];
        
        NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
        
        NSMutableArray *result = [[NSMutableArray alloc] init];
        BOOL response = [[dict objectForKey:@"response"] boolValue];
        if (response) {
            for (NSDictionary *cuisine in cuisines) {
                NSString *ID = [cuisine objectForKey:@"id"];
                NSString *name = [cuisine objectForKey:@"name"];
                UIImage *image;
                if ([name isEqualToString:@"американская"]) {
                    image = [UIImage imageNamed:@"american.png"];
                }
                else if ([name isEqualToString:@"восточная"]) {
                    image = [UIImage imageNamed:@"east.png"];
                }
                else if ([name isEqualToString:@"итальянская"]) {
                    image = [UIImage imageNamed:@"italian.png"];
                }
                else if ([name isEqualToString:@"японская"]) {
                    image = [UIImage imageNamed:@"japan.png"];
                }
                else if ([name isEqualToString:@"мексиканская"]) {
                    image = [UIImage imageNamed:@"mexican.png"];
                }
                else if ([name isEqualToString:@"китайская"]) {
                    image = [UIImage imageNamed:@"china.png"];
                }
                else if ([name isEqualToString:@"европейская"]) {
                    image = [UIImage imageNamed:@"europe.png"];
                }
                else if ([name isEqualToString:@"фьюжн"]) {
                    image = [UIImage imageNamed:@"fusion.png"];
                }
                else if ([name isEqualToString:@"интернациональная"]) {
                    image = [UIImage imageNamed:@"international.png"];
                }
                else if ([name isEqualToString:@"кавказская"]) {
                    image = [UIImage imageNamed:@"kavkaz.png"];
                }
                else if ([name isEqualToString:@"русская"]) {
                    image = [UIImage imageNamed:@"russian.png"];
                }
                else if ([name isEqualToString:@"украинская"]) {
                    image = [UIImage imageNamed:@"ukraine.png"];
                }
                else if ([name isEqualToString:@"узбекская"]) {
                    image = [UIImage imageNamed:@"uzbek.png"];
                }
                else if ([name isEqualToString:@"китайская"]) {
                    image = [UIImage imageNamed:@"china.png"];
                }
                else if ([name isEqualToString:@"татарская"]) {
                    image = [UIImage imageNamed:@"tatar.png"];
                }
                name = [name capitalizedString];
                NSDictionary *c = [NSDictionary dictionaryWithObjectsAndKeys:ID, @"id", name, @"name", image, @"image", @"cuisine", @"category", nil];
                [result addObject:c];
            } 
            [delegate catalogDidGetCuisines:result];
        }   
        else {
            [delegate catalogDidFailWithError:[dict objectForKey:@"error"]];
        }
    }];
    [request setFailedBlock:^{
        [delegate catalogDidFailWithError:request.error.localizedDescription];
    }];
    
    [request startAsynchronous];    
}

@end

 