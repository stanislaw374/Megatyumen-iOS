//
//  PhotoView.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 26.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoView : UIViewController

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;

- (id)initWithPhotoUrl:(NSURL *)url;

@end
