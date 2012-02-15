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

static int kNumberOfPages = 0;

@interface AnnouncesView()
{
    BOOL pageControlUsed;
}
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) Announces *announces;
//@property (nonatomic, strong) AuthorizationView *authorizationView;
@property (nonatomic, strong) CheckinCatalogView *checkinView;
@property (nonatomic, strong) MainMenu *mainMenu;
- (void)didGetAnnounces:(NSNotification *)notification;
- (void)loadScrollViewWithPage:(int)page;
- (void)didAuthorize:(NSNotification *)notification;
@end

@implementation AnnouncesView
@synthesize pageControl;
@synthesize btnCheckin;
@synthesize scrollView;
@synthesize viewControllers = _viewControllers;
@synthesize hud = _hud;
@synthesize announces = _announces;
//@synthesize authorizationView = _authorizationView;
@synthesize checkinView = _checkinView;
@synthesize mainMenu = _mainMenu;

- (CheckinCatalogView *)checkinView {
    if (!_checkinView) {
        _checkinView = [[CheckinCatalogView alloc] init];
    }
    return _checkinView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Анонсы вечеринок";
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAuthorize:) name:kNOTIFICATION_DID_AUTHORIZE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetAnnounces:) name:kNOTIFICATION_DID_GET_ANNOUNCES object:nil];
    
    //[MainMenu addMainButtonForViewController:self];
    //[MainMenu addAuthorizeButtonForViewController:self];
    
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    //[self.mainMenu addBackButton];
    [self.mainMenu addMainButton];
    [self.mainMenu addAuthorizeButton];
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.announces = [[Announces alloc] init];
    [self.announces getItems];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_GET_ANNOUNCES object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_AUTHORIZE object:nil];
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

- (void)didAuthorize:(NSNotification *)notification {
    self.navigationItem.rightBarButtonItem = nil;
}

- (IBAction)onCheckinButtonClick {
    if (![Authorization sharedAuthorization].isAuthorized) {
        [Alerts showAlertViewWithTitle:@"Ошибка" message:@"Для того, чтобы отметиться, нужно авторизоваться"];
        return;
    }
    [self.navigationController pushViewController:self.checkinView animated:YES];
}

- (void)didGetAnnounces:(NSNotification *)notification {   
    kNumberOfPages = self.announces.items.count;
    
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
    
    [self.hud hide:YES];
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
        controller = [[AnnounceView alloc] initWithAnnounce:[self.announces.items objectAtIndex:page]];
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

@end
