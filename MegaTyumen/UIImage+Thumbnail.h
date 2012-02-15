//
//  UIImage+Thumbnail.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 29.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Thumbnail)

- (UIImage *)thumbnailOfSize:(CGSize)size;
- (UIImage *)thumbnailByScalingProportionallyAndCroppingToSize:(CGSize)size;
- (UIImage *)thumbnailByScalingProportionallyToSize:(CGSize)targetSize;
//- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect;
- (UIImage*)getSubImageFrom:(UIImage*)img WithRect:(CGRect)rect;
    
@end
