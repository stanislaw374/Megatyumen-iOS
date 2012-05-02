//
//  UIImage+Thumbnail.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 29.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Thumbnail.h"

@implementation UIImage (Thumbnail)

- (UIImage *) thumbnailOfSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    // draw scaled image into thumbnail context
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();      
    // pop the context
    UIGraphicsEndImageContext();
    if(newThumbnail == nil) 
        NSLog(@"could not scale image");
    return newThumbnail;
}

- (UIImage *)thumbnailByScalingProportionallyAndCroppingToSize:(CGSize)size {
    return [self getSubImageFrom:[self thumbnailByScalingProportionallyToSize:size] WithRect:CGRectMake(0, 0, size.width, size.height)];
}

- (UIImage *)thumbnailByScalingProportionallyToSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) 
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    return newImage;
}

- (UIImage*) getSubImageFrom:(UIImage*)img WithRect:(CGRect)rect {
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translated rectangle for drawing sub image 
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, img.size.width, img.size.height);
    
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // draw image
    [img drawInRect:drawRect];
    
    // grab image
    UIImage* subImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return subImage;
}

//- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
//{
//    //create a context to do our clipping in
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef currentContext = UIGraphicsGetCurrentContext();
//    
//    //create a rect with the size we want to crop the image to
//    //the X and Y here are zero so we start at the beginning of our
//    //newly created context
//    CGRect clippedRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
//    CGContextClipToRect( currentContext, clippedRect);
//    
//    //create a rect equivalent to the full size of the image
//    //offset the rect by the X and Y we want to start the crop
//    //from in order to cut off anything before them
//    CGRect drawRect = CGRectMake(rect.origin.x * -1,
//                                 rect.origin.y * -1,
//                                 imageToCrop.size.width,
//                                 imageToCrop.size.height);
//    
//    //draw the image to our clipped context using our offset rect
//    CGContextDrawImage(currentContext, drawRect, imageToCrop.CGImage);
//    
//    //pull the image from our cropped context
//    UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
//    
//    //pop the context to get back to the default
//    UIGraphicsEndImageContext();
//    
//    //Note: this is autoreleased
//    return cropped;
//}

@end
