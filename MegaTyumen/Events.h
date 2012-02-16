//
//  Events.h
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

//NSString *const kNOTIFICATION_DID_GET_EVENTS = @"megatyumen.didGetEvents";
#define kNOTIFICATION_DID_GET_EVENTS @"megatyumen.didGetCompanyNews"

@interface Events : NSObject <ASIHTTPRequestDelegate>

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, readonly) BOOL result;
@property (nonatomic, copy) NSString *error; 

- (void)getItem:(int)offset;

@end
