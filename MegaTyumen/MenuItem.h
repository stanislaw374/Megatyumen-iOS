//
//  MenuItem.h
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebImageDownloader.h"

@interface MenuItem : NSObject <SDWebImageDownloaderDelegate>

@property (nonatomic, strong) NSString *title;
@property (nonatomic) float price;
@property (nonatomic, strong) NSURL *image;

@end


