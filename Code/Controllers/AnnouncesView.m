//
//  AnnouncesView.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 25.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AnnouncesView.h"
#import "Announces.h"
#import "AuthorizationView.h"
#import "CheckinCatalogView.h"
#import "Authorization.h"
#import "Alerts.h"
#import "AnnounceView.h"
#import "User.h"

static int kNumberOfPages = 0;

@interface AnnouncesView() <AnnounceDelegate>
{
    BOOL pageControlUsed;
}
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) NSArray *announces;
//@property (nonatomic, strong) CheckinCatalogView *checkinView;
@property (nonatomic, strong) MainMenu *mainMenu;
- (void)didGetAnnounces;
- (void)loadScrollViewWithPage:(int)page;
- (void)getAnnounces;
@end

@implementation AnnouncesView
@synthesize pageControl;
@synthesize btnCheckin;
@synthesize scrollView;
@synthesize viewControllers = _viewControllers;
@synthesize announces = _announces;
//@synthesize authorizationView = _authorizationView;
@synthesize mainMenu = _mainMenu;

//- (CheckinCatalogView *)checkinView {
//    if (!_checkinView) {
//        _checkinView = [[CheckinCatalogView alloc] init];
//    }
//    return _checkinView;
//}

- (NSArray *)announces {
    if (!_announces) {
        _announces = [NSArray array];
    }
    return _announces;
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

    self.title = @"Анонсы вечеринок";
    
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addMainButton];
    [self.mainMenu addAuthorizeButton];
    
    [self getAnnounces];
}

- (void)viewDidUnload
{
    [self setPageControl:nil];
    [self setBtnCheckin:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onCheckinButtonClick {
    if (![User sharedUser].token) {
        [Alerts showAlertViewWithTitle:@"Ошибка" message:@"Для того, чтобы отметиться, нужно авторизоваться"];
        return;
    }
    CheckinCatalogView *view = [[CheckinCatalogView alloc] init];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)didGetAnnounces {
    kNumberOfPages = self.announces.count;
    
    self.viewControllers = [[NSMutableArray alloc] init];
    for (int i = 0; i < kNumberOfPages; i++) {
        [self.viewControllers addObject:[NSNull null]];
    }
    
    // a page is the width of the scroll view
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height - 44);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    self.pageControl.numberOfPages = kNumberOfPages;
    self.pageControl.currentPage = 0;
    
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    //
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
        
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= kNumberOfPages)
        return;
    
    // replace the placeholder if necessary
    AnnounceView *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[AnnounceView alloc] initWithAnnounce:[self.announces objectAtIndex:page]];
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
    }
}

- (void)onMainButtonClick {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

- (IBAction)onPageTurn:(id)sender 
{
    int page = self.pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}

- (void)getAnnounces {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [Announce getWithDelegate:self];
    
//    dispatch_queue_t queue = dispatch_queue_create("Announces queue", NULL);
//    dispatch_async(queue, ^{
//        [self.announces getItems];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self didGetAnnounces];
//        });
//    });
//    
//    dispatch_release(queue);
}

#pragma mark - AnnounceDelegate
- (void)announcesDidLoad:(NSArray *)announces {
    self.announces = announces;
    [self didGetAnnounces];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)announcesDidFailWithError:(NSString *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
