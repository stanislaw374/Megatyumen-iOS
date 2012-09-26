//
//  New.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "New.h"
#import "Authorization.h"
#import "SBJson.h"
#import "Config.h"
#import "ASIFormDataRequest.h"
#import "News.h"
#import "SDWebImageManager.h"
#import "UIImage+Thumbnail.h"
#import "Comment.h"
#import "SDImageCache.h"
#import "User.h"

@interface New()
//@property (nonatomic, strong) NewDataReceiver *dataReceiver;
//@property (nonatomic, strong) NewDetailDataReceiver *detailDataReceiver;
//@property (nonatomic, strong) NewPhotosReceiver *photoReceiver;
//@property (nonatomic) int section;
//@property (nonatomic) int row;
//@property (nonatomic) int downloadingImage;
//@property (nonatomic, strong) PhotoDownloader *photoDownloader;

//- (void)didLoadData:(ASIHTTPRequest *)request;
//- (void)didGetDetails:(ASIHTTPRequest *)request;
//- (void)didGetPhoto:(ASIHTTPRequest *)request;
//- (void)didAddComment:(ASIHTTPRequest *)request;
//- (void)getTitle;
@end

@implementation New

@synthesize ID = _ID;
@synthesize date = _date;
@synthesize user = _user;
@synthesize imageURL = _imageURL;
@synthesize title = _header;
@synthesize comments = _comments;
@synthesize images = _images;
@synthesize text = _text;
@synthesize link = _link;
@synthesize type = _type;
//@synthesize image = _image;
@synthesize thumbnailURL = _thumbnailURL;
@synthesize thumbnails = _thumbnails;
@synthesize delegate = _delegate;
//@synthesize section = _section;
//@synthesize thumbnail = _thumbnail;
//@synthesize photoDownloader = _photoDownloader;
//@synthesize photoURLs = _photosUrls;
//@synthesize thumbnails = _thumbnails;
//@synthesize downloadingImage = _downloadingImage;

//- (void)setImageURL:(NSURL *)imageURL {
//    _imageURL = imageURL;
//    [SDImageCache load
//}

- (NSMutableArray *)images {
    if (!_images) {
        _images = [[NSMutableArray alloc] init];
    }
    return _images;
}

- (NSMutableArray *)comments {
    if (!_comments) {
        _comments = [[NSMutableArray alloc] init];
    }
    return _comments;
}

- (NSMutableArray *)thumbnails {
    if (!_thumbnails) {
        _thumbnails = [NSMutableArray array];
    }
    return _thumbnails;
}

- (void)getContent {
    NSString *params = [[NSString stringWithFormat:@"?request=new_content&id=%d", self.ID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSDictionary *rd = [request.responseString JSONValue];
        BOOL response = [[rd objectForKey:@"response"] boolValue];
        if (response) {
            self.imageURL = [NSURL URLWithString:[rd objectForKey:@"image"] relativeToURL:kWEBSITE_URL];
            self.text = [rd objectForKey:@"text"];
            self.user = [rd objectForKey:@"user_name"];
            int images_count = [[rd objectForKey:@"images_count"] intValue];
            self.images = [[NSMutableArray alloc] initWithCapacity:images_count];
            for (int i = 0; i < images_count; i++) {
                [self.images addObject:[NSNull null]];
            }
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            self.date = [df dateFromString:[rd objectForKey:@"date"]];
            self.link = [kWEBSITE stringByAppendingString:[rd objectForKey:@"link"]];
            self.comments = [[NSMutableArray alloc] init];
            NSArray *comments = [rd objectForKey:@"comments"];
            for (NSDictionary *comment in comments) {
                Comment *c = [[Comment alloc] init];
                c.user = [comment objectForKey:@"user_name"];
                c.text = [comment objectForKey:@"text"];
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                c.date = [df dateFromString:[comment objectForKey:@"date"]];
                
                [self.comments addObject:c];
            }
            [self.delegate newDidLoad];
        }
    }];
    [request setFailedBlock:^{
        [self.delegate newDidFailWithError:request.error.localizedDescription];
    }];
    
    [request startAsynchronous];
}

- (void)getImages {
    NSString *params = [[NSString stringWithFormat:@"?request=new_images&id=%d", self.ID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSDictionary *rd = [request.responseString JSONValue];
        BOOL response = [[rd objectForKey:@"response"] boolValue];
        if (response) {
            NSArray *images = [rd objectForKey:@"new_images"];
            [self.images removeAllObjects];
            [self.thumbnails removeAllObjects];
            for (NSDictionary *image in images) {
                NSURL *url = [NSURL URLWithString:[image objectForKey:@"image"] relativeToURL:kWEBSITE_URL];
                [self.images addObject:url];
                url = [NSURL URLWithString:[image objectForKey:@"thumbnail"] relativeToURL:kWEBSITE_URL];
                [self.thumbnails addObject:url];
            }
            [self.delegate newDidGetImages];
        }
    }];
    
    [request setFailedBlock:^{
        [self.delegate newImagesDidFailWithError:request.error.localizedDescription];
    }];
    
    [request startAsynchronous];
}

