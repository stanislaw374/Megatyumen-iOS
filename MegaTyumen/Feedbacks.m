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

@interface Feedbacks() 
@property (nonatomic) int offset;
@property (nonatomic) int loaded;
//- (void)didGetItems:(ASIHTTPRequest *)request;
@end

@implementation Feedbacks
@synthesize items = _items;
@synthesize loaded = _loaded;
@synthesize offset = _offset;

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

- (void)getItems {
    int limit = 70;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"companies_feedback", KEY_REQUEST, [NSNumber numberWithInt:self.offset], @"offset", [NSNumber numberWithInt:limit], @"limit", nil];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
    
    //self.offset += limit;
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:dict] forKey:KEY_JSON_DATA];
    //request.delegate = self;
    //request.didFinishSelector = @selector(didGetItems:);
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
            f.companyName = [comment objectForKey:@"company_name"];
            
            [self.items addObject:f];
        }
        //[[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_FEEDBACK object:nil];
        self.offset += limit;
    }
}

//- (void)didGetItems:(ASIHTTPRequest *)request {
//    SBJsonParser *parser = [[SBJsonParser alloc] init];
//    NSDictionary *dict = [parser objectWithString:request.responseString];
//    
//    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
//    
//    BOOL result = [[dict objectForKey:@"response"] boolValue];
//    
//    if (result) {
//        NSArray *comments = [dict objectForKey:@"comments"];
//        
//        for (NSDictionary *comment in comments) {
//            Feedback *f = [[Feedback alloc] init];
//            f.text = [comment objectForKey:@"text"];
//            id attitudeObj = [comment objectForKey:@"attitude"];
//            f.attitude = (!attitudeObj || [attitudeObj isKindOfClass:[NSNull class]]) ? 0 : [attitudeObj intValue];
//            NSDateFormatter *df = [[NSDateFormatter alloc] init];
//            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//            f.date = [df dateFromString:[comment objectForKey:@"date"]];
//            id nameObj = [comment objectForKey:@"name"];
//            f.name = (!nameObj || [nameObj isKindOfClass:[NSNull class]]) ? @"" : nameObj;
//            
//            [self.items addObject:f];
//        }
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_FEEDBACK object:nil];
//    }
//    
//}

@end
