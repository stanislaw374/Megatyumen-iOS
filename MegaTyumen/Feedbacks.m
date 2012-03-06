//
//  Feedback.m
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Feedbacks.h"
#import "Feedback.h"
#import "Constants.h"
#import "ASIFormDataRequest.h"
#import "Catalog.h"
#import "SBJsonWriter.h"
#import "SBJsonParser.h"
#import "Items.h"

@interface Feedbacks() 
@property (nonatomic) int offset;
//@property (nonatomic) int loadedCount;
@property (nonatomic) int allCount;
@property (nonatomic) BOOL isAllCountLoaded;
@end

@implementation Feedbacks
@synthesize items = _items;
//@synthesize loadedCount = _loadedCount;
@synthesize offset = _offset;
@synthesize isLoaded = _isLoaded;
@synthesize allCount = _allCount;
@synthesize isAllCountLoaded = _isAllCountLoaded;
@synthesize isEntirelyLoaded = _isEntirelyLoaded;

#pragma mark - Lazy Instantiation

- (NSMutableArray *)items {
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}

- (int)allCount {
    if (!self.isAllCountLoaded) {
        _allCount = [[[Items getCount] objectForKey:KEY_COMMENTS_COUNT] intValue];
        self.isAllCountLoaded = YES;
    }
    return _allCount;
}

- (void)getItems {
    self.isLoaded = NO;
    
    int limit = 10;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"companies_feedback", KEY_REQUEST, [NSNumber numberWithInt:self.offset], @"offset", [NSNumber numberWithInt:limit], @"limit", nil];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
    
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:dict] forKey:KEY_JSON_DATA];
    //request.timeOutSeconds = kREQUEST_TIMEOUT;
    [request startSynchronous];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict2 = [parser objectWithString:request.responseString];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict2.description);
    
    BOOL result = [[dict2 objectForKey:@"response"] boolValue];
    
    if (result) {
        NSArray *comments = [dict2 objectForKey:@"comments"];
        
        for (NSDictionary *comment in comments) {
            Feedback *f = [[Feedback alloc] init];
            f.text = [comment objectForKey:@"text"];
            id attitudeObj = [comment objectForKey:@"attitude"];
            f.attitude = (!attitudeObj || [attitudeObj isKindOfClass:[NSNull class]]) ? 0 : [attitudeObj intValue];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            f.date = [df dateFromString:[comment objectForKey:@"date"]];
            id nameObj = [comment objectForKey:@"user_name"];
            f.userName = (!nameObj || [nameObj isKindOfClass:[NSNull class]]) ? @"" : nameObj;
            f.companyID = [[comment objectForKey:@"company_id"] intValue];
            f.companyName = [comment objectForKey:@"company_name"];
            
            [self.items addObject:f];
            
            //self.loadedCount++;
        }
        self.offset += limit;
        
        self.isLoaded = YES;
        if (self.items.count == self.allCount) {
            self.isEntirelyLoaded = YES;
        }
    }
}

@end
