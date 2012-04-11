//
//  NewDetailView.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 27.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NewDetailView.h"
#import "Authorization.h"
#import "UIImage+Thumbnail.h"
#import "Comment.h"
#import "UIImageView+WebCache.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "MainMenu.h"

@interface NewDetailView()
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UIImageView *photoImageView;
@property (strong, nonatomic) UIButton *photosButton;
@property (strong, nonatomic) UILabel *photosCountLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UILabel *authorLabel;
@property (strong, nonatomic) UIButton *commentsHeaderButton;
@property (strong, nonatomic) UILabel *commentsCountLabel;
@property (strong, nonatomic) UIButton *goToCommentsButton;
@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) UIImageView *shareButtonsHeader;
@property (strong, nonatomic) UIButton *facebookButton;
@property (strong, nonatomic) UIButton *vkButton;
@property (strong, nonatomic) UIImageView *commentMark;
@property (strong, nonatomic) UILabel *commentsCountLabel2;
@property (strong, nonatomic) UIView *commentsView;
@property (strong, nonatomic) AddCommentView *addCommentView;
@property (strong, nonatomic) UIWebView *textWebView;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) NewsPhotosView *newsPhotosView;
@property (strong, nonatomic) MainMenu *mainMenu;
- (void)createUI;
- (void)initUI;
- (void)postToFacebook;
@end

@implementation NewDetailView
@synthesize scrollView = _scrollView;
@synthesize photosCountLabel = _photosCountLabel;
@synthesize headerLabel = _headerLabel;
@synthesize photoImageView = _photoImageView;
@synthesize dateLabel = _dateLabel;
@synthesize authorLabel = _authorLabel;
@synthesize commentsCountLabel = _commentsCountLabel;
@synthesize commentsCountLabel2 = _commentsCountLabel2;
@synthesize shareButtonsHeader = _shareButtonsHeader;
@synthesize facebookButton = _facebookButton;
@synthesize commentMark = _commentMark;
@synthesize currentNew = _currentNew;
@synthesize photosButton = _photosButton;
@synthesize borderButton = _borderButton;
@synthesize commentsHeaderButton = _commentsHeaderImageView;
@synthesize goToCommentsButton = _goToCommentsButton;
@synthesize textLabel = _text;
@synthesize commentsView = _commentsView;
@synthesize newsPhotosView = _newsPhotosView;
@synthesize vkButton = _vkButton;
@synthesize addCommentView = _addCommentView;
@synthesize textWebView = _textWebView;
@synthesize hud = _hud;
@synthesize mainMenu = _mainMenu;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Просмотр новости";
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
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPassAuthorization:) name:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetNewDetails:) name:kNOTIFICATION_DID_GET_NEW_DETAILS object:nil];
    
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addBackButton];
    [self.mainMenu addMainButton];
    [self.mainMenu addAuthorizeButton];
    
    [self createUI];
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    delegate.facebook = [[Facebook alloc] initWithAppId:kFB_APP_ID andDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initUI];
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.currentNew getContent];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initUI];
            [self.hud hide:YES];
        });
    });
}

