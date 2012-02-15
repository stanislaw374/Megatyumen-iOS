//
//  main.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 17.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SCClassUtils.h"

int main(int argc, char *argv[]) {
        
    @autoreleasepool {
        
        // Магия
        [SCClassUtils swizzleSelector:@selector(insertSubview:atIndex:)
                              ofClass:[UINavigationBar class]
                         withSelector:@selector(scInsertSubview:atIndex:)];
        [SCClassUtils swizzleSelector:@selector(sendSubviewToBack:)
                              ofClass:[UINavigationBar class]
                         withSelector:@selector(scSendSubviewToBack:)];
        
// 
//        if (SYSTEM_VERSION_LESS_THAN(@"5")) {
//            /* Начало магии */
//            
//            // Get our drawRectCustom method
//            Method drawRectCustom = class_getInstanceMethod([UINavigationBar class], @selector(drawRectCustom:));
//            
//            // Get the original drawRect method
//            Method drawRect = class_getInstanceMethod([UINavigationBar class], @selector(drawRect:));
//            
//            // Swap the methods, drawRect now becomes drawRectCustom and vice-versa
//            method_exchangeImplementations(drawRect, drawRectCustom);
//            
//            // Конец магии
//        }

        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
