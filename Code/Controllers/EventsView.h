//
//  EventsView.h
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainMenu.h"

@interface EventsView : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnCheckin;

- (IBAction)onCheckinButtonClick;

@end
