//
//  Feedback.h
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

//NSString *const kNOTIFICATION_DID_GET_FEEDBACK = @"megatyumen.didGetFeedback";
#define kNOTIFICATION_DID_GET_FEEDBACK @"megatyumen.didGetFeedback"

@interface Feedbacks : NSObject <ASIHTTPRequestDelegate>

@property (nonatomic, strong) NSMutableArray *items;

+ (int)count;
+ (int)readCount;

- (void)getItem:(int)index;
- (void)getItems;

@end
