//
//  FeedbackItem.h
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Feedback : NSObject

//@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageUrl;
@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSString *to;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic) int attitude;

@end
