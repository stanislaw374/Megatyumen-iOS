//
//  NSString+HTML.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 26.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+HTML.h"

@implementation NSString (HTML)

- (NSString *) stringByStrippingHTML {
    NSRange r;
    NSString *s = [self copy]; 
    while ((r = [s rangeOfString:@"<[^a>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s; 
}

@end
