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
- (void)didGetItem:(ASIHTTPRequest *)request;
- (void)didGetItems:(ASIHTTPRequest *)request;
@end

@implementation Feedbacks
@synthesize items = _items;

//Запрос отзывов
// {"request":"companies_feedback","offset":"20"}
 

- (NSMutableArray *)items {
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}

+ (int)readCount {
    static NSString *kFeedbacksReadCount = @"FeedbacksReadCount";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int read = 0;
    if ([defaults objectForKey:kFeedbacksReadCount]) {
        read = [defaults integerForKey:kFeedbacksReadCount];
    }
    
    return read;
}

+ (int)count {
    return [Catalog feedbacksCount];
}

- (void)getItem:(int)index {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:VALUE_FEEDBACK, @"request", index, KEY_OFFSET, nil];
                          
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:dict] forKey:@"jsonData"];
    request.delegate = self;
    request.didFinishSelector = @selector(didGetCatalogByName:);
    [request startAsynchronous];
}

- (void)didGetItem:(ASIHTTPRequest *)request {
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:request.responseString];
    BOOL result = [[dict objectForKey:@"response"] boolValue];
    if (result) {
        NSDictionary *comment = [dict objectForKey:@"comment"];
        NSString *text = [comment objectForKey:@"text"];
        int attitude = [[comment objectForKey:@"attitude"] intValue];
        NSDate *date = [comment objectForKey:@"date"];
    }
}

- (void)getItems {
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:VALUE_FEEDBACK, @"request", , nil
//    
//    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
//    [request setPostValue:[jsonWriter stringWithObject:requestDict] forKey:@"jsonData"];
//    request.delegate = self;
//    request.didFinishSelector = @selector(didGetCatalogByName:);
//    [request startAsynchronous];

    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //    [self didGetItems:nil];
    //});    
}

- (void)didGetItems:(ASIHTTPRequest *)request {
    self.items = [NSMutableArray arrayWithArray:[Catalog getAllFeedbacks]];
    dispatch_async(dispatch_get_main_queue(), ^{
       [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_FEEDBACK object:nil]; 
    });
}

@end
