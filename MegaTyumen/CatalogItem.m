//
//  CatalogItem.m
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 04.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CatalogItem.h"
#import "SBJson.h"
#import "Constants.h"
#import "UIImage+Thumbnail.h"
#import "ASIFormDataRequest.h"
#import "Authorization.h"
#import "MenuItem.h"
#import "Feedback.h"
#import "Event.h"

@interface CatalogItem()
//- (void)didGetDetails:(ASIHTTPRequest *)request;
//- (void)didCheckin:(ASIHTTPRequest *)request;
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
@synthesize feedbacks = _feedbacks;
@synthesize events = _events;
@synthesize type = _type;
@synthesize cuisine = _cuisine;
@synthesize weekdayHours = _weekdayHours;
@synthesize breakHours = _breakHours;
@synthesize saturdayHours = _saturdayHours;
@synthesize sundayHours = _sundayHours;
@synthesize location = _location;
@synthesize bill = _bill;
@synthesize photos = _photos;
@synthesize distance = _distance;
@synthesize image = _image;

#pragma mark - Lazy instantiation

- (NSMutableArray *)menu {
    if (!_menu) {
        _menu = [[NSMutableArray alloc] init];
    }
    return _menu;
}

- (NSMutableArray *)events {
    if (!_events) {
        _events = [[NSMutableArray alloc] init];
    }
    return _events;
}

- (NSMutableArray *)feedbacks {
    if (!_feedbacks) {
        _feedbacks = [[NSMutableArray alloc] init];
    }
    return _feedbacks;
}

- (NSMutableArray *)photos {
    if (!_photos) {
        _photos = [[NSMutableArray alloc] init];
    }
    return _photos;
}

- (void)getDetails {
    NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:@"catalog_details", @"request", [NSNumber numberWithInt:self.ID], @"id", nil];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:requestDict] forKey:@"jsonData"];
    request.delegate = self;
    request.didFinishSelector = @selector(didGetDetails:);
    [request startSynchronous];
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [jsonParser objectWithString:[request responseString]];
    BOOL response = [[dict objectForKey:@"response"] boolValue];
    if (response) {
        self.description = [dict objectForKey:@"description"];
        NSArray *photos = [dict objectForKey:@"photos"];
        for (NSDictionary *photo in photos) {
            NSURL *url = [NSURL URLWithString:[photo objectForKey:@"photo"] relativeToURL:kWEBSITE_URL];
            [self.photos addObject:url];
        }
    }
}

//- (void)didGetDetails:(ASIHTTPRequest *)request {
//    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//    NSDictionary *responseDict = [jsonParser objectWithString:[request responseString]];
//    //-------
//    //NSLog(@"CatalogItemDetails: %@", responseDict.description);
//    //--------
//    self.description = [responseDict objectForKey:@"description"];
//    //self.description = @"";
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"didGetDetails" object:nil];
//}

- (NSDictionary *)checkinWithFeedBack:(NSString *)feedback andAttitude:(int)attitude {
    NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:@"checkin", @"request", [NSNumber numberWithInt:self.ID], @"id", [Authorization sharedAuthorization].token, @"token", feedback, @"text", [NSNumber numberWithInt:attitude], @"attitude", nil];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:requestDict] forKey:@"jsonData"];
    //request.delegate = self;
    //request.didFinishSelector = @selector(didCheckin:);
    //request.didFailSelector = @selector(didCheckin:);
    [request startSynchronous];
    
    NSLog(@"Отправил чекин: %@", requestDict.description); 
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [jsonParser objectWithString:[request responseString]];
    return dict;
}

//- (void)didCheckin:(ASIHTTPRequest *)request {
//    int result;
//    NSString *error;
//    
//    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//    NSDictionary *responseDict = [jsonParser objectWithString:[request responseString]];
//    result = [[responseDict objectForKey:@"response"] intValue];
//    if (!result) {
//        error = [responseDict objectForKey:@"error"];
//    }
//    
//    NSLog(@"Получил ответ по чекину: %@", responseDict.description);
//    
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_CHECKIN object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:result], @"result", error, @"error", nil]];
//}

- (void)getPhotos {
    [self didGetPhotos:nil];
}

- (void)didGetPhotos:(ASIHTTPRequest *)request {
        
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didGetPhotos" object:nil];
    NSLog(@"Post didGetPhotos");
}

- (void)getMenu {
    //[self didGetMenu:nil];
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"company_menu", @"request", [NSNumber numberWithInt:self.ID], @"id", nil];
    NSString *query = [writer stringWithObject:dict];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:query forKey:@"jsonData"];
    [request startSynchronous];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict2 = [parser objectWithString:request.responseString];
    BOOL result = [[dict2 objectForKey:@"response"] boolValue];
    if (result) {
        NSArray *items = [dict2 objectForKey:@"items"];
        for (NSDictionary *item in items) {
            MenuItem *m = [[MenuItem alloc] init];
            m.title = [item objectForKey:@"title"];
            m.price = [[item objectForKey:@"cost"] intValue];
            id imageId = [item objectForKey:@"image"];
            NSString *imageStr = (!imageId || [imageId isKindOfClass:[NSNull class]]) ? @"" : imageId;
            m.image = [NSURL URLWithString:imageStr relativeToURL:kWEBSITE_URL];
            
            [self.menu addObject:m];
        }
    }
}

- (void)didGetMenu:(ASIHTTPRequest *)request {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didGetMenu" object:nil];
}

- (void)getFeedbacks {
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"feedback", @"request", [NSNumber numberWithInt:self.ID], @"id", nil];
    NSString *query = [writer stringWithObject:dict];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:query forKey:@"jsonData"];
    [request startSynchronous];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict2 = [parser objectWithString:request.responseString];
    BOOL result = [[dict2 objectForKey:@"response"] boolValue];
    if (result) {
        NSArray *comments = [dict2 objectForKey:@"comments"];
        for (NSDictionary *comment in comments) {
            Feedback *f = [[Feedback alloc] init];
            f.text = [comment objectForKey:@"comment"];
            f.attitude = [[comment objectForKey:@"attitude"] intValue];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            f.date = [df dateFromString:[comment objectForKey:@"date"]];
            
            [self.events addObject:f];
        }
    }
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
