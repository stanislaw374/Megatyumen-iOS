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

@interface Events()
- (void)didGetItems:(ASIHTTPRequest *)request;
@end

@implementation Events
@synthesize items = _items;

- (NSMutableArray *)items {
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}

+ (int)readCount {
    static NSString *kEventsReadCount = @"EventsReadCount";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int read = 0;
    if ([defaults objectForKey:kEventsReadCount]) {
        read = [defaults integerForKey:kEventsReadCount];
    }
    return read;
}

+ (int)count {
    return [Catalog eventsCount];
}

- (void)getItems {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self didGetItems:nil];
    });    
}

- (void)didGetItems:(ASIHTTPRequest *)request {
    self.items = [NSMutableArray arrayWithArray:[Catalog getAllEvents]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_EVENTS object:nil];
    });
}

@end
