//
//  Items.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KEY_NEWS_COUNT @"news"
#define KEY_EVENTS_COUNT @"events"
#define KEY_FEEDBACKS_COUNT @"feedbacks"
#define KEY_ANNOUNCES_COUNT @"announces"

@interface Items : NSObject

+ (NSDictionary *)getCount;

@end
