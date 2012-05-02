//
//  FeedbackItem.m
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Feedback.h"
#import "Config.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"

@implementation Feedback
@synthesize text = _text;
@synthesize date = _date;
@synthesize attitude = _attitude;
@synthesize userName = _userName;
@synthesize companyName = _companyName;
@synthesize companyID = _companyID;

+ (void)get:(int)page withDelegate:(id<FeedbackDelegate>)delegate {
    NSString *params = [[NSString stringWithFormat:@"?request=feedbacks&page=%d", page] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSDictionary *rd = [request.responseString JSONValue];
        BOOL response = [[rd objectForKey:@"response"] boolValue];
        if (response) {
            NSDictionary *feedbacks = [rd objectForKey:@"feedbacks"];
            NSMutableArray *result = [NSMutableArray array];
            for (NSDictionary *feedback in feedbacks) {
                Feedback *f = [[Feedback alloc] init];
                f.text = [feedback objectForKey:@"text"];
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                f.date = [df dateFromString:[feedback objectForKey:@"date"]];
                f.userName = [feedback objectForKey:@"user_name"];
                f.companyID = [[feedback objectForKey:@"company_id"] intValue];
                f.companyName = [feedback objectForKey:@"company_name"];
                f.attitude = [[feedback objectForKey:@"attitude"] intValue];
                
                [result addObject:f];
            }
            [delegate feedbacksDidLoad:result];
        }
        else {
            [delegate feedbacksDidFailWithError:@""];
        }
    }];
    [request setFailedBlock:^{
        [delegate feedbacksDidFailWithError:request.error.localizedDescription];
    }];
    [request startAsynchronous];
}

@end
