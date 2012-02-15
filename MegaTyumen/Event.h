//
//  EventItem.h
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebImageDownloader.h"

@interface Event : NSObject <SDWebImageDownloaderDelegate>

//@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageUrl;
@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *date;

@end