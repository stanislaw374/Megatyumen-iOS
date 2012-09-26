//
//  Authorization.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "ASIHTTPRequest.h"

#define kNOTIFICATION_DID_PASS_AUTHORIZATION @"megatyumen.didPassAuthorization"


@protocol AuthorizationDelegate;

@interface Authorization : NSObject <ASIHTTPRequestDelegate>

@property (nonatomic, readonly) BOOL isAuthorized;
@property (nonatomic, strong, readonly) NSString *token;


// Синглетон авторизации
+ (Authorization *)sharedAuthorization; 

// Авторизация
- (NSDictionary *)authorizeWithLogin:(NSString *)login andPassword:(NSString *)password;

// Регистрация
- (NSDictionary *)registerWithLogin:(NSString *)login Password:(NSString *)password andName:(NSString *)name;

// Пользовательское соглашение
- (NSString *)getUserAgreement;

// Восстановление пароля
- (NSDictionary *)restorePasswordWithEmail:(NSString *)email;

@end
