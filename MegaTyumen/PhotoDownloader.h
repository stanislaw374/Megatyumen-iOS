//
//  PhotoDownloader.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 29.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebImageManager.h"
#import "SDWebImageManagerDelegate.h"

@protocol PhotoDownloaderDelegate;

@interface PhotoDownloader : NSObject <SDWebImageManagerDelegate>

- (id)initWithDelegate:(id<PhotoDownloaderDelegate>)delegate;
- (void)downloadPhoto:(NSString *)url;

@end

@protocol PhotoDownloaderDelegate <NSObject>

- (void)photoDownloaderDidDownloadPhoto:(UIImage *)image;

@end