//
//  User.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 20.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import "ASIFormDataRequest.h"
#import "Config.h"
#import "SBJson.h"

static User *_user;

@implementation User
@synthesize lastVisit = _lastVisit;
@synthesize email = _email;
@synthesize password = _password;
@synthesize name = _name;
@synthesize token = _token;
@synthesize isSave = _isSave;
@synthesize delegate = _delegate;

+ (User *)sharedUser {
    if (!_user) {
        _user = [[User alloc] init];
        [_user loadUser];
    }
    return _user;
}

- (void)login {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token =[userDefaults objectForKey:@"userToken"];
    if (token != nil && token != @"")
    {
        [self.delegate userDidLoginWithMesssage:@"Message"];
    }
    else {
        NSString *params = [[NSString stringWithFormat:@"?request=login&email=%@&password=%@", self.email, self.password] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
        
        __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        
        [request setCompletionBlock:^{
            //NSLog(@"%@, %@", NSStringFromSelector(_cmd), request.responseString);
            NSDictionary *responseDict = [request.responseString JSONValue];
            BOOL response = [[responseDict objectForKey:@"response"] boolValue];
            if (response) {
                self.token = [responseDict objectForKey:@"token"];
                self.lastVisit = [NSDate date];
                [self saveUser];
                [self.delegate userDidLoginWithMesssage:[responseDict objectForKey:@"message"]];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_USER_DID_LOGIN object:nil];
            }
            else {
                [self.delegate userLoginDidFailWithError:[responseDict objectForKey:@"error"]];
            }
        }];
        
        [request setFailedBlock:^{
            [self.delegate userLoginDidFailWithError:request.error.localizedDescription];                                                
        }];
        
        [request startAsynchronous]; 
    }
    
}

- (void)signUp {    
    NSString *params = [[NSString stringWithFormat:@"?request=sign_up&email=%@&password=%@&name=%@", self.email, self.password, self.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];

    [request setCompletionBlock:^{
        NSDictionary *dict = [request.responseString JSONValue];
        BOOL response = [[dict objectForKey:@"response"] boolValue];
        if (response) {
            self.token = [dict objectForKey:@"token"];
            [self saveUser];
            [self.delegate userDidSignUpWithMessage:[dict objectForKey:@"message"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_USER_DID_LOGIN object:nil];
        }
        else {
            [self.delegate userSignUpDidFailWithError:[dict objectForKey:@"error"]];
        }
    }];
    
    [request setFailedBlock:^{
        [self.delegate userSignUpDidFailWithError:request.error.localizedDescription];
    }];
    
    [request startAsynchronous];
}

- (void)restorePassword {
    NSString *params = [[NSString stringWithFormat:@"?request=restore_password&email=%@", self.email] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setCompletionBlock:^{
        NSDictionary *dict = [request.responseString JSONValue];
        BOOL response = [[dict objectForKey:@"response"] boolValue];
        if (response) {
            [self.delegate userDidRestorePasswordWithMessage:[dict objectForKey:@"message"]];
        }
        else {
            [self.delegate userRestorePasswordDidFailWithError:[dict objectForKey:@"error"]];
        }
    }];
    
    [request setFailedBlock:^{
        [self.delegate userDidRestorePasswordWithMessage:request.error.localizedDescription];
    }];
    
    [request startAsynchronous];
}

- (void)getUserAgreement {
    NSString *params = [@"?request=user_agreement" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setCompletionBlock:^{
        NSDictionary *dict = [request.responseString JSONValue];
        BOOL response = [[dict objectForKey:@"response"] boolValue];
        if (response) {
            [self.delegate userDidLoadUserAgreementWithMessage:[dict objectForKey:@"message"]];
        }
        else {
            [self.delegate userAgreementDidFailWithError:[dict objectForKey:@"error"]];
        }
    }];
    
    [request setFailedBlock:^{
        [self.delegate userAgreementDidFailWithError:request.error.localizedDescription];
    }];
    
    [request startAsynchronous];
}

- (void)saveUser {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (self.isSave == YES) {
        [userDefaults setObject:self.email forKey:@"userEmail"];
        [userDefaults setObject:self.password forKey:@"userPassword"];
        [userDefaults setObject:@"yes" forKey:@"userIsSave"];
    } else{
        [userDefaults setObject:@"no" forKey:@"userIsSave"];
    }
    
    [userDefaults setObject:self.token forKey:@"userToken"];
    [userDefaults setObject:[NSDate date] forKey:@"lastVisit"];
}

- (void)loadUser {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.email = [userDefaults objectForKey:@"userEmail"];
    self.password = [userDefaults objectForKey:@"userPassword"];
    self.token = [userDefaults objectForKey:@"userToken"];
    self.lastVisit = [userDefaults objectForKey:@"lastVisit"];
    NSString *isSave = [userDefaults objectForKey:@"userSave"];
    if ([isSave isEqualToString:@"yes"])
        self.isSave = YES;
    else {
        self.isSave = NO;
    }
}

-(void)clear{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults removeObjectForKey:@"userToken"];
    [User sharedUser].token = nil;
    if ([User sharedUser].isSave == NO) {
        [userDefaults removeObjectForKey:@"userEmail"];
        [userDefaults removeObjectForKey:@"userPassword"];
        [userDefaults removeObjectForKey:@"userSave"];
        [userDefaults removeObjectForKey:@"lastVisit"];
        [User sharedUser].email = nil;
        [User sharedUser].password = nil;
    }
}

@end
