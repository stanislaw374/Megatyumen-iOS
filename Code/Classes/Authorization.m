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
//- (void)didAuthorize:(ASIHTTPRequest *)request;
//- (void)didRegister:(ASIHTTPRequest *)request;
//- (void)didGetUserAgreement:(ASIHTTPRequest *)request;
//- (void)didRestorePassword:(ASIHTTPRequest *)request;
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
        _token = [dict2 objectForKey:KEY_TOKEN];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:result], KEY_RESPONSE, nil];
    }
    else {
        NSString *error = @"Неверное имя пользователя или пароль";
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:result], KEY_RESPONSE, error, KEY_ERROR, nil];
    }
}

//- (void)didAuthorize:(ASIHTTPRequest *)request {
//    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//    NSDictionary *dict = [jsonParser objectWithString:[request responseString]];
//    
//    NSLog(@"Авторизация(ответ): %@", dict.description); 
//    
//    _result = [[dict objectForKey:KEY_RESPONSE] boolValue];
//    if (_result) {
//        _isAuthorized = YES;
//        _token = [dict objectForKey:KEY_TOKEN];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];
//    }
//    else {
//        _error = @"Неверное имя пользователя или пароль";
//    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_AUTHORIZE object:self];
//}

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

//- (void)didRegister:(ASIHTTPRequest *)request {
//    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//    NSDictionary *dict = [jsonParser objectWithString:[request responseString]];
//    
//    NSLog(@"Регистрация (ответ): %@", dict.description);
//    
////    _result = [[dict objectForKey:KEY_RESPONSE] boolValue];
////    if (!_result) {
////        _error = [dict objectForKey:KEY_ERROR];
////    }
////    else {
////        _isAuthorized = YES;
////        _token = [dict objectForKey:KEY_TOKEN];
//////        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_PASS_AUTHORIZATION object:self];
////    }
////    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_REGISTER object:self];
////    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_AUTHORIZE object:self];
//}

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

//- (void)didGetUserAgreement:(ASIHTTPRequest *)request {
//    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//    NSDictionary *dict = [jsonParser objectWithString:[request responseString]];
//    
//    NSLog(@"Текст пользовательского соглашения: %@", dict.description);
//    
//    _result = YES;
//    _userAgreement = [dict objectForKey:KEY_RESPONSE];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_USER_AGREEMENT object:self];
//}

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

//- (void)didRestorePassword:(ASIHTTPRequest *)request {
//    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//    NSDictionary *dict = [jsonParser objectWithString:[request responseString]];
//    
//    NSLog(@"Восстановление пароля (ответ): %@", dict.description);
//          
////    _result = [[dict objectForKey:KEY_RESPONSE] boolValue];
////    if (!_result) {
////        _error = [dict objectForKey:KEY_ERROR];
////    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_RESTORE_PASSWORD object:self];
//}

//- (void)addDelegate:(id<AuthorizationDelegate>)delegate {
//    [self.delegates addObject:delegate];
//}
//
//- (void)removeDelegate:(id<AuthorizationDelegate>)delegate {
//    [self.delegates removeObject:delegate];
//}

//--------СТАРОЕ---------------------------------------------------------------------

