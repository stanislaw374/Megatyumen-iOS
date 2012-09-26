//
//  MainView.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 18.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainMenu.h"
#import "CustomBadge.h"
@interface MainView : UIViewController <UIAlertViewDelegate>

@property(unsafe_unretained,nonatomic) BOOL *seenFeedbacks;
@property(unsafe_unretained,nonatomic) BOOL *seenNews;
@property(unsafe_unretained,nonatomic) BOOL *seenAnnounces;
@property(unsafe_unretained,nonatomic) BOOL *seenCompaniesNews;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *newsButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *feedbackButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *announcesButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *eventsButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *checkinButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *checkinLabel;
@property (unsafe_unretained,nonatomic) CustomBadge *newsBadge;
@property (unsafe_unretained,nonatomic) CustomBadge *feedbackBadge;
@property (unsafe_unretained,nonatomic) CustomBadge *announceBadge;
@property (unsafe_unretained,nonatomic) CustomBadge *eventsBadge;
- (IBAction)showCatalog;
- (IBAction)showNews;
- (IBAction)showMap;
- (IBAction)showFeedbacks;
- (IBAction)showAnnounces;
- (IBAction)showEvents;

- (IBAction)onCheckinButtonClick;
- (IBAction)onCatalogButtonClick;
- (IBAction)onMapButtonClick;
- (IBAction)onFeedbackButtonClick;
- (IBAction)onAnnouncesButtonClick;
- (IBAction)onEventsButtonClick;



@end
