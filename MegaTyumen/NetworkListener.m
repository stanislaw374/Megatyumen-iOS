//
//  NetworkListener.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 03.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NetworkListener.h"
#import "Reachability.h"
//#import "Alerts.h"

@interface NetworkListener()
@property (nonatomic, strong) Reachability *networkReachability;
- (void)reachabilityChanged:(NSNotification *)notification;
@end

@implementation NetworkListener
@synthesize networkReachability = _networkReachability;
@synthesize isNetworkAvailable = _isNetworkAvailable;

- (id)init {
    if (self = [super init]) {
        // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
        // method "reachabilityChanged" will be called. 
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
        self.networkReachability = [Reachability reachabilityForInternetConnection];
        [self.networkReachability startNotifier];
        NSLog(@"reachability started notifier");
        
#warning O_O
        _isNetworkAvailable = YES;
    }
    return self;
}

- (void)reachabilityChanged:(NSNotification *)notification {
    Reachability *reachability = [notification object];
    NSParameterAssert([reachability isKindOfClass: [Reachability class]]);
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        _isNetworkAvailable = NO;
    }
    else {
        _isNetworkAvailable = YES;
    }
    
    NSLog(@"reachabilityChanged: %d", self.isNetworkAvailable);
}

- (void)dealloc {
    [self.networkReachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
