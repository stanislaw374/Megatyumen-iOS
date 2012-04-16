//
//  Constants.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 22.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#define kAPI_URL [NSURL URLWithString:@"http://itisntrandomhostname.megatyumen.ru/api"]
//#define kAPI_URL [NSURL URLWithString:@"http://192.168.88.51/api"]

#define kWEBSITE @"http://megatyumen.ru"
#define kWEBSITE_URL [NSURL URLWithString:kWEBSITE]
#define kFB_APP_ID @"251079404955893"
#define kPLACEHOLDER_IMAGE [UIImage imageNamed:@"placeholder.png"]
#define KEY_REQUEST @"request"
#define KEY_JSON_DATA @"jsonData"
#define KEY_ERROR @"error"
#define KEY_LOGIN @"login"
#define KEY_PASSWORD @"password"
#define KEY_WAS_LAUNCHED @"wasLaunched"
#define KEY_RESPONSE @"response"
#define KEY_IS_AUTHORIZED @"isAuthorized"
#define kREQUEST_TIMEOUT 30
#define kDEFAULT_LOCATION [[CLLocation alloc] initWithLatitude:57.1196 longitude:65.5649]