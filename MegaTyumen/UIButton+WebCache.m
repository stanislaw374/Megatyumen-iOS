/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIButton+WebCache.h"
#import "SDWebImageManager.h"
#import "UIImage+Thumbnail.h"

static BOOL scale;
static CGSize scaleSize;

@implementation UIButton (WebCache)

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    scale = NO;
    SDWebImageManager *manager = [SDWebImageManager sharedManager];

    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];

    [self setImage:placeholder forState:UIControlStateNormal];

    if (url)
    {
        [manager downloadWithURL:url delegate:self];
    }
}

- (void)cancelCurrentImageLoad
{
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    if (scale) {
        [self setImage:[image thumbnailByScalingProportionallyAndCroppingToSize:scaleSize] forState:UIControlStateNormal]; 
    }
    else [self setImage:image forState:UIControlStateNormal];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder andScaleTo:(CGSize)size {
    [self setImageWithURL:url placeholderImage:placeholder];
    scale = YES;
    scaleSize = size;
}

@end
