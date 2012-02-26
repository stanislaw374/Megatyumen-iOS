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
@synthesize lblTitleWhat;
@synthesize lblTitleWhere;
@synthesize lblTitleWhen;
@synthesize txtTitle;
@synthesize borderButton;
@synthesize textWebView;
@synthesize btnImage2;
@synthesize view1;
@synthesize view2;
@synthesize lblWhat;
@synthesize lblWhere;
@synthesize lblWhen;
@synthesize btnImage;
@synthesize lblDescription;
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
    [self setLblWhat:nil];
    [self setLblWhere:nil];
    [self setLblWhen:nil];
    [self setBtnImage:nil];
    [self setLblDescription:nil];
    [self setLblTitleWhat:nil];
    [self setLblTitleWhere:nil];
    [self setLblTitleWhen:nil];
    [self setTxtTitle:nil];
    [self setBorderButton:nil];
    [self setTextWebView:nil];
    [self setBtnImage2:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onImageClick {
    NSLog(@"click");
    
    if (self.isAnimating) return;
    
    self.isAnimating = YES;
    
    UIView *fromView = self.view1.hidden ? self.view2 : self.view1;
    
    if (fromView == self.view2) {
        [self minimizePage];
    }
    else {
        [self turnPage];
    }
    
    //self.isAnimating = NO;
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

- (void)maximizeText {
    int offset = 20; 
    
    CGRect frame = self.lblWhat.frame;
    frame.origin.x = offset;
    frame.origin.y = self.lblTitleWhat.frame.origin.y + self.lblTitleWhat.frame.size.height;
    frame.size.width = self.view2.frame.size.width - 2 * offset;
    CGSize size = [self.lblWhat sizeThatFits:self.lblWhat.frame.size];
    frame.size.height = size.height;
    self.lblWhat.frame = frame;
    
    //[self.lblWhat sizeToFit];
    //height -= self.lblWhat.frame.size.height;

    frame = self.lblTitleWhere.frame;
    frame.origin.y = self.lblWhat.frame.origin.y + self.lblWhat.frame.size.height;
    self.lblTitleWhere.frame = frame;
    //height -= self.lblTitleWhere.frame.size.height - self.lblTitleWhen.frame.size.height;
    
    frame = self.lblWhere.frame;
    frame.origin.x = offset;
    frame.origin.y = self.lblTitleWhere.frame.origin.y + self.lblTitleWhere.frame.size.height;
    frame.size.width = self.view2.frame.size.width - 40;
    size = [self.lblWhere sizeThatFits:self.lblWhere.frame.size];
    frame.size.height = size.height;
    //frame.size.height = height / 2;
    self.lblWhere.frame = frame;
    //[self.lblWhere sizeToFit];
    //height -= self.lblWhere.frame.size.height;
    
    frame = self.lblTitleWhen.frame;
    frame.origin.y = self.lblWhere.frame.origin.y + self.lblWhere.frame.size.height;
    self.lblTitleWhen.frame = frame;
    
    frame = self.lblWhen.frame;
    frame.origin.x = offset;
    frame.origin.y = self.lblTitleWhen.frame.origin.y + self.lblTitleWhen.frame.size.height;
    frame.size.width = self.view2.frame.size.width - 40;
    size = [self.lblWhen sizeThatFits:self.lblWhen.frame.size];
    frame.size.height = size.height;
    //frame.size.height = height;
    self.lblWhen.frame = frame;
    //[self.lblWhen sizeToFit];
}

- (void)minimizeText {
    int space = 8;
    
    CGRect frame = self.lblWhat.frame;
    frame.origin.x = self.lblTitleWhat.frame.origin.x + self.lblTitleWhat.frame.size.width + space;
    frame.origin.y = self.lblTitleWhat.frame.origin.y;
    frame.size.width = self.view2.frame.size.width - self.lblTitleWhat.frame.size.width;
    frame.size.height = self.lblTitleWhat.frame.size.height;
    self.lblWhat.frame = frame;
    
    frame = self.lblTitleWhere.frame;
    frame.origin.y = self.lblTitleWhat.frame.origin.y + self.lblTitleWhat.frame.size.height + 25;
    self.lblTitleWhere.frame = frame;
    
    frame = self.lblWhere.frame;
    frame.origin.x = self.lblTitleWhere.frame.origin.x + self.lblTitleWhere.frame.size.width + space;
    frame.origin.y = self.lblTitleWhere.frame.origin.y;
    frame.size.width = self.view2.frame.size.width - self.lblTitleWhere.frame.size.width;
    frame.size.height = self.lblTitleWhere.frame.size.height;
    self.lblWhere.frame = frame;
    
    frame = self.lblTitleWhen.frame;
    frame.origin.y = self.lblTitleWhere.frame.origin.y + self.lblTitleWhere.frame.size.height + 25;
    self.lblTitleWhen.frame = frame;
    
    frame = self.lblWhen.frame;
    frame.origin.x = self.lblTitleWhen.frame.origin.x + self.lblTitleWhen.frame.size.width + space;
    frame.origin.y = self.lblTitleWhen.frame.origin.y;
    frame.size.width = self.view2.frame.size.width - self.lblTitleWhen.frame.size.width;
    frame.size.height = self.lblTitleWhen.frame.size.height;
    self.lblWhen.frame = frame;
}

- (void)minimizePage {
    [UIView beginAnimations:@"PageMinimization" context:nil];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    CGRect frame = self.view2.frame;
    frame.size.height = self.view1.frame.size.height;
    self.view2.frame = frame;
    
    //self.textWebView.frame = frame;
    
    //[self minimizeText];
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(turnPage)];
    [UIView commitAnimations];
}

- (void)initUI {    
    [self.btnImage setImageWithURL:self.announce.image];
    self.txtTitle.text = self.announce.title;
    //CGSize size = [self.txtTitle sizeThatFits:self.txtTitle.frame.size];
    [self.txtTitle sizeToFit];
    //self.borderButton.frame = CGRectMake(self.borderButton.frame.origin.x, self.borderButton.frame.origin.y, size.width, size.height);
    
    NSString *text = [[@"<html><body style=\"background-color: black; font-size: 16; font-family: Helvetica; color: #FFFFFF\">" stringByAppendingString:self.announce.text] stringByAppendingString:@"</body></html>"];
    text = [text stringByReplacingOccurrencesOfString:@"Что:" withString:@"<span style=\"color:#FF9600\">Что:</span>"];
    text = [text stringByReplacingOccurrencesOfString:@"Где:" withString:@"<span style=\"color:#FF9600\">Где:</span>"];
    text = [text stringByReplacingOccurrencesOfString:@"Когда:" withString:@"<span style=\"color:#FF9600\">Когда:</span>"];
    //self.textView.text = [self.announce.text stringByStrippingHTML];
    [self.textWebView loadHTMLString:text baseURL:nil];
}

@end
