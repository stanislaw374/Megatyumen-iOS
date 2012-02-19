//
//  Network.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 19.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Network : NSObject

@property (nonatomic, readonly) BOOL isAvailable;

+ (Network *)sharedNetwork;

@end
