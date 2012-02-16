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

#define KEY_REQUEST @"request"
#define VALUE_EVENTS @"catalogue_events"
#define KEY_OFFSET @"offset"
#define KEY_LIMIT @"limit"
#define KEY_JSON_DATA @"jsonData"

@interface Events()
- (void)didGetItem:(ASIHTTPRequest *)request;
@end

@implementation Events
@synthesize items = _items;
@synthesize error = _error;
@synthesize result = _RESULT;

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

- (void)getItem:(int)offset {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:VALUE_EVENTS, KEY_REQUEST, [NSNumber numberWithInt:1], KEY_LIMIT, [NSNumber numberWithInt:offset], KEY_OFFSET, nil];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *query = [writer stringWithObject:dict];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:query forKey:KEY_JSON_DATA];
    request.delegate = self;
    [request setDidFinishSelector:@selector(didGetItem:)];
    [request startAsynchronous];    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self didGetItem:nil];
//    });    
}

- (void)didGetItem:(ASIHTTPRequest *)request {
    //self.items = [NSMutableArray arrayWithArray:[Catalog getAllEvents]];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_EVENTS object:nil];
//    });
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:[request responseString]];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
    
    _RESULT = [[dict objectForKey:@"response"] boolValue];
    if (!_RESULT) {
        _error = [dict objectForKey:@"error"];
    }
    else {
        NSArray *events = [dict objectForKey:@"events"];
        for (NSDictionary *event in events) {
            Event *e = [[Event alloc] init];
            e.imageUrl = [NSURL URLWithString:[event objectForKey:@"image"] relativeToURL:kWEBSITE_URL];
            e.announce = [event objectForKey:@"announce"];
            e.title = [event objectForKey:@"title"];
            e.companyName = [event objectForKey:@"company_name"];
            e.companyID = [[event objectForKey:@"company_id"] intValue];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_EVENTS object:self];
}

@end