- (void)viewDidUnload
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_GET_NEW_DETAILS object:nil];
    [self setScrollView:nil];
    [self setPhotosCountLabel:nil];
    [self setHeaderLabel:nil];
    [self setPhotoImageView:nil];
    [self setDateLabel:nil];
    [self setAuthorLabel:nil];
    [self setCommentsCountLabel:nil];
    [self setCommentsCountLabel2:nil];
    [self setShareButtonsHeader:nil];
    [self setFacebookButton:nil];
    [self setCommentMark:nil];
    [self setPhotosButton:nil];
    [self setBorderButton:nil];
    [self setCommentsHeaderButton:nil];
    [self setGoToCommentsButton:nil];
    [self setTextLabel:nil];
    [self setCommentsView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)createUI {    
    self.headerLabel = [[UILabel alloc] init];
    self.headerLabel.backgroundColor = [UIColor clearColor];
    self.headerLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.headerLabel.numberOfLines = 0;
    self.headerLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.scrollView addSubview:self.headerLabel];
    //self.headerLabel = nil;
    
    self.photoImageView = [[UIImageView alloc] init];
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:self.photoImageView];
    //self.photoImageView = nil;
    
    self.photosButton = [[UIButton alloc] init];
    [self.photosButton setImage: [UIImage imageNamed:@"photosButton.png"] forState:UIControlStateNormal];
    [self.photosButton addTarget:self action:@selector(onPhotosButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.photosButton];
    //self.photosButton = nil;
    
    self.photosCountLabel = [[UILabel alloc] init];
    self.photosCountLabel.backgroundColor = [UIColor clearColor];
    self.photosCountLabel.adjustsFontSizeToFitWidth = YES;
    self.photosCountLabel.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.photosCountLabel];
    //self.photosCountLabel = nil;
    
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.backgroundColor = [UIColor clearColor];
    self.dateLabel.textColor = [UIColor colorWithRed:108.0/255 green:108.0/255 blue:108.0/255 alpha:1];
    self.dateLabel.font = [UIFont systemFontOfSize:14];
    self.dateLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.dateLabel.numberOfLines = 1;
    [self.scrollView addSubview:self.dateLabel];
    //self.dateLabel = nil;
    
    self.authorLabel = [[UILabel alloc] init];
    self.authorLabel.backgroundColor = [UIColor clearColor];
    self.authorLabel.textColor = [UIColor colorWithRed:0/255 green:144.0/255 blue:219.0/255 alpha:1];
    self.authorLabel.font = [UIFont systemFontOfSize:14];
    self.authorLabel.lineBreakMode = UILineBreakModeTailTruncation;
    self.authorLabel.numberOfLines = 1;
    [self.scrollView addSubview:self.authorLabel];
    //self.authorLabel = nil;
    
    self.commentsHeaderButton = [[UIButton alloc] init];
    [self.commentsHeaderButton addTarget:self action:@selector(onScrollToCommentsButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.commentsHeaderButton setImage:[UIImage imageNamed:@"commentsHeader.png"] forState:UIControlStateNormal];
    [self.scrollView addSubview:self.commentsHeaderButton];
    //self.commentsHeaderButton = nil;
    
    self.commentsCountLabel = [[UILabel alloc] init];
    self.commentsCountLabel.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.commentsCountLabel];
    //self.commentsCountLabel = nil;
    
    self.goToCommentsButton = [[UIButton alloc] init];
    [self.goToCommentsButton setImage:[UIImage imageNamed:@"commentsButton.png"] forState:UIControlStateNormal];
    [self.goToCommentsButton addTarget:self action:@selector(onScrollToCommentsButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.goToCommentsButton];
    //self.goToCommentsButton = nil;
    
    //self.textLabel = [[UILabel alloc] init];
    //self.textLabel.backgroundColor = [UIColor clearColor];
    //self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    //self.textLabel.numberOfLines = 0;
    //[self.scrollView addSubview:self.textLabel];    
    
    self.shareButtonsHeader = [[UIImageView alloc] init];
    [self.scrollView addSubview:self.shareButtonsHeader];
    //self.shareButtonsHeader = nil;
    
    self.facebookButton = [[UIButton alloc] init];
    [self.facebookButton setImage:[UIImage imageNamed:@"facebookButton.png"] forState:UIControlStateNormal];
    [self.facebookButton addTarget:self action:@selector(onFacebookButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.facebookButton];
    //self.facebookButton = nil;
    
    self.vkButton = [[UIButton alloc] init];
    [self.vkButton setImage:[UIImage imageNamed:@"vkButton.png"] forState:UIControlStateNormal];
    [self.scrollView addSubview:self.vkButton];
    //self.vkButton = nil;
    
    self.commentMark = [[UIImageView alloc] init];
    [self.scrollView addSubview:self.commentMark];
    //self.commentMark = nil;
    
    self.commentsCountLabel2 = [[UILabel alloc] init];
    self.commentsCountLabel2.backgroundColor = [UIColor clearColor];
    self.commentsCountLabel2.adjustsFontSizeToFitWidth = YES;
    [self.scrollView addSubview:self.commentsCountLabel2];
    //self.commentsCountLabel2 = nil;
}

-(void)initUI {
    
    int dx = 20;
    int dy = 64;
    int dd = 8;
    int height = 0;
    
    self.headerLabel.frame = CGRectMake(dx + 8, dy + 8, 280 - 8, 0);
    self.headerLabel.text = self.currentNew.title;
    [self.headerLabel sizeToFit];
    height += dy + self.headerLabel.frame.size.height;
    
    self.photoImageView.frame = CGRectMake(dx, self.headerLabel.frame.origin.y + self.headerLabel.frame.size.height + dd, 183, 104);
    [self.photoImageView setImageWithURL:self.currentNew.image placeholderImage:kPLACEHOLDER_IMAGE andScaleTo:CGSizeMake(183, 104)];
    //[self.currentNew.photo thumbnailOfSize:CGSizeMake(183, 104)];
    height += dd + self.photoImageView.frame.size.height;
    
    self.photosButton.frame = CGRectMake(self.photoImageView.frame.origin.x + self.photoImageView.frame.size.width + 17, self.photoImageView.frame.origin.y + 15, 75, 75);
    
    self.photosCountLabel.text = [NSString stringWithFormat:@"%d фото", self.currentNew.images.count];
    self.photosCountLabel.frame = CGRectMake(self.photosButton.frame.origin.x + 17, self.photosButton.frame.origin.y + 38, 42, 21);
    
    self.dateLabel.frame = CGRectMake(dx, self.photoImageView.frame.origin.y + self.photoImageView.frame.size.height + dd, 0, 0);
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd MMMM HH:mm"];
    self.dateLabel.text = [df stringFromDate:self.currentNew.date];
    [self.dateLabel sizeToFit];
    height += dd + self.dateLabel.frame.size.height;
    
    self.authorLabel.frame = CGRectMake(self.dateLabel.frame.origin.x + self.dateLabel.frame.size.width + dd, self.photoImageView.frame.origin.y + self.photoImageView.frame.size.height + dd, 280 - self.dateLabel.frame.size.width - dd, 0);
    self.authorLabel.text = self.currentNew.user;
    NSLog(@"user = %@", self.currentNew.user);
    [self.authorLabel sizeToFit];
    
    self.commentsHeaderButton.frame = CGRectMake(dx / 2, self.dateLabel.frame.origin.y + self.dateLabel.frame.size.height + dd, 300, 38);
    height += dd + self.commentsHeaderButton.frame.size.height + 6;
    
    self.commentsCountLabel.text = [NSString stringWithFormat:@"%d комментариев", self.currentNew.comments.count];
    self.commentsCountLabel.frame = CGRectMake(dx / 2 + 44, self.commentsHeaderButton.frame.origin.y + self.commentsHeaderButton.frame.size.height / 6, 0, 0);
    [self.commentsCountLabel sizeToFit];
    
    self.goToCommentsButton.frame = CGRectMake(self.commentsHeaderButton.frame.size.width - 26 - 5, self.commentsHeaderButton.frame.origin.y + 5, 26, 26);
        
    //self.textLabel.frame = CGRectMake(dx, self.commentsHeaderImageView.frame.origin.y + self.commentsHeaderImageView.frame.size.height + dd, 280, 0);
    //self.textLabel.text = self.currentNew.text;
    //[self.textLabel sizeToFit];
    //height += dd + self.textLabel.frame.size.height;
    
    if (self.textWebView) {
        [self.textWebView removeFromSuperview];
        [self setTextWebView:nil];
    }
    self.textWebView = [[UIWebView alloc] init];
    self.textWebView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.textWebView];
    self.textWebView.frame = CGRectMake(dx, self.commentsHeaderButton.frame.origin.y + self.commentsHeaderButton.frame.size.height + dd, 280, 0);
    [self.textWebView loadHTMLString:self.currentNew.text baseURL:nil];
    self.textWebView.delegate = self;
    
    self.borderButton.frame = CGRectMake(self.borderButton.frame.origin.x, self.borderButton.frame.origin.y, self.borderButton.frame.size.width, height - 6 * dd);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, height + 3 *dd);
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    int dx = 20;
    //int dy = 64;
    int dd = 8;
    int height = 0;
    
    int webHeight = [[self.textWebView stringByEvaluatingJavaScriptFromString:@"document.height"] intValue];
    self.textWebView.frame = CGRectMake(self.textWebView.frame.origin.x, self.textWebView.frame.origin.y, self.textWebView.frame.size.width, webHeight);
    height += webHeight;
    
    self.shareButtonsHeader.frame = CGRectMake(dx / 2, self.textWebView.frame.origin.y + self.textWebView.frame.size.height + dd, 300, 47);
    self.shareButtonsHeader.image = [UIImage imageNamed:@"shareButtonsHeader.png"];
    height += dd + self.shareButtonsHeader.frame.size.height;
    
    self.facebookButton.frame = CGRectMake(self.shareButtonsHeader.frame.origin.x + 5, self.shareButtonsHeader.frame.origin.y + 5, 94, 36);
    //self.facebookButton.hidden = YES;
    
    self.vkButton.frame = CGRectMake(self.facebookButton.frame.origin.x + self.facebookButton.frame.size.width + 5, self.shareButtonsHeader.frame.origin.y + 5, 94, 36);
    self.vkButton.hidden = YES;
    
    self.commentMark.frame = CGRectMake(dx, self.shareButtonsHeader.frame.origin.y + self.shareButtonsHeader.frame.size.height + 2 * dd, 19, 18);
    self.commentMark.image = [UIImage imageNamed:@"commentMark.png"];
    height += 2 * dd + self.commentMark.frame.size.height;
    
    self.commentsCountLabel2.frame = CGRectMake(self.commentMark.frame.origin.x + self.commentMark.frame.size.width + dd, self.commentMark.frame.origin.y - 1, 250, 18);
    self.commentsCountLabel2.text = [NSString stringWithFormat:@"КОММЕНТАРИИ (%d)", self.currentNew.comments.count];
    
    // Добавление комментариев %(
    if (self.commentsView) { 
        [self.commentsView removeFromSuperview]; 
        [self setCommentsView:nil];
    }
    self.commentsView = [[UIView alloc] initWithFrame:CGRectMake(dx, self.commentMark.frame.origin.y + self.commentMark.frame.size.height + dd, 280, 0)];
    int lastCommentHeight = 0;
    for (int i = 0; i < self.currentNew.comments.count; i++) {
        Comment *comment = [self.currentNew.comments objectAtIndex:i];
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, lastCommentHeight, 0, 0)];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textColor = [UIColor colorWithRed:0/255 green:144.0/255 blue:219.0/255 alpha:1];
        lbl.font = [UIFont systemFontOfSize:14];
        lbl.lineBreakMode = UILineBreakModeWordWrap;
        lbl.numberOfLines = 1;
        lbl.text = [NSString stringWithFormat:@"%@,", comment.user];
        [lbl sizeToFit];
        [self.commentsView addSubview:lbl];
        
        UILabel *lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(lbl.frame.origin.x + lbl.frame.size.width + dd, lastCommentHeight + dd, 280 - lbl.frame.size.width, 0)];
        lbl2.backgroundColor = [UIColor clearColor];
        lbl2.font = [UIFont systemFontOfSize:14];
        lbl2.textColor = [UIColor colorWithRed:108.0/255 green:108.0/255 blue:108.0/255 alpha:1];
        lbl2.lineBreakMode = UILineBreakModeTailTruncation;
        lbl2.numberOfLines = 1;
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"dd MMMM HH:mm"];
        lbl2.text = [df stringFromDate:comment.date];
        [lbl2 sizeToFit];
        [self.commentsView addSubview:lbl2];
        
        UILabel *lbl3 = [[UILabel alloc] initWithFrame:CGRectMake(0, lbl.frame.origin.y + lbl.frame.size.height + dd / 2, 280, 0)];
        lbl3.backgroundColor = [UIColor clearColor];
        lbl3.font = [UIFont systemFontOfSize:14];
        lbl3.lineBreakMode = UILineBreakModeWordWrap;
        lbl3.numberOfLines = 0;
        lbl3.text = comment.text;
        [lbl3 sizeToFit];
        [self.commentsView addSubview:lbl3];
        
        int commentHeight = lbl.frame.size.height + lbl2.frame.size.height + lbl3.frame.size.height + 1.5f * dd;
        lastCommentHeight += commentHeight;
        height += commentHeight;
    }
    [self.commentsView sizeToFit];
    [self.scrollView addSubview:self.commentsView];
    //----------------------
    
    self.borderButton.frame = CGRectMake(self.borderButton.frame.origin.x, self.borderButton.frame.origin.y, self.borderButton.frame.size.width, self.borderButton.frame.size.height + height + 8);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.contentSize.height + height + 8);
}

