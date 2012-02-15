//
//  SCAppUtils.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 28.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kSCNavBarImageTag 6183746
#define kSCNavBarColor [UIColor colorWithRed:216.0/255 green:6.0/255 blue:27.0/255 alpha:1]

@interface SCAppUtils : NSObject

+ (void)customizeNavigationController:(UINavigationController *)navController;

@end
