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
#import "Config.h"

#define KEY_LAST_LAUNCH_DATE @"LastLaunchDate"

@interface Items()
@end

@implementation Items

+ (NSDictionary *)getCount {    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *lastLaunchDate = (NSDate *)[userDefaults objectForKey:KEY_LAST_LAUNCH_DATE];
    NSString *date = lastLaunchDate ? [df stringFromDate:lastLaunchDate] : @"1970-01-01 00:00:00";
    NSLog(@"Last launch date was: %@", lastLaunchDate.description);
    
    NSString *params = [[NSString stringWithFormat:@"?request=items_count&date=%@", date] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSDictionary *rd = [request.responseString JSONValue];
    return rd;
    
//    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"items_count", @"request", date, @"date", nil];
//    NSLog(@"Items get count: %@", dict.description);
//    
//    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
//    NSString *query = [writer stringWithObject:dict];
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
//    [request setPostValue:query forKey:@"jsonData"];
//    [request startSynchronous];
//    
//    SBJsonParser *parser = [[SBJsonParser alloc] init];
//    NSDictionary *dict2 = [parser objectWithString:request.responseString];
//    
//    NSLog(@"Items get count response: %@", dict2.description);
//    
//    return dict2;
}

@end
