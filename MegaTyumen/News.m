//
//  News.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "News.h"
#import "SBJson.h"
#import "Constants.h"
#import "New.h"
#import "ASIFormDataRequest.h"

@interface News()
//@property (nonatomic) int loadingCount;
//@property (nonatomic) int section;
//@property (nonatomic) int row;
//@property (nonatomic, strong) NSMutableArray *rows;
//- (void)didGetCount:(ASIHTTPRequest *)request;
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
//@synthesize loadingCount = _loadingCount;
//@synthesize section = _section;
//@synthesize row = _row;
//@synthesize rows = _rows;
//@synthesize isLoaded = _isLoaded;
//@synthesize offset = _offset;

#pragma mark - Lazy Instantiation

//- (NSMutableArray *)rows {
//    if (!_rows) {
//        _rows = [[NSMutableArray alloc] initWithCapacity:5];
//        for (int i = 0; i < 5; i++) {
//            [_rows insertObject:[NSNull null] atIndex:i];
//        }
//    }
//    return _rows;
//}

- (NSMutableDictionary *)items {
    if (!_items) {
        _items = [[NSMutableDictionary alloc] init];
    }
    return _items;
}

//+ (int)count {
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"news_count", @"request", nil];
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
//    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
//    [request setPostValue:[jsonWriter stringWithObject:dict] forKey:@"jsonData"];
//    
//    [request startSynchronous];
//    
//    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//    NSDictionary *dict2 = [jsonParser objectWithString:[request responseString]];
//    
//    NSLog(@"[News count] : %@", dict2.description);
//    
//    int todayCount = [[dict2 objectForKey:@"news_today"] intValue];
//    int yesterdayCount = [[dict2 objectForKey:@"news_yesterday"] intValue];
//    int threeDaysAgoCount = [[dict2 objectForKey:@"news_3"] intValue];
//    int weekAgoCount = [[dict2 objectForKey:@"news_week"] intValue];
//    int othersCount = [[dict2 objectForKey:@"news_other"] intValue];
//    int count = todayCount + yesterdayCount + threeDaysAgoCount + weekAgoCount + othersCount;
//    
//    return count;
//}
//
//+ (int)readCount {
//    static NSString *kNewsReadCount = @"NewsReadCount";
//    int read = 0;
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if ([defaults objectForKey:kNewsReadCount]) {
//        read = [defaults integerForKey:kNewsReadCount];
//    }
//    return read;
//}
//
//+ (void)setReadCount:(int)value {
////    static NSString *kNewsReadCount = @"NewsReadCount";
////    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
////    [defaults setInteger:value forKey:kNewsReadCount];
////    [defaults synchronize];
//}

//- (id)init {
//    if (self = [super init]) {
//        //self.items = [NSMutableDictionary dictionary];
//        //[self getNewsCount];
//    }
//    return self;
//}

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
    //int totalCount = self.todayCount + self.yesterdayCount + self.threeDaysAgoCount + self.weekAgoCount + self.othersCount;   
    
//    if (!totalCount) {
//        self.isLoaded = YES;
//    }
//    else {
//        self.isLoaded = NO;
//    }
    
    //self.row = self.section = 0;
//    [self.rows replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:self.todayCount]];
//    [self.rows replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:self.yesterdayCount]];
//    [self.rows replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:self.threeDaysAgoCount]];
//    [self.rows replaceObjectAtIndex:3 withObject:[NSNumber numberWithInt:self.weekAgoCount]];
//    [self.rows replaceObjectAtIndex:4 withObject:[NSNumber numberWithInt:self.othersCount]];
}

//- (void)didGetCount:(ASIHTTPRequest *)request {
//    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//    NSDictionary *dict = [jsonParser objectWithString:[request responseString]];
//    
//    NSLog(@"Запрос количества новостей (ответ): %@", dict.description);
//    
//    self.todayCount = [[dict objectForKey:@"news_today"] intValue];
//    self.yesterdayCount = [[dict objectForKey:@"news_yesterday"] intValue];
//    self.threeDaysAgoCount = [[dict objectForKey:@"news_3"] intValue];
//    self.weekAgoCount = [[dict objectForKey:@"news_week"] intValue];
//    self.othersCount = [[dict objectForKey:@"other_news"] intValue];
//    self.count += self.todayCount + self.yesterdayCount + self.threeDaysAgoCount + self.weekAgoCount + self.othersCount;   
//    
//    self.row = self.section = 0;
//    [self.rows replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:self.todayCount]];
//    [self.rows replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:self.yesterdayCount]];
//    [self.rows replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:self.threeDaysAgoCount]];
//    [self.rows replaceObjectAtIndex:3 withObject:[NSNumber numberWithInt:self.weekAgoCount]];
//    [self.rows replaceObjectAtIndex:4 withObject:[NSNumber numberWithInt:self.othersCount]];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_NEWS_COUNT object:nil];
//}

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
            new.image = [NSURL URLWithString:[title objectForKey:@"image"] relativeToURL:kWEBSITE_URL];

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

//- (void)getNextNews {
//    self.loadingCount = 0;
//    
//    for (int i = self.section; i < 5; i++) {
//        for (int j = self.row; j < [[self.rows objectAtIndex:i] intValue]; j++) {
//            New *new = [[New alloc] init];
//            new.parent = self;
//            [self.items setObject:new forKey:[NSIndexPath indexPathForRow:j inSection:i]];
//            [new loadDataForRow:j inSection:i];
//            self.row++;
//            if (++self.loadingCount == 5) return;            
//        }
//        self.section++;
//    }
//}
//
//- (void)didGetNewForRow:(int)row_ inSection:(int)section_ {
//    switch (section_) {
//        case 0: self.todayLoaded++; break;
//        case 1: self.yesterdayLoaded; break;  
//        case 2: self.threeDaysAgoLoaded++; break;
//        case 3: self.weekAgoLoaded++; break;
//        case 4: self.othersLoaded++; break;
//    }
//    
//    if (self.loadingCount) { self.loadingCount--; }
//
//    if (!self.loadingCount) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_NEWS object:nil];
//    }
//}

@end