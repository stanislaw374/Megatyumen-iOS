//
//  PhotoDownloader.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 29.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotoDownloader.h"

@interface PhotoDownloader()
@property (nonatomic, unsafe_unretained) id<PhotoDownloaderDelegate> delegate;
@end

@implementation PhotoDownloader
@synthesize delegate = _delegate;

-(id)initWithDelegate:(id<PhotoDownloaderDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

-(void)downloadPhoto:(NSString *)url {
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    UIImage *cachedImage = [manager imageWithURL:[NSURL URLWithString:url]];
    
    if (cachedImage)
    {
        [self.delegate photoDownloaderDidDownloadPhoto:cachedImage];
    }
    else
    {
        // Start an async download
        [manager downloadWithURL:[NSURL URLWithString:url] delegate:self];
    }
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error {
    [self.delegate photoDownloaderDidDownloadPhoto:[UIImage imageNamed:@"placeholder.png"]];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image {
    [self.delegate photoDownloaderDidDownloadPhoto:image];
}

@end
