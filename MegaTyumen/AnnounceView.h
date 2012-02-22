//
//  AnnouncesView.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainMenu.h"
#import "Announce.h"

@interface AnnounceView : UIViewController

@property (unsafe_unretained, nonatomic) IBOutlet UIView *view1;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *view2;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblWhat;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblWhere;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblWhen;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnImage;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblDescription;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblTitleWhat;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblTitleWhere;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *lblTitleWhen;

@property (unsafe_unretained, nonatomic) IBOutlet UITextView *txtTitle;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *borderButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *textWebView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnImage2;

- (id)initWithAnnounce:(Announce *)announce;
- (IBAction)onImageClick;

@end
