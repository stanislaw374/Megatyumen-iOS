//
//  AnnouncesView.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainMenu.h"
#import "Announce.h"

@interface AnnounceView : UIViewController <UIWebViewDelegate, UIScrollViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UIView *view1;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *view2;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblTitle;
@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *textWebView;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;


- (id)initWithAnnounce:(Announce *)announce;
- (IBAction)onImageClick;

@end
