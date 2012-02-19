//
//  Items.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KEY_NEWS_COUNT @"news_count"
#define KEY_COMMENTS_COUNT @"comments_count"
#define KEY_EVENTS_COUNT @"events_count"
#define KEY_ANNOUNCES_COUNT @"announces_count"

@interface Items : NSObject

+ (NSDictionary *)getCount;

@end
