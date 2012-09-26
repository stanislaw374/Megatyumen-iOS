//
//  AnnouncesView.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AnnounceView.h"
#import "Authorization.h"
#import "AuthorizationView.h"
#import "CheckinCatalogView.h"
#import "Alerts.h"
#import "Announces.h"
#import "Announce.h"
#import "UIImage+Thumbnail.h"
#import "UIButton+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+HTML.h"

@interface AnnounceView()
@property (nonatomic, strong) Announce *announce;
@property (nonatomic) BOOL isAnimating;
- (void)initUI;
- (void)maximizePage;
- (void)minimizePage;
- (void)turnPage;
- (void)maximizeText;
- (void)minimizeText;
@end

@implementation AnnounceView

@synthesize textWebView;
@synthesize imageView;
@synthesize scrollView;
@synthesize view1;
@synthesize view2;
@synthesize lblTitle;
@synthesize announce = _announce;
@synthesize isAnimating = _isAnimating;

- (id)initWithAnnounce:(Announce *)announce {
    if (self = [super init]) {
        self.announce = announce;
    }
    return self;
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
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [self setView1:nil];
    [self setView2:nil];
    [self setTextWebView:nil];
    [self setLblTitle:nil];
    [self setTextWebView:nil];
    [self setImageView:nil];
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



- (void)turnPage {
    UIView *fromView = self.view1.hidden ? self.view2 : self.view1;
    UIView *toView = self.view1.hidden ? self.view1 : self.view2;
    
    [UIView beginAnimations:@"PageTurn" context:nil];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:fromView cache:YES];
    [self.view bringSubviewToFront:fromView];
    fromView.hidden = YES;
    toView.hidden = NO;
    
    if (fromView == self.view2) self.isAnimating = NO;
    
    if (fromView == self.view1) {
        [UIView setAnimationDelegate:self];
        SEL stopSelector = @selector(maximizePage);
        [UIView setAnimationDidStopSelector:stopSelector];
    }
    [UIView commitAnimations];
}

- (void)maximizePage {
    [UIView beginAnimations:@"PageMaximization" context:nil];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    CGRect frame = self.view2.frame;
    frame.size.height = self.view.frame.size.height - 20;
    self.view2.frame = frame;
    
    //self.textWebView.frame = frame;
    
    //[self maximizeText];    
    
    self.isAnimating = NO;
    [UIView commitAnimations];
}




- (void)initUI { 
    self.scrollView.delegate = self;
    self.textWebView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(320, 540);
    self.textWebView.opaque = NO;
    self.textWebView.backgroundColor = [UIColor clearColor];

    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSLog(@"announce image: %@", self.announce.image.description);
    UIActivityIndicatorView *hud = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    hud.center = CGPointMake(self.imageView.frame.size.width / 2, self.imageView.frame.size.height / 2);
    [self.imageView addSubview:hud];
    [hud startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:self.announce.image];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self.btnImage setBackgroundImage:image forState:UIControlStateNormal];
            [self.imageView setImage:image];
            [hud stopAnimating];
            [hud removeFromSuperview];
        });
    });

    self.lblTitle.text = self.announce.title;
    //CGSize size = [self.txtTitle sizeThatFits:self.txtTitle.frame.size];
    //[self.lblTitle sizeToFit];
    //self.borderButton.frame = CGRectMake(self.borderButton.frame.origin.x, self.borderButton.frame.origin.y, size.width, size.height);
    NSString *text = self.announce.text;
    
    text = [text stringByStrippingHTML];
    
    NSLog(@"extracted html: %@", text);
    
    text = [[@"<html><body style=\"background-color:transparent; font-size: 16; font-family: Helvetica; color: black\">" stringByAppendingString:text] stringByAppendingString:@"</body></html>"];
    text = [text stringByReplacingOccurrencesOfString:@"Что:" withString:@"<span style=\"color:#FF9600;font-weight:bold\">Что:</span>"];
    text = [text stringByReplacingOccurrencesOfString:@"Где:" withString:@"<br/><span style=\"color:#FF9600;font-weight:bold\">Где:</span>"];
    text = [text stringByReplacingOccurrencesOfString:@"Когда:" withString:@"<br/><span style=\"color:#FF9600;font-weight:bold\">Когда:</span>"];
    [self.textWebView loadHTMLString:text baseURL:nil];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"%@", NSStringFromSelector(_cmd));    
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    else {
        
    }
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.textWebView sizeToFit];
    self.scrollView.contentSize = CGSizeMake(320, self.scrollView.contentSize.height + self.textWebView.frame.size.height - 50);
}

@end
