//
//  PhotoView.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 26.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotoView.h"
#import "UIImageView+WebCache.h"

@implementation PhotoView
@synthesize imageView;
@synthesize photoURL = _photoURL;

//- (id)initWithPhotoUrl:(NSURL *)url {
//    if (self = [super init]) {
//        self.photoUrl = url;
//    }
//    return self;
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    //[self.imageView setImageWithURL:self.photoURL];
    //NSLog(@"%@", self.photoURL.description);
    
    UIActivityIndicatorView *hud = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    hud.center = CGPointMake(self.imageView.frame.size.width / 2, self.imageView.frame.size.height / 2);
    [self.imageView addSubview:hud];
    [hud startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:self.photoURL];
        UIImage *image = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
            [hud stopAnimating];
            [hud removeFromSuperview];
        });
    });
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)zoomImage:(id)sender {
    UIPinchGestureRecognizer *gesture = (UIPinchGestureRecognizer *)sender;
    self.imageView.transform = CGAffineTransformScale(self.imageView.transform, gesture.scale, gesture.scale);
    
    NSLog(@"Scale = %f", gesture.scale);
    
    gesture.scale = 1;
}
@end
