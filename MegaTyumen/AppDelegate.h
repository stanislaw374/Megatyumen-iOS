//
//  AppDelegate.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 17.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Facebook *facebook;
@property (strong, nonatomic) Reachability *reachability;

@end
