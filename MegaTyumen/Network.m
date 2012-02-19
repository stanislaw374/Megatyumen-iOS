//
//  Network.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 19.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Network.h"
#import "AppDelegate.h"

static Network *network;

@implementation Network
@synthesize isAvailable = _isAvailable;

+ (Network *)sharedNetwork {
    if (!network) {
        network = [[Network alloc] init];
    }
    return network;
}

- (BOOL)isAvailable {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NetworkStatus status = delegate.reachability.currentReachabilityStatus;
    return status != NotReachable;
}

@end
