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
#define kNOTIFICATION_DID_GET_EVENTS @"megatyumen.didGetEvents"

@interface Events : NSObject

@property (nonatomic, strong) NSMutableArray *items;

+ (int)count;
+ (int)readCount;

- (void)getItems;

@end
