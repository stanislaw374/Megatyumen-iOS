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
@synthesize view1;
@synthesize view2;
@synthesize lblWhat;
@synthesize lblWhere;
@synthesize lblWhen;
@synthesize btnImage;
@synthesize lblDescription;
//@synthesize tvWhat;
//@synthesize tvWhere;
//@synthesize tvWhen;
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
//    [self setTvWhat:nil];
//    [self setTvWhere:nil];
//    [self setTvWhen:nil];
    [self setLblTitleWhat:nil];
    [self setLblTitleWhere:nil];
    [self setLblTitleWhen:nil];
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
    
    [self maximizeText];    
    
    self.isAnimating = NO;
    [UIView commitAnimations];
}

- (void)maximizeText {
    int offset = 20; 
    //int spacing = 8;
    
    //int height = self.view.frame.size.height - 2 * offset;
    //height -= self.lblTitleWhat.frame.size.height;
    
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
    
    [self minimizeText];
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(turnPage)];
    [UIView commitAnimations];
}

- (void)initUI {
    //UIImage *image = [self.announce.image thumbnailByScalingProportionallyAndCroppingToSize:CGSizeMake(300, 157)];
    //[self.btnImage setImage:image forState:UIControlStateNormal];
    [self.btnImage setImageWithURL:self.announce.imageUrl];
    //self.lblWhat.text = [NSString stringWithFormat:@"%@", self.announce.what];
    //self.lblWhere.text = [NSString stringWithFormat:@"%@", self.announce.where];
    //self.lblWhen.text = [NSString stringWithFormat:@"%@", self.announce.when];
    self.lblWhat.text = self.announce.what;
    self.lblWhere.text = self.announce.where;
    self.lblWhen.text = self.announce.when;
    self.lblDescription.text = self.announce.description;
//    [self.lblWhat sizeToFit];
//    [self.lblWhere sizeToFit];
//    [self.lblWhen sizeToFit];
    [self.lblDescription sizeToFit];
}

@end