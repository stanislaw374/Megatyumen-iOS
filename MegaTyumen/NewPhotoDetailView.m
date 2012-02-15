//
//  NewPhotoDetailView.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 29.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NewPhotoDetailView.h"
#import "Authorization.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"

@interface NewPhotoDetailView()
@property (nonatomic, strong) MainMenu *mainMenu;
@end

@implementation NewPhotoDetailView
@synthesize imageView1;
@synthesize imageView2;
@synthesize textLabel;
@synthesize currentNew = _currentNew;
@synthesize authorizationView = _authorizationView;
@synthesize currentPhoto = _currentPhoto;
@synthesize containerView;
@synthesize leftSwipeGestureRecognizer;
@synthesize rightSwipeGestureRecognizer;
@synthesize mainMenu = _mainMenu;

-(void)didPassAuthorization:(NSNotification *)notification {
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)performTransition:(NSString *)subtype
{
	// First create a CATransition object to describe the transition
	CATransition *transition = [CATransition animation];
	// Animate over 3/4 of a second
	transition.duration = 0.2;
	// using the ease in/out timing function
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	// Now to set the type of transition. Since we need to choose at random, we'll setup a couple of arrays to help us.
	//NSString *types[4] = {kCATransitionMoveIn, kCATransitionPush, kCATransitionReveal, kCATransitionFade};
	//NSString *subtypes[4] = {kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom};

	transition.type = kCATransitionMoveIn;
    transition.subtype = subtype;
	
	// Finally, to avoid overlapping transitions we assign ourselves as the delegate for the animation and wait for the
	// -animationDidStop:finished: message. When it comes in, we will flag that we are no longer transitioning.
	transitioning = YES;
	transition.delegate = self;
	
	// Next add it to the containerView's layer. This will perform the transition based on how we change its contents.
	[containerView.layer addAnimation:transition forKey:nil];
	
	// Here we hide view1, and show view2, which will cause Core Animation to animate view1 away and view2 in.
	self.imageView1.hidden = YES;
	self.imageView2.hidden = NO;
	
	// And so that we will continue to swap between our two images, we swap the instance variables referencing them.
	UIImageView *tmp = self.imageView2;
	self.imageView2 = self.imageView1;
	self.imageView1 = tmp;
}

-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	transitioning = NO;
}

- (IBAction)onSwipeLeft:(id)sender {
    if (transitioning) return;
    NSLog(@"Swipe left");
    if (self.currentPhoto < self.currentNew.photosCount - 1) {
        self.currentPhoto++;
        [self.imageView2 setImageWithURL:[self.currentNew.photoURLs objectAtIndex:self.currentPhoto]];
        self.textLabel.text = [NSString stringWithFormat:@"%d / %d", self.currentPhoto +1, self.currentNew.photosCount];
        [self performTransition:kCATransitionFromRight];
    }
}

- (IBAction)onSwipeRight:(id)sender {
    if (transitioning) return;
    if (self.currentPhoto > 0) {
        self.currentPhoto--;
        [self.imageView2 setImageWithURL:[self.currentNew.photoURLs objectAtIndex:self.currentPhoto]];
        self.textLabel.text = [NSString stringWithFormat:@"%d / %d", self.currentPhoto +1, self.currentNew.photosCount];
        [self performTransition:kCATransitionFromLeft];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Просмотр фото";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPassAuthorization:) name:@"didPassAuthorization" object:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.mainMenu = [[MainMenu alloc]  initWithViewController:self];
    [self.mainMenu addBackButton];
    [self.mainMenu addMainButton];
    [self.mainMenu addAuthorizeButton];
    
    self.leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft:)];
    self.leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    self.rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight:)];
    self.rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.imageView1 setGestureRecognizers:[NSArray arrayWithObjects:self.leftSwipeGestureRecognizer, self.rightSwipeGestureRecognizer, nil]];
    [self.imageView2 setGestureRecognizers:[NSArray arrayWithObjects:self.leftSwipeGestureRecognizer, self.rightSwipeGestureRecognizer, nil]];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.imageView1 setImageWithURL:[self.currentNew.photoURLs objectAtIndex:self.currentPhoto]];
    self.textLabel.text = [NSString stringWithFormat:@"%d / %d", self.currentPhoto +1, self.currentNew.photosCount];
    transitioning = NO;
    //self.containerView.contentSize = self.imageView1.bounds.size;
    self.containerView.maximumZoomScale = 10;
    self.containerView.bouncesZoom = YES;
}

- (void)viewDidUnload
{
    [self setTextLabel:nil];
    [self setImageView1:nil];
    [self setImageView2:nil];
    [self setContainerView:nil];
    [self setLeftSwipeGestureRecognizer:nil];
    [self setRightSwipeGestureRecognizer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView1.hidden ? imageView2 : imageView1;
}

@end
