//
//  PartyAnnounces.m
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Announces.h"
#import "Announce.h"
#import "Config.h"
#import "ASIFormDataRequest.h"
#import "SBJSON.h"

@interface Announces()
//- (void)didGetItems:(ASIHTTPRequest *)request;
@end

@implementation Announces
@synthesize items = _items;

- (NSMutableArray *)items {
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}

- (void)getItems { 
    int limit = 100;
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"food_announces", @"request", [NSNumber numberWithInt:limit], @"limit", nil];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
    
    NSString *jsonData = [writer stringWithObject:dict];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:jsonData forKey:@"jsonData"];
    [request startSynchronous];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict2 = [parser objectWithString:request.responseString];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict2.description);
    
    BOOL result = [[dict2 objectForKey:@"response"] intValue];
    if (result) {
        NSArray *announces = [dict2 objectForKey:@"announces"];
        for (NSDictionary *announce in announces) {
            Announce *a = [[Announce alloc] init];
            a.title = [announce objectForKey:@"title"];
            a.text = [announce objectForKey:@"text"];
            a.image = [NSURL URLWithString: [kWEBSITE stringByAppendingPathComponent:[announce objectForKey:@"image"]]];
            
            [self.items addObject:a];
        }
    }
}


@end
