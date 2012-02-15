//
//  PartyAnnounce.h
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Announce : NSObject

@property (nonatomic, strong) NSString *description;
//@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageUrl;
@property (nonatomic, strong) NSString *what;
@property (nonatomic, strong) NSString *where;
@property (nonatomic, strong) NSString *when;
@property (nonatomic) int comments;

@end
