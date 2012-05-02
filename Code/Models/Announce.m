//
//  PartyAnnounce.m
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Announce.h"
#import "Config.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"

@implementation Announce
@synthesize title = _title;
@synthesize text = _text;
@synthesize image = _image;

+ (void)getWithDelegate:(id<AnnounceDelegate>)delegate {
    NSString *params = [@"?request=announces" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSDictionary *rd = [request.responseString JSONValue];
        BOOL response = [[rd objectForKey:@"response"] boolValue];
        if (response) {
            NSDictionary *announces = [rd objectForKey:@"announces"];
            NSMutableArray *result = [NSMutableArray array];
            for (NSDictionary *announce in announces) {
                Announce *a = [[Announce alloc] init];
                a.title = [announce objectForKey:@"title"];
                a.text = [announce objectForKey:@"text"];
                id imageObj = [announce objectForKey:@"image"];
                if (![imageObj isEqual:[NSNull null]]) {
                    a.image = [NSURL URLWithString:imageObj relativeToURL:kWEBSITE_URL];
                }
                [result addObject:a];
            }
            [delegate announcesDidLoad:result];
        }
        else {
            [delegate announcesDidFailWithError:@""];
        }
    }];
    [request setFailedBlock:^{
        [delegate announcesDidFailWithError:request.error.localizedDescription];
    }];
    [request startAsynchronous];
}

@end
