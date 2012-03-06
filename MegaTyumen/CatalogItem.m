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
@end

@implementation CatalogItem
@synthesize ID = _ID;
@synthesize name = _name;
@synthesize address = _address;
@synthesize description = _description;
//@synthesize photos = _photos;
@synthesize checkinCount = _checkinCount;
@synthesize phone = _phone;
@synthesize website = _website;
@synthesize menu = _menu;
@synthesize feedbacks = _feedbacks;
@synthesize events = _events;
@synthesize type = _type;
@synthesize cuisine = _cuisine;
@synthesize weekdayHours = _weekdayHours;
//@synthesize breakHours = _breakHours;
//@synthesize saturdayHours = _saturdayHours;
//@synthesize sundayHours = _sundayHours;
@synthesize location = _location;
@synthesize bill = _bill;
@synthesize photos = _photos;
@synthesize distance = _distance;
@synthesize logo = _logo;
@synthesize distanceString = _distanceString;

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

#pragma mark -

- (id)initWithID:(int)ID {
    if (self = [super init]) {
        _ID = ID;
    }
    return self;
}

- (void)setDistance:(double)distance {
    _distance = distance;
    if (self.distance < 1000) {
        self.distanceString = [NSString stringWithFormat:@"%.0lf м", self.distance];
    }
    else {
        self.distanceString = [NSString stringWithFormat:@"%.0lf км", self.distance / 1000];
    }
}

- (void)getDetails {
    [self getDetailsWithLocation:kDEFAULT_LOCATION];
}

- (void)getDetailsWithLocation:(CLLocation *)location {
    if (gotDetails) return;
    
    NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:@"company_details", @"request", [NSNumber numberWithInt:self.ID], @"id", nil];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), requestDict.description);
    
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:requestDict] forKey:@"jsonData"];
    [request startSynchronous];
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [jsonParser objectWithString:[request responseString]];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
    
    BOOL response = [[dict objectForKey:@"response"] boolValue];
    if (response) {
        self.name = [dict objectForKey:@"name"];
        self.logo = [NSURL URLWithString:[dict objectForKey:@"logo"] relativeToURL:kWEBSITE_URL];
        self.address = [dict objectForKey:@"address"];
        double lat = [[dict objectForKey:@"lat"] doubleValue];
        double lng = [[dict objectForKey:@"lng"] doubleValue];
        self.location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
        self.distance = [location distanceFromLocation:self.location] / 1000;
        
        self.description = [dict objectForKey:@"description"];
        NSArray *photos = [dict objectForKey:@"photos"];
        [self.photos removeAllObjects];
        for (NSDictionary *photo in photos) {
            NSURL *url = [NSURL URLWithString:[photo objectForKey:@"photo"] relativeToURL:kWEBSITE_URL];
            [self.photos addObject:url];
        }
        gotDetails = YES;
    }
}

- (void)getCommon {
    if (gotCommon) return;
    
    NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:@"catalog_details2", @"request", [NSNumber numberWithInt:self.ID], @"id", nil];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), requestDict.description);
    
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:requestDict] forKey:@"jsonData"];
    [request startSynchronous];
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [jsonParser objectWithString:[request responseString]];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
    
    BOOL response = [[dict objectForKey:@"response"] boolValue];
    if (response) {
        self.description = [dict objectForKey:@"description"];
        self.phone = [dict objectForKey:@"phone"];
        self.website = [dict objectForKey:@"website"];
        //self.type = [dict objectForKey:@"type"];
        self.weekdayHours = [dict objectForKey:@"weekdays_hours"];
        double lat = [[dict objectForKey:@"lat"] doubleValue];
        double lng = [[dict objectForKey:@"lng"] doubleValue];
        self.location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
        
        gotCommon = YES;
    }
}

- (void)getPhotos {
    if (gotPhotos) return;
    
    NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:@"catalog_photos", @"request", [NSNumber numberWithInt:self.ID], @"id", nil];

    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), requestDict.description);
    
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:requestDict] forKey:@"jsonData"];
    //request.delegate = self;
    //request.didFinishSelector = @selector(didGetDetails:);
    [request startSynchronous];
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [jsonParser objectWithString:[request responseString]];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
    
    BOOL response = [[dict objectForKey:@"response"] boolValue];
    if (response) {
        [self.photos removeAllObjects];
        NSArray *photos = [dict objectForKey:@"photos"];
        for (NSDictionary *photo in photos) {
            NSURL *url = [NSURL URLWithString:[photo objectForKey:@"photo"] relativeToURL:kWEBSITE_URL];
            [self.photos addObject:url];
        }
        gotPhotos = YES;
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

//- (void)getPhotos {
//    [self didGetPhotos:nil];
//}

//- (void)didGetPhotos:(ASIHTTPRequest *)request {
//        
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"didGetPhotos" object:nil];
//    NSLog(@"Post didGetPhotos");
//}

- (void)getMenu {
    if (gotMenu) return;
    
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
        NSArray *menu = [dict2 objectForKey:@"menu"];
        for (NSDictionary *item in menu) {
            MenuItem *m = [[MenuItem alloc] init];
            m.title = [item objectForKey:@"title"];
            m.price = [[item objectForKey:@"cost"] doubleValue];
            m.image = [NSURL URLWithString:[item objectForKey:@"image"] relativeToURL:kWEBSITE_URL];
            
            [self.menu addObject:m];
        }
        gotMenu = YES;
    }
}

- (void)getFeedbacks {
    if (gotFeedbacks) return;
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"company_feedback", @"request", [NSNumber numberWithInt:self.ID], @"id", nil];
    NSString *query = [writer stringWithObject:dict];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:query forKey:@"jsonData"];
    [request startSynchronous];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict2 = [parser objectWithString:request.responseString];
    BOOL result = [[dict2 objectForKey:@"response"] boolValue];
    if (result) {
        [self.feedbacks removeAllObjects];
        NSArray *feedbacks = [dict2 objectForKey:@"feedbacks"];
        for (NSDictionary *feedback in feedbacks) {
            Feedback *f = [[Feedback alloc] init];
            f.text = [feedback objectForKey:@"text"];            
            f.attitude = [[feedback objectForKey:@"attitude"] intValue];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            f.date = [df dateFromString:[feedback objectForKey:@"date"]];
            f.userName = [feedback objectForKey:@"user_name"];
            
            [self.feedbacks addObject:f];
        }
        gotFeedbacks = YES;
    }
}

- (void)getEvents {
    if (gotEvents) return;
    
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"company_events", @"request", [NSNumber numberWithInt:self.ID], @"id", nil];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
    
    NSString *query = [writer stringWithObject:dict];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:query forKey:@"jsonData"];
    [request startSynchronous];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict2 = [parser objectWithString:request.responseString];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict2.description);
    
    BOOL result = [[dict2 objectForKey:@"response"] boolValue];
    if (result) {
        [self.events removeAllObjects];
        NSArray *events = [dict2 objectForKey:@"events"];
        for (NSDictionary *event in events) {
            Event *e = [[Event alloc] init];
            e.text = [event objectForKey:@"announce"];
            e.title = [event objectForKey:@"title"];
            e.image = [event objectForKey:@"image"];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            e.date = [df dateFromString:[event objectForKey:@"date"]];
            
            [self.events addObject:e];
        }
        gotEvents = YES;
    }
}

@end
