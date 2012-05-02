//
//  Auxiliary.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Alerts : NSObject

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message;
+ (void)showAuthorizationAlertViewWithTitle:(NSString *)title message:(NSString *)message delegate:(id<UIAlertViewDelegate>)delegate;

@end
