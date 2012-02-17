//
//  Items.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Items.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJSON.h"
#import "Constants.h"

@interface Items()
//- (void)didGetItems:(ASIHTTPRequest *)request;
@end

@implementation Items
@synthesize newsCount = _newsCount;
@synthesize eventsCount = _eventsCount;
@synthesize announcesCount = _announcesCount;
@synthesize feedbackCount = _feedbackCount;

- (void)getCount {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"items_count", @"request", nil];
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *query = [writer stringWithObject:dict];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:query forKey:@"jsonData"];
    [request startSynchronous];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict2 = [parser objectWithString:request.responseString];
    self.newsCount = [[dict2 objectForKey:@"news_count"] intValue];
    self.feedbackCount = [[dict2 objectForKey:@"comments_count"] intValue];
    self.eventsCount = [[dict2 objectForKey:@"events_count"] intValue];
    self.announcesCount = [[dict2 objectForKey:@"announces_count"] intValue];
}

@end
