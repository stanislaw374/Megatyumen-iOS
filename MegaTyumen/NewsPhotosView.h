//
//  NewsPhotosView.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 26.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AuthorizationView.h"
#import "New.h"
#import "NewPhotoDetailView.h"
#import "MBProgressHUD.h"
#import "MainMenu.h"

@interface NewsPhotosView : UIViewController
{
    int loadingPhoto;
}
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *headerLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (unsafe_unretained, nonatomic) New *currentNew;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *borderButton;
@property (nonatomic) BOOL isLoaded;

@end
