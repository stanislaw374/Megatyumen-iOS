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

#define VALUE_FEEDBACK @"companies_feedback"
#define KEY_OFFSET @"offset"

@interface Feedbacks() 
@property (nonatomic) int loaded;
- (void)didGetItems:(ASIHTTPRequest *)request;
@end

@implementation Feedbacks
@synthesize items = _items;
@synthesize loaded = _loaded;

#pragma mark - Lazy Instantiation

- (NSMutableArray *)items {
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}

//+ (int)readCount {
//    static NSString *kFeedbacksReadCount = @"FeedbacksReadCount";
//    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    int read = 0;
//    if ([defaults objectForKey:kFeedbacksReadCount]) {
//        read = [defaults integerForKey:kFeedbacksReadCount];
//    }
//    
//    return read;
//}
//
//+ (int)count {
//    return [Catalog feedbacksCount];
//}

- (void)getItems:(int)index {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:VALUE_FEEDBACK, KEY_REQUEST, [NSNumber numberWithInt:index], KEY_OFFSET, nil];
                          
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:dict] forKey:KEY_JSON_DATA];
    request.delegate = self;
    request.didFinishSelector = @selector(didGetItems:);
    [request startAsynchronous];
}

- (void)didGetItems:(ASIHTTPRequest *)request {
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:request.responseString];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
    
    BOOL result = [[dict objectForKey:@"response"] boolValue];
    
    if (result) {
        NSArray *comments = [dict objectForKey:@"comments"];
        
        for (NSDictionary *comment in comments) {
            Feedback *f = [[Feedback alloc] init];
            f.text = [comment objectForKey:@"text"];
            id attitudeObj = [comment objectForKey:@"attitude"];
            f.attitude = (!attitudeObj || [attitudeObj isKindOfClass:[NSNull class]]) ? 0 : [attitudeObj intValue];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            f.date = [df dateFromString:[comment objectForKey:@"date"]];
            id nameObj = [comment objectForKey:@"name"];
            f.name = (!nameObj || [nameObj isKindOfClass:[NSNull class]]) ? @"" : nameObj;
            
            [self.items addObject:f];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_FEEDBACK object:nil];
    }
    
}

@end
