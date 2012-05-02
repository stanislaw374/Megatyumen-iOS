//
//  PhotoView.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 26.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotosView.h"
#import "PhotoView.h"
#import "AuthorizationView.h"

@interface PhotosView()
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) MainMenu *mainMenu;
- (void)loadScrollViewWithPage:(int)page;
@end

@implementation PhotosView
@synthesize scrollView;
@synthesize lblPage;
@synthesize currentPhoto = _currentPhoto;
@synthesize viewControllers = _viewControllers;
@synthesize photosURLs = _photosURLs;
@synthesize mainMenu = _mainMenu;

- (void)setCurrentPhoto:(int)currentPhoto {
    _currentPhoto = currentPhoto;
    self.lblPage.text = [NSString stringWithFormat:@"%d / %d", self.currentPhoto + 1, self.photosURLs.count];
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:self.currentPhoto - 1];
    [self loadScrollViewWithPage:self.currentPhoto];
    [self loadScrollViewWithPage:self.currentPhoto + 1];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

//- (id)initWithPhotosUrls:(NSArray *)photosUrls {
//    if (self = [super init]) {
//        self.photosUrls = photosUrls;
//        self.numberOfPages = self.photosUrls.count;
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
    self.title = @"Просмотр фото";
    
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addBackButton];
    [self.mainMenu addMainButton];
    [self.mainMenu addAuthorizeButton];
    
    self.viewControllers = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.self.photosURLs.count; i++) {
        [self.viewControllers addObject:[NSNull null]];
    }
    
    // a page is the width of the scroll view
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.photosURLs.count, scrollView.frame.size.height - 49);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    //
    
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width * self.currentPhoto, 0);
    
    [self loadScrollViewWithPage:self.currentPhoto - 1];
    [self loadScrollViewWithPage:self.currentPhoto];
    [self loadScrollViewWithPage:self.currentPhoto + 1];
    
    self.lblPage.text = [NSString stringWithFormat:@"%d / %d", self.currentPhoto + 1, self.photosURLs.count];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setLblPage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= self.photosURLs.count)
        return;
    
    // replace the placeholder if necessary
    PhotoView *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[PhotoView alloc] init];
        controller.photoURL = [self.photosURLs objectAtIndex:page];
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil) //
    {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    self.currentPhoto = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//    return ((PhotoView *)[self.viewControllers objectAtIndex:self.page]).imageView;
//}

@end
