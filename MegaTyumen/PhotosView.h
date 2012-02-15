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

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblPage;
@property (nonatomic) int page;

- (id)initWithPhotosUrls:(NSArray *)photosUrls;

@end
