//
//  NewDetailView.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 27.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "New.h"
#import "NewsPhotosView.h"
#import "AddCommentView.h"
#import "FBConnect.h"
#import "MBProgressHUD.h"
#import "MainMenu.h"

@interface NewDetailView : UIViewController <UIWebViewDelegate, FBSessionDelegate, FBDialogDelegate>

@property (unsafe_unretained, nonatomic) New *currentNew;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *borderButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;

- (void)didPassAuthorization:(NSNotification *)notification;
- (IBAction)onPhotosButtonClick;
- (IBAction)onFacebookButtonClick;
- (void)onVKButtonClick;
- (IBAction)onScrollToCommentsButtonClick;

- (void)didGetNewDetails:(NSNotification *)notification;
- (IBAction)onAddCommentButtonClick;

@end
