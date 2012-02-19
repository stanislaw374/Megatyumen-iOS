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

+ (NSDictionary *)getCount {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"items_count", @"request", nil];
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *query = [writer stringWithObject:dict];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:query forKey:@"jsonData"];
    [request startSynchronous];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict2 = [parser objectWithString:request.responseString];
    return dict2;
}

@end
