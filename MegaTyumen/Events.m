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
#import "Constants.h"
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

- (NSMutableArray *)items {
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}
//
//+ (int)readCount {
//    static NSString *kEventsReadCount = @"EventsReadCount";
//    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    int read = 0;
//    if ([defaults objectForKey:kEventsReadCount]) {
//        read = [defaults integerForKey:kEventsReadCount];
//    }
//    return read;
//}

- (void)getItems {
    self.isLoaded = NO;
    int limit = 10;
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:VALUE_EVENTS, KEY_REQUEST, [NSNumber numberWithInt:limit], KEY_LIMIT, [NSNumber numberWithInt:self.offset], KEY_OFFSET, nil];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *query = [writer stringWithObject:dict];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:query forKey:KEY_JSON_DATA];
    request.delegate = self;
    [request setDidFinishSelector:@selector(didGetItems:)];
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
            //Event *e = [[Event alloc] init];
            e.ID = [[event objectForKey:@"id"] intValue];
            e.image = [NSURL URLWithString:[event objectForKey:@"image"] relativeToURL:kWEBSITE_URL];
            //e.image = [NSURL URLWithString:[event objectForKey:@"image"] relativeToURL:kWEBSITE_URL];
            e.text = [event objectForKey:@"text"];
            //e.announce = [event objectForKey:@"announce"];
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
