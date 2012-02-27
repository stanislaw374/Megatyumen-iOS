//
//  NewsPhotosView.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 26.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NewsPhotosView.h"
#import "Authorization.h"
#import "UIImage+Thumbnail.h"
#import "Constants.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"

@interface NewsPhotosView()
@property (strong, nonatomic) UILabel *photosCountLabel;
@property (strong, nonatomic) NewPhotoDetailView *photoDetailView;
@property (nonatomic) int currentPhoto;
@property (nonatomic, strong) UIView *photosView;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (nonatomic, strong) MainMenu *mainMenu;
- (void)initUI;
- (void)onPhotoClick:(id)sender;
@end

@implementation NewsPhotosView
@synthesize thumbImageView;
@synthesize headerLabel;
@synthesize scrollView;
@synthesize currentNew = _currentNew;
@synthesize photosCountLabel = _photosCountLabel;
@synthesize photoDetailView = _photoDetailView;
@synthesize currentPhoto = _currentPhoto;
@synthesize photosView = _photosView;
@synthesize borderButton = _borderButton;
//@synthesize isLoaded = _isLoaded;
@synthesize hud = _hud;
@synthesize mainMenu = _mainMenu;
@synthesize isLoaded = _isLoaded;

- (NewPhotoDetailView *)photoDetailView {
    if (!_photoDetailView) {
        _photoDetailView = [[NewPhotoDetailView alloc] init];
    }
    return _photoDetailView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Фотографии";
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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.isLoaded) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.currentNew getImages];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self initUI];
                [self.hud hide:YES];
            });
        });
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPassAuthorization:) name:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetPhotos:) name:kNOTIFICATION_DID_GET_PHOTOS object:nil];
    
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addBackButton];
    [self.mainMenu addMainButton];
    [self.mainMenu addAuthorizeButton];
}

- (void)viewDidUnload
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_GET_PHOTOS object:nil];
    [self setThumbImageView:nil];
    [self setHeaderLabel:nil];
    [self setScrollView:nil];
    [self setPhotosCountLabel:nil];
    [self setBorderButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//-(void)didPassAuthorization:(NSNotification *)notification {
//    self.navigationItem.rightBarButtonItem = nil;
//}

//-(void)didGetPhotos:(NSNotification *)notification {
////    int number = [[notification.userInfo objectForKey:@"number"] intValue];
////    UIButton *btn = (UIButton *)[self.photosView viewWithTag:number +1];
////    if (number < self.currentNew.photos.count) {
////        UIImage *img = [[self.currentNew.photos objectAtIndex:number] thumbnailByScalingProportionallyAndCroppingToSize:CGSizeMake(64, 64)];
////        btn.enabled = YES;
////        [btn setImage:img forState:UIControlStateNormal];
////    }
////    
////    if (++loadingPhoto == 3) {
////        [self.hud hide:YES];
////    }
//    [self initUI];
//    [self.hud hide:YES];
//    self.isLoaded = YES;
//    //NSLog(@"Did get photos O_O");
//}

-(void)onPhotoClick:(id)sender {
    self.currentPhoto = ((UIButton *)sender).tag - 1;
    
    self.photoDetailView.currentNew = self.currentNew;
    self.photoDetailView.currentPhoto = self.currentPhoto;
    [self.navigationController pushViewController:self.photoDetailView animated:YES];
}

-(void)initUI {    
    [self.thumbImageView setImageWithURL:self.currentNew.image placeholderImage:kPLACEHOLDER_IMAGE andScaleTo:CGSizeMake(81, 81)];
    self.headerLabel.text = self.currentNew.title;
    
    int height = 0;
    
    if (!self.photosCountLabel) {
        self.photosCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 + 8, 10, 300, 0)];
        self.photosCountLabel.backgroundColor = [UIColor clearColor];
        self.photosCountLabel.font = [UIFont systemFontOfSize:16];
        self.photosCountLabel.numberOfLines = 1;
        [self.scrollView addSubview:self.photosCountLabel];
    }
    self.photosCountLabel.text = [NSString stringWithFormat:@"%d фотографий", self.currentNew.images.count];
    [self.photosCountLabel sizeToFit];
    height += self.photosCountLabel.frame.origin.y + self.photosCountLabel.frame.size.height;
    
    if (self.photosView) {
        for (UIView *view in self.photosView.subviews) {
            [view removeFromSuperview];
        }
    }
    else {
        self.photosView = [[UIView alloc] initWithFrame:CGRectMake(12, self.photosCountLabel.frame.origin.y + self.photosCountLabel.frame.size.height + 10, 300, 0)];
        [self.scrollView addSubview:self.photosView];
    }
    
    int row = 0, column = 0;
    for (int i = 0; i < self.currentNew.images.count; i++) {        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(column * 72 + 8, row * 72 + 8, 64, 64);
        button.tag = i + 1;
        [button addTarget:self action:@selector(onPhotoClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setImageWithURL:[self.currentNew.images objectAtIndex:i] placeholderImage:kPLACEHOLDER_IMAGE andScaleTo:CGSizeMake(64, 64)];
        
//        UIImage *image;
////        if (i < self.currentNew.thumbnails.count) {
////            //image = [self.currentNew.thumbnails objectAtIndex:i];
////            [button setImage:image forState:UIControlStateNormal];
////        }
//        if (!image) button.enabled = NO;
        [self.photosView addSubview:button];
        
        if (column == 3) {
            row++;
            column = 0;
            height += 72;
        }
        else {
            column++;
        }
    }
    if (1) height += 72;
    height += 16;
    CGRect rect = self.photosView.frame;
    rect.size.height = (row + 2) * 72;
    self.photosView.frame = rect;
    
    self.borderButton.frame = CGRectMake(self.borderButton.frame.origin.x, self.borderButton.frame.origin.y, self.borderButton.frame.size.width, height + 16);
    self.scrollView.contentSize = CGSizeMake(300, height + 60);    
    
    // Отправка запроса загрузки фотографий
//    if (!self.currentNew.photos.count) {
//        loadingPhoto = 0;
//        
//        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        
//        [self.currentNew getPhotos];
//    }
}

@end
