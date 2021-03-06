//
//  Events.m
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Events.h"
#import "Event.h"
#import "ASIFormDataRequest.h"
#import "Config.h"
#import "Catalog.h"
#import "SBJSON.h"
#import "New.h"

#define VALUE_EVENTS @"catalogue_events"
#define KEY_OFFSET @"offset"
#define KEY_LIMIT @"limit"

@interface Events()
@property (nonatomic) int offset;
//- (void)didGetItems:(ASIHTTPRequest *)request;
@end

@implementation Events
@synthesize items = _items;
@synthesize isLoaded = _isLoaded;
//@synthesize error = _error;
//@synthesize result = _RESULT;
@synthesize offset = _offset;
//@synthesize isEntirelyLoaded = _isEntirelyLoaded;

- (NSMutableArray *)items {
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}



- (void)getItems {
    self.isLoaded = NO;
    int limit = 10;
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:VALUE_EVENTS, KEY_REQUEST, [NSNumber numberWithInt:limit], KEY_LIMIT, [NSNumber numberWithInt:self.offset], KEY_OFFSET, nil];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *query = [writer stringWithObject:dict];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:query forKey:KEY_JSON_DATA];
    //request.delegate = self;
    //[request setDidFinishSelector:@selector(didGetItems:)];
    //request.timeOutSeconds = kREQUEST_TIMEOUT;
    [request startSynchronous];    
    
    self.isLoaded = YES;
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict2 = [parser objectWithString:[request responseString]];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict2.description);
    
    BOOL result = [[dict2 objectForKey:@"response"] boolValue];
    if (result) {        
        NSArray *events = [dict2 objectForKey:@"events"];
        for (NSDictionary *event in events) {
            Event *e = [[Event alloc] init];
            e.ID = [[event objectForKey:@"id"] intValue];
            e.imageURL = [NSURL URLWithString:[event objectForKey:@"image"] relativeToURL:kWEBSITE_URL];
            NSString *thumbnailStr = [event objectForKey:@"thumbnail"];
            e.thumbnailURL = thumbnailStr.length ? [NSURL URLWithString:thumbnailStr relativeToURL:kWEBSITE_URL] : thumbnailStr;
            e.text = [event objectForKey:@"text"];
            e.title = [event objectForKey:@"title"];
            e.companyName = [event objectForKey:@"company_name"];
            e.companyID = [[event objectForKey:@"company_id"] intValue];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            e.date = [df dateFromString:[event objectForKey:@"date"]];
            [self.items addObject:e];
        }
        self.offset += limit;
    }
    else {
        self.isLoaded = YES;
    }
}

//- (void)didGetItems:(ASIHTTPRequest *)request {    
//    self.isLoaded = YES;
//    
//    SBJsonParser *parser = [[SBJsonParser alloc] init];
//    NSDictionary *dict = [parser objectWithString:[request responseString]];
//    
//    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
//    
//    BOOL result = [[dict objectForKey:@"response"] boolValue];
//    if (result) {        
//        NSArray *events = [dict objectForKey:@"events"];
//        for (NSDictionary *event in events) {
//            Event *e = [[Event alloc] init];
//            e.imageUrl = [NSURL URLWithString:[event objectForKey:@"image"] relativeToURL:kWEBSITE_URL];
//            e.announce = [event objectForKey:@"announce"];
//            e.title = [event objectForKey:@"title"];
//            e.companyName = [event objectForKey:@"company_name"];
//            e.companyID = [[event objectForKey:@"company_id"] intValue];
//            NSDateFormatter *df = [[NSDateFormatter alloc] init];
//            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//            e.date = [df dateFromString:[event objectForKey:@"date"]];
//            [self.items addObject:e];
//        }
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_EVENTS object:self];
//    }
//}

@end
