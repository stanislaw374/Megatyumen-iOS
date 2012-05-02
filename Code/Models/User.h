//
//  User.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 20.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNOTIFICATION_USER_DID_LOGIN @"megatyumen.userDidLogin"

@protocol UserDelegate <NSObject>
@optional
- (void)userDidLoginWithMesssage:(NSString *)message;
- (void)userLoginDidFailWithError:(NSString *)error;

- (void)userDidSignUpWithMessage:(NSString *)message;
- (void)userSignUpDidFailWithError:(NSString *)error;

- (void)userDidLoadUserAgreementWithMessage:(NSString *)message;
- (void)userAgreementDidFailWithError:(NSString *)error;

- (void)userDidRestorePasswordWithMessage:(NSString *)message;
- (void)userRestorePasswordDidFailWithError:(NSString *)error;
@end

@interface User : NSObject
@property (nonatomic, unsafe_unretained) id <UserDelegate> delegate;

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *token;

+ (User *)sharedUser;

- (void)login;
- (void)signUp;
- (void)getUserAgreement;
- (void)restorePassword;

- (void)saveUser;
- (void)loadUser;
@end
