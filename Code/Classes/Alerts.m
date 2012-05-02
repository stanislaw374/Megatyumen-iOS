//
//  Auxiliary.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Alerts.h"

@implementation Alerts

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message;
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

+ (void)showAuthorizationAlertViewWithTitle:(NSString *)title message:(NSString *)message delegate:(id<UIAlertViewDelegate>)delegate
{    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:@"Авторизация", nil];
    [alert show];
}

@end
