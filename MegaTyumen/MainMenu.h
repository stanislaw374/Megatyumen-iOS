//
//  MainMenu.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 25.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainMenu : NSObject

- (id)initWithViewController:(UIViewController *)viewController;

- (void)addMainButton;
- (void)addBackButton;
- (void)addAuthorizeButton;
- (void)addHiddenBackButton;

- (void)onMainButtonClick;
- (void)onBackButtonClick;
- (void)onAuthorizeButtonClick;

- (void)didPassAuthorization:(NSNotification *)notification;

@end
