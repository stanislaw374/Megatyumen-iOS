//
//  Company.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 24.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Company.h"
#import "Config.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "User.h"
#import "Feedback.h"
#import "MenuItem.h"
#import "Event.h"

@implementation Company
@synthesize ID = _ID;
@synthesize name = _name;
@synthesize address = _address;
@synthesize coordinate = _coordinate;
@synthesize logoURL = _logoURL;
@synthesize feedbacksCount = _feedbacksCount;
@synthesize checkinCount = _checkinCount;
@synthesize description = _description;
@synthesize images = _images;
@synthesize thumbnails = _thumbnails;
@synthesize delegate = _delegate;
@synthesize phone = _phone;
@synthesize website = _website;
@synthesize type = _type;
@synthesize hours = _hours;
@synthesize feedbacks = _feedbacks;
@synthesize menu = _menu;
@synthesize events = _events;
@synthesize distance = _distance;

- (NSMutableArray *)images {
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}

- (NSMutableArray *)thumbnails {
    if (!_thumbnails) {
        _thumbnails = [NSMutableArray array];
    }
    return _thumbnails;
}

- (void)getImages {
    NSString *params = [[NSString stringWithFormat:@"?request=catalog_company_images&id=%d", self.ID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSDictionary *rd = [request.responseString JSONValue];
        BOOL response = [[rd objectForKey:@"response"] boolValue];
        if (response) {
            NSArray *images = [rd objectForKey:@"images"];
            for (NSDictionary *image in images) {
                NSURL *url = [NSURL URLWithString:[image objectForKey:@"image"] relativeToURL:kWEBSITE_URL];
                [self.images addObject:url];
                url = [NSURL URLWithString:[image objectForKey:@"thumbnail"] relativeToURL:kWEBSITE_URL];
                [self.thumbnails addObject:url];
            }
            [self.delegate companyImagesDidLoad];
        }
        else {
            [self.delegate companyDidFailWithError:@""];
        }
    }];
    
    [request setFailedBlock:^{
        [self.delegate companyDidFailWithError:request.error.localizedDescription];
    }];
    
    [request startAsynchronous];
}

- (void)checkin:(int)attitude withText:(NSString *)text {
    NSString *params = [[NSString stringWithFormat:@"?request=checkin&id=%d&token=%@&attitude=%d&text=%@", self.ID, [User sharedUser].token, attitude, text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSDictionary *rd = [request.responseString JSONValue];
        BOOL response = [[rd objectForKey:@"response"] boolValue];
        if (response) {
            [self.delegate companyDidCheckin];
        }
        else {
            [self.delegate companyDidFailWithError:[rd objectForKey:@"error"]];
        }
    }];
    
    [request setFailedBlock:^{
        [self.delegate companyDidFailWithError:request.error.localizedDescription];
    }];
    
    [request startAsynchronous];
}

- (void)getDetails {
    NSString *params = [[NSString stringWithFormat:@"?request=catalog_company_details&id=%d", self.ID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        
        NSDictionary *rd = [request.responseString JSONValue];
        BOOL response = [[rd objectForKey:@"response"] boolValue];
        if (response) {
            self.type = [rd objectForKey:@"type"];
            self.hours = [rd objectForKey:@"weekdays_hours"];
            self.website = [rd objectForKey:@"website"];
            self.phone = [rd objectForKey:@"phone"];
            id logoObj = [rd objectForKey:@"logo"];
            if (![logoObj isEqual:[NSNull null]]) {
                self.logoURL = [NSURL URLWithString:logoObj relativeToURL:kWEBSITE_URL];
                NSLog(@"receive logo: %@", self.logoURL.description);
            }
            double lat = [[rd objectForKey:@"lat"] doubleValue];
            double lng = [[rd objectForKey:@"lng"] doubleValue];
            self.coordinate = CLLocationCoordinate2DMake(lat, lng);
            [self.delegate companyDetailsDidLoad];
        }
        else {
            [self.delegate companyDidFailWithError:@""];
        }
    }];
    
    [request setFailedBlock:^{
        [self.delegate companyDidFailWithError:request.error.localizedDescription];
    }];
    
    [request startAsynchronous];
}

