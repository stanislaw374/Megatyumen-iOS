//
//  EventItem.m
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Event.h"
#import "SBJSON.h"
#import "ASIFormDataRequest.h"
#import "Constants.h"
#import "Comment.h"
#import "Authorization.h"

@interface Event()
//@property (nonatomic, strong) SDWebImageDownloader *downloader;
@end

@implementation Event
@synthesize companyID = _companyID;
@synthesize companyName = _companyName;
//@synthesize text = _text;
//@synthesize date = _date;
//@synthesize image = _image;
//@synthesize title = _title;
//@synthesize images = _images;
//@synthesize comments = _comments;
//@synthesize link = _link;
//@synthesize ID = _ID;

//- (NSMutableArray *)images {
//    if (!_images) {
//        _images = [[NSMutableArray alloc] init];
//    }
//    return _images;
//}
//
//- (NSMutableArray *)comments {
//    if (!_comments) {
//        _comments = [[NSMutableArray alloc] init];
//    }
//    return _comments;
//}

- (void)getContent {
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"catalogue_event_details", @"request", [NSNumber numberWithInt:self.ID], @"id", nil];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
    
    NSString *query = [writer stringWithObject:dict];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:query forKey:@"jsonData"];
    [request startSynchronous];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict2 = [parser objectWithString:request.responseString];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict2.description);
    
    BOOL response = [[dict2 objectForKey:@"response"] boolValue];
    if (response) {
        self.text = [dict2 objectForKey:@"text"];
        self.user = [dict2 objectForKey:@"user"];
        int images_count = [[dict2 objectForKey:@"images_count"] intValue];
        self.images = [[NSMutableArray alloc] initWithCapacity:images_count];
        for (int i = 0; i < images_count; i++) {
            [self.images addObject:[NSNull null]];
        }
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        self.date = [df dateFromString:[dict2 objectForKey:@"date"]];
        self.link = [dict2 objectForKey:@"link"];
        self.comments = [[NSMutableArray alloc] init];
        NSArray *comments = [dict2 objectForKey:@"comments"];
        for (NSDictionary *comment in comments) {
            Comment *c = [[Comment alloc] init];
            c.user = [comment objectForKey:@"user"];
            c.text = [comment objectForKey:@"text"];
            c.date = [comment objectForKey:@"date"];
            
            [self.comments addObject:c];
        }
    }
}

- (void)getImages {
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"news_images", @"request", [NSNumber numberWithInt:self.ID], @"id", nil];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
    
    NSString *query = [writer stringWithObject:dict];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:query forKey:@"jsonData"];
    [request startSynchronous];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict2 = [parser objectWithString:request.responseString];
    BOOL response = [[dict2 objectForKey:@"response"] boolValue];
    if (response) {
        NSArray *images = [dict2 objectForKey:@"images"];
        int i = 0;
        for (NSDictionary *image in images) {
            NSURL *url = [NSURL URLWithString:[image objectForKey:@"image"] relativeToURL:kWEBSITE_URL];
            [self.images replaceObjectAtIndex:i++ withObject:url];
        }
    }
}

- (BOOL)addCommentWithName:(NSString *)name andText:(NSString *)text {
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSDictionary *dict;
    if ([Authorization sharedAuthorization].isAuthorized) {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:@"add_comment", @"request", [NSNumber numberWithInt:self.ID], @"id", [Authorization sharedAuthorization].token, @"token", text, @"text", name, @"name", nil];
    }
    else {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:@"add_comment", @"request", [NSNumber numberWithInt:self.ID], @"id", text, @"text", name, @"name", nil];    
    }
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), dict.description);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    [request setPostValue:[jsonWriter stringWithObject:dict] forKey:@"jsonData"];
    //request.delegate = self;
    //request.didFinishSelector = @selector(didAddComment:);
    [request startSynchronous];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict2 = [parser objectWithString:request.responseString];
    BOOL response = [[dict2 objectForKey:@"response"] boolValue];
    return response;
}


@end
