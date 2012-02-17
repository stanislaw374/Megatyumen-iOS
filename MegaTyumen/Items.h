//
//  Items.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Items : NSObject

@property (nonatomic) int newsCount;
@property (nonatomic) int feedbackCount;
@property (nonatomic) int eventsCount;
@property (nonatomic) int announcesCount;

- (void)getCount;

@end