- (void)addCommentWithName:(NSString *)name andText:(NSString *)text{
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSString *params = [NSString stringWithFormat:@"?request=new_add_comment&id=%d&comment=%@&name=%@&type=%@", self.ID, text, name, self.type];
    if ([User sharedUser].token) {
        params = [params stringByAppendingString:[NSString stringWithFormat:@"&token=%@", [User sharedUser].token]];
    }
    params = [params stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(params);
    NSURL *url = [NSURL URLWithString:params relativeToURL:kAPI_URL];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
        NSDictionary *rd = [request.responseString JSONValue];
        BOOL response = [[rd objectForKey:@"response"] boolValue];
        if (response) {
            NSString *message = [rd objectForKey:@"message"];
            [self.delegate newDidAddCommentWithMessage:message];
        }
        else {
            [self.delegate newDidFailWithError:[rd objectForKey:@"error"]];
        }
    }];
    [request setFailedBlock:^{
        [self.delegate newDidFailWithError:request.error.localizedDescription];
    }];
    [request startAsynchronous];
}

//- (void)loadDataForRow:(int)row inSection:(int)section {
//    self.row = row;
//    self.section = section;
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"news_header", @"request", [NSNumber numberWithInteger:section], @"section", [NSNumber numberWithInteger:row], @"row", nil];
//    
//    NSLog(@"Запрос информации о новости: %@", dict.description);
//    
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
//    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
//    [request setPostValue:[jsonWriter stringWithObject:dict] forKey:@"jsonData"];
//    request.delegate = self;
//    request.didFinishSelector = @selector(didLoadData:);
//    [request startAsynchronous];
//}
//
//- (void)didLoadData:(ASIHTTPRequest *)request {
//    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//    NSDictionary *dict = [jsonParser objectWithString:[request responseString]];
//    
//    NSLog(@"%@ %@", NSStringFromSelector(_cmd), dict.description);
//    
//    self.ID = [[dict objectForKey:@"id"] intValue];
//    self.title = [dict objectForKey:@"header"];
//    
//    NSString *photo = [dict objectForKey:@"photo"];
//    if (!photo) photo = @"";
//    self.photoUrl = [NSURL URLWithString:[kWEBSITE stringByAppendingString:photo]];
//
//    NSLog(@"Photo url: %@", self.photoUrl);
//    
//    // Загрузка thumbnail новости
//    SDWebImageManager *manager = [SDWebImageManager sharedManager];
//    UIImage *cachedImage = [manager imageWithURL:self.photoUrl];
//    if (cachedImage)
//    {
//        self.thumbnail = [cachedImage thumbnailByScalingProportionallyAndCroppingToSize:CGSizeMake(81, 81)];
//        //[self.parent didGetNewForRow:self.row inSection:self.section];
//    }
//    else
//    {
//        // Start an async download
//        [manager downloadWithURL:self.photoUrl delegate:self];
//    }    
//}
//
//- (void)webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error {
//    self.thumbnail = [[UIImage imageNamed:@"placeholder.png"] thumbnailOfSize:CGSizeMake(81, 81)];
//    //[self.parent didGetNewForRow:self.row inSection:self.section];
//}
//
//- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image {
//    self.thumbnail = [image thumbnailByScalingProportionallyAndCroppingToSize:CGSizeMake(81, 81)];
//    //[self.parent didGetNewForRow:self.row inSection:self.section];
//}
//
//- (void)getDetails {
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"news_content", @"request", [NSNumber numberWithInt:self.ID], @"id", nil];
//    
//    NSLog(@"%@: %@", NSStringFromSelector(_cmd), dict.description);
//    
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
//    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
//    [request setPostValue:[jsonWriter stringWithObject:dict] forKey:@"jsonData"];
//    request.delegate = self;
//    request.didFinishSelector = @selector(didGetDetails:);
//    [request startAsynchronous];
//}
//
//- (void)didGetDetails:(ASIHTTPRequest *)request {
//    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//    NSDictionary *responseDict = [jsonParser objectWithString:[request responseString]];
//    
//    NSLog(@"%@: %@", NSStringFromSelector(_cmd), responseDict.description);
//    
//    id authorId = [responseDict objectForKey:@"author"];
//    self.author = (!authorId || [authorId isKindOfClass:[NSNull class]]) ? @"" : authorId;
//    self.text = (NSString *)[responseDict objectForKey:@"content"];
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    self.date = [df dateFromString:[responseDict objectForKey:@"date"]];
//    self.photosCount = [[responseDict objectForKey:@"photos_count"] intValue];
//    NSString *url = [responseDict objectForKey:@"url"];
//    if (!url) url = @"";
//    self.url = [NSURL URLWithString:url relativeToURL:kWEBSITE_URL];
//    
//    // Получение комментариев
//    self.commentsCount = [[responseDict objectForKey:@"comments_count"] intValue];
//    self.comments = [NSMutableArray arrayWithCapacity:self.commentsCount];
//    NSArray *commentsArray = [responseDict objectForKey:@"comments"];
//    for (int i = 0; i < self.commentsCount; i++) {
//        Comment *comment = [[Comment alloc] init];
//        NSDictionary *commentDictionary = [commentsArray objectAtIndex:i];
//        comment.author = (NSString *)[commentDictionary objectForKey:@"author"];
//        comment.date = [NSDate dateWithTimeIntervalSince1970:[((NSNumber *)[commentDictionary objectForKey:@"date"]) intValue]];
//        comment.text = (NSString *)[commentDictionary objectForKey:@"content"];
//        [self.comments insertObject:comment atIndex:i];
//    }
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_NEW_DETAILS object:nil];
//}
//
//- (void)getPhotos {
//    if (!self.photosCount) return;
//    
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"news_photo", @"request", [NSNumber numberWithInteger:self.ID], @"id", [NSNumber numberWithInteger:self.downloadingImage], @"number", nil];
//    
//    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
//    
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
//    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
//    [request setPostValue:[jsonWriter stringWithObject:dict] forKey:@"jsonData"];
//    request.delegate = self;
//    request.didFinishSelector = @selector(didGetPhoto:);
//    [request startAsynchronous];
//}
//
//- (void)didGetPhoto:(ASIHTTPRequest *)request {
//    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//    NSDictionary *dict = [jsonParser objectWithString:[request responseString]];
//    NSString *photo = [dict objectForKey:@"photo"];
//    if (!photo) photo = @"";
//    NSString *url = [kWEBSITE stringByAppendingPathComponent:photo];
//    [self.photoURLs insertObject:url atIndex:self.downloadingImage];
//    
//    if (++self.downloadingImage != self.photosCount) {
//        [self getPhotos];
//    }
//    else {
//        self.downloadingImage = 0;
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_PHOTOS object:nil];
//    }
//}
//
////- (void)loadPhotos {
////    [self.photoDownloader downloadPhoto:[self.photosURLs objectAtIndex:downloadingImage]];
////}
////
////- (void)photoDownloaderDidDownloadPhoto:(UIImage *)image {
////    [self.photos insertObject:image atIndex:downloadingImage];
////    [self.thumbnails insertObject:[image thumbnailByScalingProportionallyAndCroppingToSize:CGSizeMake(64, 64)] atIndex:downloadingImage];
////
////    [[NSNotificationCenter defaultCenter] postNotificationName:@"didGetPhoto" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:downloadingImage++], @"number", nil]];
////    
////    if (downloadingImage < self.photosCount) {
////        [self loadPhotos];
////    }
////    else {
////        downloadingImage = 0;
////    }
////}
//
//- (void)addCommentWithName:(NSString *)name andText:(NSString *)text {
//    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    NSDictionary *dict;
//    if ([Authorization sharedAuthorization].isAuthorized) {
//        dict = [NSDictionary dictionaryWithObjectsAndKeys:@"add_comment", @"request", [NSNumber numberWithInt:self.ID], @"id", [Authorization sharedAuthorization].token, @"token", text, @"text", name, @"name", nil];
//    }
//    else {
//        dict = [NSDictionary dictionaryWithObjectsAndKeys:@"add_comment", @"request", [NSNumber numberWithInt:self.ID], @"id", text, @"text", name, @"name", nil];    
//    }
//    
//    NSLog(@"%@ %@", NSStringFromSelector(_cmd), dict.description);
//    
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
//    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
//    [request setPostValue:[jsonWriter stringWithObject:dict] forKey:@"jsonData"];
//    request.delegate = self;
//    request.didFinishSelector = @selector(didAddComment:);
//    [request startAsynchronous];
//}
//
//- (void)didAddComment:(ASIHTTPRequest *)request {
//    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//    NSDictionary *responseDict = [jsonParser objectWithString:[request responseString]];
//    
//    NSLog(@"%@ %@", NSStringFromSelector(_cmd), responseDict.description);
//    
//    int result = [[responseDict objectForKey:@"response"] intValue];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_ADD_COMMENT object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:result] forKey:@"result"]];
//}

@end
