//
//  Authorization.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Authorization.h"
#import "Config.h"
#import "Alerts.h"
#import "SBJson.h"
#import "ASIFormDataRequest.h"

#define KEY_JSON_DATA @"jsonData"
#define KEY_REQUEST @"request"
#define VALUE_AUTHORIZATION @"login"
#define VALUE_REGISTRATION @"sign_up"
#define VALUE_RESTORE_PASSWORD @"restore_password"
#define VALUE_USER_AGGREEMENT @"user_agreement"
#define KEY_PASSWORD @"password"
#define KEY_NAME @"name"
#define KEY_TOKEN @"token"
#define KEY_ERROR @"error"
#define KEY_EMAIL @"email"
#define KEY_MESSAGE @"message"

static Authorization *authorization;

@interface Authorization()
@end

@implementation Authorization
@synthesize isAuthorized = _isAuthorized;
@synthesize token = _token;

+ (Authorization *)sharedAuthorization {
    if (!authorization) {
        authorization = [[Authorization alloc] init];
    }
    return authorization;
}

- (NSDictionary *)authorizeWithLogin:(NSString *)login andPassword:(NSString *)password {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:VALUE_AUTHORIZATION, KEY_REQUEST, login, KEY_EMAIL, password, KEY_PASSWORD, nil];
    NSLog(@"Авторизация: %@", dict.description);   
    
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:dict] forKey:KEY_JSON_DATA];
    request.delegate = self;
    request.didFinishSelector = @selector(didAuthorize:);
    [request startSynchronous];
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict2 = [jsonParser objectWithString:[request responseString]];
    
    NSLog(@"Авторизация(ответ): %@", dict2.description); 
    
    BOOL result = [[dict2 objectForKey:KEY_RESPONSE] boolValue];
    if (result) {
        _isAuthorized = YES;
        _token = [dict2 objectForKey:@"UserToken"];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:_token forKey:KEY_TOKEN];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:result], KEY_RESPONSE, nil];
    }
    else {
        NSString *error = @"Неверное имя пользователя или пароль";
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:result], KEY_RESPONSE, error, KEY_ERROR, nil];
    }
}



- (NSDictionary *)registerWithLogin:(NSString *)login Password:(NSString *)password andName:(NSString *)name {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:VALUE_REGISTRATION, KEY_REQUEST, login, KEY_EMAIL, password, KEY_PASSWORD, name, KEY_NAME, nil];
    
    NSLog(@"Регистрация %@", dict.description);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    [request setPostValue:[jsonWriter stringWithObject:dict] forKey:KEY_JSON_DATA];
    request.delegate = self;
    request.didFinishSelector = @selector(didRegister:);
    [request startSynchronous];
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict2 = [jsonParser objectWithString:[request responseString]];
    
    NSLog(@"Регистрация (ответ): %@", dict2.description);

    BOOL result = [[dict2 objectForKey:KEY_RESPONSE] boolValue];
    if (result) {
        _token = [dict2 objectForKey:KEY_TOKEN];
        _isAuthorized = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];
    }
    
    return dict2;
}


- (NSString *)getUserAgreement {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:VALUE_USER_AGGREEMENT, KEY_REQUEST, nil];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    [request setPostValue:[jsonWriter stringWithObject:dict] forKey:KEY_JSON_DATA];
    //request.delegate = self;
    //request.didFinishSelector = @selector(didGetUserAgreement:);
    [request startSynchronous];
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict2 = [jsonParser objectWithString:[request responseString]];
    return [dict2 objectForKey:KEY_RESPONSE];
}



- (NSDictionary *)restorePasswordWithEmail:(NSString *)email {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:VALUE_RESTORE_PASSWORD, KEY_REQUEST, email, KEY_EMAIL, nil];
    
    NSLog(@"Восстановление пароля: %@", dict.description);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    [request setPostValue:[jsonWriter stringWithObject:dict] forKey:KEY_JSON_DATA];
    request.delegate = self;
    request.didFinishSelector = @selector(didRestorePassword:);
    [request startSynchronous];
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict2 = [jsonParser objectWithString:[request responseString]];
    
    NSLog(@"Восстановление пароля (ответ): %@", dict.description);
    
    return dict2;
}


@end
