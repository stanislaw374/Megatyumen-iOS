//
//  EventItem.m
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Event.h"
#import "SBJSON.h"
#import "ASIFormDataRequest.h"
#import "Config.h"
#import "Comment.h"
#import "Authorization.h"

@interface Event()
@end

@implementation Event
@synthesize companyID = _companyID;
@synthesize companyName = _companyName;
//@synthesize delegate = _delegate;

+ (void)get:(int)page withDelegate:(id<EventDelegate>)delegate {
    NSString *params = [[NSString stringWithFormat:@"?request=events&page=%d", page] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSDictionary *rd = [request.responseString JSONValue];
        BOOL response = [[rd objectForKey:@"response"] boolValue];
        if (response) {
            NSDictionary *events = [rd objectForKey:@"events"];
            NSMutableArray *result = [NSMutableArray array];
            for (NSDictionary *event in events) {
                Event *e = [[Event alloc] init];
                e.ID = [[event objectForKey:@"id"] intValue];
                e.companyID = [[event objectForKey:@"company_id"] intValue];
                e.companyName = [event objectForKey:@"company_name"];
                e.title = [event objectForKey:@"title"];
                e.text = [event objectForKey:@"text"];
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                e.date = [df dateFromString:[event objectForKey:@"date"]];
                id thumbObj = [event objectForKey:@"thumbnail"];
                if (![thumbObj isEqual:[NSNull null]]) {
                    //e.thumbnailURL = [NSURL URLWithString:[event objectForKey:@"thumbnail"] relativeToURL:kWEBSITE_URL];
                    e.thumbnailURL = [NSURL URLWithString:[kWEBSITE stringByAppendingPathComponent:[event objectForKey:@"thumbnail"]]];
                    NSLog(@"Event thumb: %@", e.thumbnailURL.description);
                }
                [result addObject:e];
            }
            [delegate eventsDidLoad:result];
        }
        else {
            [delegate eventsDidFailWithError:@""];
        }
    }];
    [request setFailedBlock:^{
        [delegate eventsDidFailWithError:request.error.localizedDescription];
    }];
    [request startAsynchronous];
}

- (void)getContent {
    NSString *params = [[NSString stringWithFormat:@"?request=event_content&id=%d", self.ID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSDictionary *rd = [request.responseString JSONValue];
        BOOL response = [[rd objectForKey:@"response"] boolValue];
        if (response) {
            id imageObj = [rd objectForKey:@"image"];
            if (![imageObj isEqual:[NSNull null]]) {
                self.imageURL = [NSURL URLWithString:[rd objectForKey:@"image"] relativeToURL:kWEBSITE_URL];
            }            
            self.text = [rd objectForKey:@"text"];
            self.user = [rd objectForKey:@"user_name"];
            int images_count = [[rd objectForKey:@"images_count"] intValue];
            self.images = [[NSMutableArray alloc] initWithCapacity:images_count];
            for (int i = 0; i < images_count; i++) {
                [self.images addObject:[NSNull null]];
            }
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            self.date = [df dateFromString:[rd objectForKey:@"date"]];
            self.link = [kWEBSITE stringByAppendingString:[rd objectForKey:@"link"]];
            self.comments = [[NSMutableArray alloc] init];
            NSArray *comments = [rd objectForKey:@"comments"];
            for (NSDictionary *comment in comments) {
                Comment *c = [[Comment alloc] init];
                c.user = [comment objectForKey:@"user_name"];
                c.text = [comment objectForKey:@"text"];
                c.date = [comment objectForKey:@"date"];
                
                [self.comments addObject:c];
            }
            [self.delegate newDidLoad];
        }
        else {
            [self.delegate newDidFailWithError:@"Ошибка"];
        }
    }];
    [request setFailedBlock:^{
        [self.delegate newDidFailWithError:request.error.localizedDescription];
    }];
    
    [request startAsynchronous];
}

- (void)getImages {
    NSString *params = [[NSString stringWithFormat:@"?request=event_images&id=%d", self.ID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSDictionary *rd = [request.responseString JSONValue];
        BOOL response = [[rd objectForKey:@"response"] boolValue];
        if (response) {
            NSArray *images = [rd objectForKey:@"new_images"];
            [self.images removeAllObjects];
            [self.thumbnails removeAllObjects];
            for (NSDictionary *image in images) {
                NSURL *url = [NSURL URLWithString:[image objectForKey:@"image"] relativeToURL:kWEBSITE_URL];
                [self.images addObject:url];
                url = [NSURL URLWithString:[image objectForKey:@"image"] relativeToURL:kWEBSITE_URL];
                [self.thumbnails addObject:url];
            }
            [self.delegate newDidGetImages];
        }
        else {
            [self.delegate newDidFailWithError:@"Ошибка"];
        }
    }];
    
    [request setFailedBlock:^{
        [self.delegate newDidFailWithError:request.error.localizedDescription];
    }];
    
    [request startAsynchronous];
}

@end
