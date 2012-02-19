//
//  NewPhotoDetailView.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 29.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthorizationView.h"
#import "New.h"
#import "MainMenu.h"

@interface NewPhotoDetailView : UIViewController <UIScrollViewDelegate>
{
    BOOL transitioning;
}
@property (nonatomic, strong) AuthorizationView *authorizationView;

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView1;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *imageView2;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *textLabel;
@property (unsafe_unretained, nonatomic) New *currentNew;
@property (nonatomic) int currentPhoto;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *containerView;
@property (strong, nonatomic) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (strong, nonatomic) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;

//-(void)didPassAuthorization:(NSNotification *)notification;

- (IBAction)onSwipeLeft:(UISwipeGestureRecognizer *)sender;
- (IBAction)onSwipeRight:(UISwipeGestureRecognizer *)sender;

- (void)performTransition:(NSString *)subtype;

@end