//-(void)didGetNewDetails:(NSNotification *)notification {
//    [self initUI];
//    [self.hud hide:YES];
//}

//-(void)didPassAuthorization:(NSNotification *)notification {
//    self.navigationItem.rightBarButtonItem = nil;
//}

- (IBAction)onPhotosButtonClick {
    if (!self.currentNew.images.count) return;
    if (!self.newsPhotosView) {
        self.newsPhotosView = [[NewsPhotosView alloc] init];
    }
    self.newsPhotosView.currentNew = self.currentNew;
    self.newsPhotosView.isLoaded = NO;
    [self.navigationController pushViewController:self.newsPhotosView animated:YES];
}

#pragma mark - Facebook share button

- (IBAction)onFacebookButtonClick {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        delegate.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        delegate.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    if (![delegate.facebook isSessionValid]) {
        NSArray *permissions = [[NSArray alloc] initWithObjects:@"publish_stream", nil];
        [delegate.facebook authorize:permissions];
    }
    else {
        [self postToFacebook];
    }
}

- (void)fbDidLogin {
    //NSLog(@"Залогинился в facebooke!");
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[delegate.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[delegate.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [self postToFacebook];
}

- (void)postToFacebook {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   kFB_APP_ID, @"app_id",
                                   self.currentNew.link, @"link",
                                   self.currentNew.image.absoluteString, @"picture",
                                   self.currentNew.title, @"name",
                                   @"megatyumen.ru", @"caption",
                                   self.currentNew.title, @"description",
                                   //self.currentNew.text, @"message",
                                   nil];
    
    NSLog(@"%@: %@", NSStringFromSelector(_cmd), params.description);
    
    [delegate.facebook dialog:@"feed" andParams:params andDelegate:self];
}

#pragma mark VK Button

-(void)onVKButtonClick {
    
}

-(void)onAddCommentButtonClick {
    if (!self.addCommentView) {
        self.addCommentView = [[AddCommentView alloc] init];
    }
    self.addCommentView.currentNew = self.currentNew;
    [self.navigationController pushViewController:self.addCommentView animated:YES];
}

- (IBAction)onScrollToCommentsButtonClick {
    [self.scrollView scrollRectToVisible:self.commentMark.frame animated:YES];
}


@end
