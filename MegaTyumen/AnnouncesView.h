//
//  AnnouncesView.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 25.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainMenu.h"
#import "MBProgressHUD.h"

@interface AnnouncesView : UIViewController <UIScrollViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UIPageControl *pageControl;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnCheckin;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)onCheckinButtonClick;
- (IBAction)onPageTurn:(id)sender;

@end
