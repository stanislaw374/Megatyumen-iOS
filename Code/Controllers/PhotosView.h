//
//  PhotoView.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 26.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainMenu.h"

@interface PhotosView : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *photosURLs;
@property (nonatomic) int currentPhoto;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblPage;

@end
