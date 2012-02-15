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

//+ (void)addMainButtonForViewController:(UIViewController<MainMenuDelegate> *)viewController;
//+ (void)addBackButtonForViewController:(UIViewController<MainMenuDelegate> *)viewController;
//+ (void)addAuthorizeButtonForViewController:(UIViewController<MainMenuDelegate> *)viewController;
//+ (void)addHiddenBackButtonForViewController:(UIViewController<MainMenuDelegate> *)viewController;

@end

//
//@protocol MainMenuDelegate <NSObject>
//
//@optional
//- (void)onMainButtonClick;
//- (void)onBackButtonClick;
//- (void)onAuthorizeButtonClick;
//
//@end
