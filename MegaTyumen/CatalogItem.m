//
//  CatalogItem.m
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 04.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CatalogItem.h"
#import "PhotoDownloader.h"
#import "SBJson.h"
#import "Constants.h"
#import "UIImage+Thumbnail.h"
#import "ASIFormDataRequest.h"
#import "Authorization.h"
#import "MenuItem.h"
#import "Feedback.h"
#import "Event.h"

@interface CatalogItem()
- (void)didGetDetails:(ASIHTTPRequest *)request;
- (void)didCheckin:(ASIHTTPRequest *)request;
- (void)didGetPhotos:(ASIHTTPRequest *)request;
- (void)didGetMenu:(ASIHTTPRequest *)request;
- (void)didGetFeedback:(ASIHTTPRequest *)request;
- (void)didGetEvents:(ASIHTTPRequest *)request;
@end

@implementation CatalogItem
@synthesize ID = _ID;
@synthesize name = _name;
@synthesize address = _address;
@synthesize description = _description;
//@synthesize photos = _photos;
@synthesize checkins = _checkinCount;
@synthesize phone = _phone;
@synthesize website = _website;
@synthesize menu = _menu;
@synthesize feedbacks = _feedback;
@synthesize events = _events;
@synthesize type = _type;
@synthesize cuisine = _cuisine;
@synthesize weekdayHours = _weekdayHours;
@synthesize breakHours = _breakHours;
@synthesize saturdayHours = _saturdayHours;
@synthesize sundayHours = _sundayHours;
@synthesize location = _location;
@synthesize bill = _bill;
@synthesize photosUrls = _photosUrls;
@synthesize distance = _distance;

- (id)init {
    if (self = [super init]) {
        self.menu = [[NSMutableArray alloc] init];
        self.feedbacks = [[NSMutableArray alloc] init];
        self.events = [[NSMutableArray alloc] init];
        //self.photos = [[NSMutableArray alloc] init];
        self.photosUrls = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)getDetails {
    NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:@"catalog_details", @"request", [NSNumber numberWithInt:self.ID], @"id", nil];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:requestDict] forKey:@"jsonData"];
    request.delegate = self;
    request.didFinishSelector = @selector(didGetDetails:);
    [request startAsynchronous];
}

- (void)didGetDetails:(ASIHTTPRequest *)request {
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *responseDict = [jsonParser objectWithString:[request responseString]];
    //-------
    //NSLog(@"CatalogItemDetails: %@", responseDict.description);
    //--------
    self.description = [responseDict objectForKey:@"description"];
    //self.description = @"";
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didGetDetails" object:nil];
}

- (void)checkinWithFeedBack:(NSString *)feedback andAttitude:(int)attitude {
    NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:@"checkin", @"request", [NSNumber numberWithInt:self.ID], @"id", [Authorization sharedAuthorization].token, @"token", feedback, @"comment", [NSNumber numberWithInt:attitude], @"attitude", nil];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:requestDict] forKey:@"jsonData"];
    request.delegate = self;
    request.didFinishSelector = @selector(didCheckin:);
    //request.didFailSelector = @selector(didCheckin:);
    [request startAsynchronous];
    
    NSLog(@"Отправил чекин: %@", requestDict.description); 
}

- (void)didCheckin:(ASIHTTPRequest *)request {
    int result;
    NSString *error;
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *responseDict = [jsonParser objectWithString:[request responseString]];
    result = [[responseDict objectForKey:@"response"] intValue];
    if (!result) {
        error = [responseDict objectForKey:@"error"];
    }
    
    NSLog(@"Получил ответ по чекину: %@", responseDict.description);
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_CHECKIN object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:result], @"result", error, @"error", nil]];
}

- (void)getPhotos {
    [self didGetPhotos:nil];
}

- (void)didGetPhotos:(ASIHTTPRequest *)request {
        
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didGetPhotos" object:nil];
    NSLog(@"Post didGetPhotos");
}

- (void)getMenu {
    [self didGetMenu:nil];
}

- (void)didGetMenu:(ASIHTTPRequest *)request {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didGetMenu" object:nil];
}

- (void)getFeedbacks {
    [self didGetFeedback:nil];
}

- (void)didGetFeedback:(ASIHTTPRequest *)request {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didGetCatalogItemFeedback" object:nil];
}

- (void)getEvents {
    [self didGetEvents:nil];
}

- (void)didGetEvents:(ASIHTTPRequest *)request {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didGetCatalogItemEvents" object:nil];
}

@end