// Отправка асинхронного запроса
//+(void)sendRequest:(NSDictionary *)requestDictionary withDelegate:(id<NSURLConnectionDataDelegate>)delegate {
//    NSData *json = [jsonWriter dataWithObject:requestDictionary];
//    
//    NSMutableData *requestData = [NSMutableData dataWithData:[@"jsonData=" dataUsingEncoding:NSUTF8StringEncoding]]; 
//    [requestData appendData:json];
//    
//    // Отправка асинхронного запроса 
//    NSURL *url = [NSURL URLWithString:[Constants api]];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request setHTTPMethod:@"POST"];
//    [request setHTTPBody:requestData];
//    
//    // Получение ответа
//    [NSURLConnection connectionWithRequest:request delegate:delegate];
//}
//
//+(NSData *)sendSynchronousRequest:(NSDictionary *)requestDictionary {
//    NSError *error;
//    NSData *json = [jsonWriter dataWithObject:requestDictionary];
//    
//    
//    //NSString *str = [jsonWriter stringWithObject:requestDictionary];
//    //NSLog(@"Отправил: %@", str);
//    
//    
//    NSMutableData *requestData = [NSMutableData dataWithData:[@"jsonData=" dataUsingEncoding:NSUTF8StringEncoding]]; 
//    [requestData appendData:json];
//    
//    // Отправка синхронного запроса 
//    NSURL *url = [NSURL URLWithString:[Constants api]];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request setHTTPMethod:@"POST"];
//    [request setHTTPBody:requestData];
//    
//    // Получение ответа
//    NSURLResponse *response;
//    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    if (error) { NSLog(@"Error: %@", error.localizedDescription); } 
//    return responseData;
//}
//
//+(BOOL)sendAuthorizationRequest:(NSDictionary *)requestDictionary {
//    NSData *responseData = [Authorization sendSynchronousRequest:requestDictionary];
//    if (!responseData) {
//        [Auxiliary showAlertViewWithTitle:@"Ошибка" message:@"Ошибка соединения"];
//        return NO;
//    }
//    
//    // Разбор результата
//    //NSError *error;
//    NSDictionary *responseDictionary = [jsonParser objectWithData:responseData];
//    int result = [[responseDictionary objectForKey:@"response"] intValue];
//    if (result) {
//        IsAuthorized = YES;
//        Token = (NSString *)[responseDictionary objectForKey:@"token"];
//        NSLog(@"Получил токен: %@", Token);
//        [Auxiliary showAlertViewWithTitle:@"" message:@"Успешно авторизовался"];
//        return YES;
//    }
//    else {
//        [Auxiliary showAlertViewWithTitle:@"Ошибка" message:@"Неверное имя пользователя или пароль"];
//        return NO;
//    }
//}
//
//+(BOOL)sendRegistrationRequest:(NSDictionary *)requestDictionary {
//    NSData *responseData = [Authorization sendSynchronousRequest:requestDictionary];
//    if (!responseData) {
//        [Auxiliary showAlertViewWithTitle:@"Ошибка" message:@"Ошибка соединения"];
//        return NO;
//    }
//    
//    // Разбор результата
//    NSDictionary *responseDictionary = [jsonParser objectWithData:responseData];
//    int result = [[responseDictionary objectForKey:@"response"] intValue];
//    if (result) {        
//        [Auxiliary showAlertViewWithTitle:@"" message:@"Успешная регистрация"];
//        //IsAuthorized = YES;
//        //Token = (NSString *)[responseDictionary objectForKey:@"token"];
//        return YES;
//    }
//    else {
//        NSString *errorMessage = (NSString *)[responseDictionary objectForKey:@"error"];
//        [Auxiliary showAlertViewWithTitle:@"Ошибка" message:errorMessage];
//        return NO;
//    }
//}
//
//+(void)sendUserAgreementRequest:(NSDictionary *)requestDictionary withDelegate:(id<NSURLConnectionDataDelegate>)delegate {
//    [Authorization sendRequest:requestDictionary withDelegate:delegate];
//    //NSData *responseData = [Authorization sendSynchronousRequest:requestDictionary];
////    if (!responseData) {
////        [Auxiliary showAlertViewWithTitle:@"Ошибка" message:@"Ошибка соединения"];
////        return @"";
////    }
//    
//    // Разбор результата
//    //NSError *error;
////    NSDictionary *responseDictionary = [jsonParser objectWithData:responseData];
////    NSString *result = (NSString *)[responseDictionary objectForKey:@"response"];
////    //NSString *str = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
////    //return str;
////    return result;
//}
//
//+(BOOL)sendRestorePasswordRequest:(NSDictionary *)requestDictionary {
//    NSData *responseData = [Authorization sendSynchronousRequest:requestDictionary];
//    if (!responseData) {
//        [Auxiliary showAlertViewWithTitle:@"Ошибка" message:@"Ошибка соединения"];
//        return NO;
//    }
//    
//    // Разбор результата
//    //NSError *error;
//    NSDictionary *responseDictionary = [jsonParser objectWithData:responseData];
//    int result = [[responseDictionary objectForKey:@"response"] intValue];
//    if (result) {        
//        [Auxiliary showAlertViewWithTitle:@"" message:@"Новый пароль был выслан на ваш e-mail"];
//        return YES;
//    }
//    else {
//        NSString *errorMessage = (NSString *)[responseDictionary objectForKey:@"error"];
//        [Auxiliary showAlertViewWithTitle:@"Ошибка" message:errorMessage];
//        return NO;
//    }
//}

@end