- (void)getFeedbacks {
    NSString *params = [[NSString stringWithFormat:@"?request=catalog_company_feedbacks&id=%d", self.ID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSDictionary *rd = [request.responseString JSONValue];
        BOOL response = [[rd objectForKey:@"response"] boolValue];
        if (response) {
            NSMutableArray *result = [NSMutableArray array];
            NSArray *feedbacks = [rd objectForKey:@"company_feedbacks"];
            for (NSDictionary *feedback in feedbacks) {
                Feedback *f = [[Feedback alloc] init];
                f.companyID = self.ID;
                f.companyName = self.name;
                f.text = [feedback objectForKey:@"text"];
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                f.date = [df dateFromString:[feedback objectForKey:@"date"]];
                f.attitude = [[feedback objectForKey:@"attitude"] intValue];
                f.userName = [feedback objectForKey:@"user_name"];
                
                [result addObject:f];
            }
            self.feedbacks = result;
            [self.delegate companyFeedbacksDidLoad];
        }
        else {
            [self.delegate companyDidFailWithError:@"У заведения нет отзывов"];
        }
    }];
    
    [request setFailedBlock:^{
        [self.delegate companyDidFailWithError:request.error.localizedDescription];
    }];
    
    [request startAsynchronous];
}

- (void)getMenu {
    NSString *params = [[NSString stringWithFormat:@"?request=catalog_company_menu&id=%d", self.ID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSDictionary *rd = [request.responseString JSONValue];
        BOOL response = [[rd objectForKey:@"response"] boolValue];
        if (response) {
            NSMutableArray *result = [NSMutableArray array];
            NSArray *menu = [rd objectForKey:@"company_menu"];
            for (NSDictionary *menuItem in menu) {
                MenuItem *m = [[MenuItem alloc] init];
                m.title = [menuItem objectForKey:@"title"];
                m.price = [[menuItem objectForKey:@"price"] doubleValue];
                NSString *imageStr = [menuItem objectForKey:@"image"];    
                if (![imageStr isEqual:[NSNull null]]) {
                    m.imageURL = [NSURL URLWithString:imageStr relativeToURL:kWEBSITE_URL];
                }
                
                [result addObject:m];
            }
            self.menu = result;
            [self.delegate companyMenuDidLoad];
        }
        else {
            if ([self.delegate respondsToSelector:@selector(companyDidFailWithError:)]) {
                [self.delegate companyDidFailWithError:@"У заведения не добавлено меню"];
            }
        }
    }];
    
    [request setFailedBlock:^{
        [self.delegate companyDidFailWithError:request.error.localizedDescription];
    }];
    
    [request startAsynchronous];
}

- (void)getEvents {
    NSString *params = [[NSString stringWithFormat:@"?request=catalog_company_events&id=%d", self.ID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSDictionary *rd = [request.responseString JSONValue];
        BOOL response = [[rd objectForKey:@"response"] boolValue];
        if (response) {
            NSMutableArray *result = [NSMutableArray array];
            NSArray *events = [rd objectForKey:@"company_events"];
            for (NSDictionary *event in events) {
                Event *e = [[Event alloc] init];
                e.ID = [[event objectForKey:@"id"] intValue];
                e.companyID = self.ID;
                e.companyName = self.name;
                e.text = [event objectForKey:@"text"];
                e.title = [event objectForKey:@"title"];
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                e.date = [df dateFromString:[event objectForKey:@"date"]];
                NSString *imageStr = [event objectForKey:@"image"];
                NSString *thumbStr = [event objectForKey:@"thumbnail"];
                if (![imageStr isEqual:[NSNull null]]) {
                    e.imageURL = [NSURL URLWithString:imageStr relativeToURL:kWEBSITE_URL];
                    e.thumbnailURL = [NSURL URLWithString:thumbStr relativeToURL:kWEBSITE_URL];
                }
                
                [result addObject:e];
            }
            self.events = result;
            [self.delegate companyEventsDidLoad];
        }
        else {
            [self.delegate companyDidFailWithError:@"У заведения нет событий"];
        }
    }];
    
    [request setFailedBlock:^{
        [self.delegate companyDidFailWithError:request.error.localizedDescription];
    }];
    
    [request startAsynchronous];
}

@end
