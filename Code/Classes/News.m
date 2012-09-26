//
//  News.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "News.h"
#import "SBJson.h"
#import "Config.h"
#import "New.h"
#import "ASIFormDataRequest.h"
#import "Event.h"

@interface News()

@end

@implementation News
@synthesize todayCount = _todayCount;
@synthesize yesterdayCount = _yesterdayCount;
@synthesize threeDaysAgoCount = _threeDaysAgoCount;
@synthesize weekAgoCount = _weekAgoCount;
@synthesize othersCount = _othersCount;
@synthesize items = _items;
//@synthesize count = _count;
@synthesize todayLoaded = _todayLoaded;
@synthesize yesterdayLoaded = _yesterdayLoaded;
@synthesize threeDaysAgoLoaded = _threeDaysAgoLoaded;
@synthesize weekAgoLoaded = _weekAgoLoaded;
@synthesize othersLoaded = _othersLoaded;


#pragma mark - Lazy Instantiation

- (NSMutableDictionary *)items {
    if (!_items) {
        _items = [[NSMutableDictionary alloc] init];
    }
    return _items;
}

- (void)getCount {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"news_count", @"request", nil];
    
    NSLog(@"Запрос количества новостей: %@", dict.description);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    [request setPostValue:[jsonWriter stringWithObject:dict] forKey:@"jsonData"];
    //request.delegate = self;
    //request.didFinishSelector = @selector(didGetCount:);
    [request startSynchronous];
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict2 = [jsonParser objectWithString:[request responseString]];
    
    NSLog(@"Запрос количества новостей (ответ): %@", dict2.description);
    
    self.todayCount = [[dict2 objectForKey:@"news_today"] intValue];
    self.yesterdayCount = [[dict2 objectForKey:@"news_yesterday"] intValue];
    self.threeDaysAgoCount = [[dict2 objectForKey:@"news_3_days"] intValue];
    self.weekAgoCount = [[dict2 objectForKey:@"news_week"] intValue];
    self.othersCount = [[dict2 objectForKey:@"other_news"] intValue];

}

- (void)getNewsForSection:(int)section withLimit:(int)limit {
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"news_titles", @"request", [NSNumber numberWithInt:section], @"section", [NSNumber numberWithInt:offsets[section]], @"offset", [NSNumber numberWithInt:limit], @"limit", nil];
    NSString *query = [writer stringWithObject:dict];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:query forKey:@"jsonData"];
    [request startSynchronous];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict2 = [parser objectWithString:request.responseString];
    BOOL response = [[dict2 objectForKey:@"response"] boolValue];
    if (response) {
        NSArray *titles = [dict2 objectForKey:@"titles"];
        int i = 0;
        for (NSDictionary *title in titles) {
            New *new = [[New alloc] init];
            new.ID = [[title objectForKey:@"id"] intValue];
            new.title = [title objectForKey:@"title"];
            new.imageURL = [NSURL URLWithString: [kWEBSITE stringByAppendingPathComponent:[title objectForKey:@"image"]]];
            new.thumbnailURL = [NSURL URLWithString: [kWEBSITE stringByAppendingPathComponent:[title objectForKey:@"thumbnail"]]];

            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:offsets[section] + i++ inSection:section];
            [self.items setObject:new forKey:indexPath];
        }
        offsets[section] += limit;
        switch (section) {
            case 0: self.todayLoaded += i; break;
            case 1: self.yesterdayLoaded += i; break;
            case 2: self.threeDaysAgoLoaded += i; break;
            case 3: self.weekAgoLoaded += i; break;
            case 4: self.othersLoaded += i; break;
        }
    }
}


+ (void)get:(int)page withDelegate:(id<NewsDelegate>)delegate {
    NSString *params = [[NSString stringWithFormat:@"?request=news_titles&page=%d", page] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSDictionary *rd = [request.responseString JSONValue];
        BOOL response = [[rd objectForKey:@"response"] boolValue];
        if (response) {
            NSArray *titles = [rd objectForKey:@"news_titles"];
            NSMutableArray *result = [NSMutableArray array];
            for (NSDictionary *title in titles) {
                NSString *type = [title objectForKey:@"type"];
                if ([type isEqualToString:@"news"])
                {
                    New *n = [[New alloc] init];
                    n.ID = [[title objectForKey:@"id"] intValue];
                    n.type = type;
                    n.title = [title objectForKey:@"title"];
                    n.thumbnailURL = [NSURL URLWithString:[title objectForKey:@"thumbnail"] relativeToURL:kWEBSITE_URL];
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    // 2012-04-13 13:35:58
                    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                    n.date = [df dateFromString:[title objectForKey:@"date"]];
                    [result addObject:n];
                } else {
                    Event *e = [[Event alloc] init];
                    e.ID = [[title objectForKey:@"id"] intValue];
                    e.companyID = [[title objectForKey:@"company_id"] intValue];
                    e.companyName = [title objectForKey:@"company_name"];
                    e.title = [title objectForKey:@"title"];
                    e.text = [title objectForKey:@"text"];
                    e.type = type;
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                    e.date = [df dateFromString:[title objectForKey:@"date"]];
                    id thumbObj = [title objectForKey:@"thumbnail"];
                    if (![thumbObj isEqual:[NSNull null]]) {
                        NSString *str = (NSString *)[title objectForKey:@"thumbnail"];
                        //e.thumbnailURL = [NSURL URLWithString:[event objectForKey:@"thumbnail"] relativeToURL:kWEBSITE_URL];
                        e.thumbnailURL = [NSURL URLWithString:[kWEBSITE stringByAppendingPathComponent:str]];
                        NSLog(@"Event thumb: %@", e.thumbnailURL.description);
                    }
                    [result addObject:e];
                }
                
            }
            [delegate newsDidLoad:result];
        }
    }];
    
    [request setFailedBlock:^{
        [delegate newsDidFailWithError:request.error.localizedDescription];
    }];
    
    [request startAsynchronous];
}


@end