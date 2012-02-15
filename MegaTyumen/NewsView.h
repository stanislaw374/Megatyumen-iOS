//
//  NewsView.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainMenu.h"

@class News, AuthorizationView, NewDetailView;

@interface NewsView : UITableViewController 

@property (strong, nonatomic) IBOutlet UITableViewCell *loadingCell;


@end