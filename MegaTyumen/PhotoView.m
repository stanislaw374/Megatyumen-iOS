//
//  PhotoView.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 26.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotoView.h"
#import "UIImageView+WebCache.h"

@interface PhotoView()
@property (nonatomic, unsafe_unretained) NSURL *photoUrl;
@end

@implementation PhotoView
@synthesize imageView;
@synthesize photoUrl = _photoUrl;

- (id)initWithPhotoUrl:(NSURL *)url {
    if (self = [super init]) {
        self.photoUrl = url;
    }
    return self;
}

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
    
    [self.imageView setImageWithURL:self.photoUrl];
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

@end
