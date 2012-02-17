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
#import "Constants.h"
#import "ASIFormDataRequest.h"
#import "News.h"
#import "SDWebImageManager.h"
#import "UIImage+Thumbnail.h"
#import "Comment.h"

@interface New()
//@property (nonatomic, strong) NewDataReceiver *dataReceiver;
//@property (nonatomic, strong) NewDetailDataReceiver *detailDataReceiver;
//@property (nonatomic, strong) NewPhotosReceiver *photoReceiver;
@property (nonatomic) int section;
@property (nonatomic) int row;
@property (nonatomic) int downloadingImage;
//@property (nonatomic, strong) PhotoDownloader *photoDownloader;

- (void)didLoadData:(ASIHTTPRequest *)request;
- (void)didGetDetails:(ASIHTTPRequest *)request;
- (void)didGetPhoto:(ASIHTTPRequest *)request;
- (void)didAddComment:(ASIHTTPRequest *)request;
@end

@implementation New

@synthesize ID = _ID;
@synthesize date = _date;
@synthesize author = _author;
@synthesize photoUrl = _image;
@synthesize title = _header;
@synthesize comments = _comments;
//@synthesize photos = _photos;
//@synthesize dataReceiver = _dataReceiver;
@synthesize text = _text;
//@synthesize detailDataReceiver = _detailDataReceiver;
@synthesize photosCount = _photos_count;
@synthesize commentsCount = _comments_count;
//@synthesize photoReceiver = _photoReceiver;
@synthesize url = _url;
@synthesize section = _section;
@synthesize row = _row;
@synthesize parent = _parent;
@synthesize thumbnail = _thumbnail;
//@synthesize photoDownloader = _photoDownloader;
@synthesize photoURLs = _photosUrls;
//@synthesize thumbnails = _thumbnails;
@synthesize downloadingImage = _downloadingImage;

- (NSMutableArray *)photoURLs {
    if (!_photosUrls) {
        _photosUrls = [[NSMutableArray alloc] init];
    }
    return _photosUrls;
}

- (NSMutableArray *)comments {
    if (!_comments) {
        _comments = [[NSMutableArray alloc] init];
    }
    return _comments;
}

- (void)loadDataForRow:(int)row inSection:(int)section {
    self.row = row;
    self.section = section;
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"news_header", @"request", [NSNumber numberWithInteger:section], @"section", [NSNumber numberWithInteger:row], @"row", nil];
    
    NSLog(@"Запрос информации о новости: %@", dict.description);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    [request setPostValue:[jsonWriter stringWithObject:dict] forKey:@"jsonData"];
    request.delegate = self;
    request.didFinishSelector = @selector(didLoadData:);
    [request startAsynchronous];
}

- (void)didLoadData:(ASIHTTPRequest *)request {
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [jsonParser objectWithString:[request responseString]];
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), dict.description);
    
    self.ID = [[dict objectForKey:@"id"] intValue];
    self.title = [dict objectForKey:@"header"];
    
    NSString *photo = [dict objectForKey:@"photo"];
    if (!photo) photo = @"";
    self.photoUrl = [NSURL URLWithString:[kWEBSITE stringByAppendingString:photo]];

    NSLog(@"Photo url: %@", self.photoUrl);
    
    // Загрузка thumbnail новости
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    UIImage *cachedImage = [manager imageWithURL:self.photoUrl];
    if (cachedImage)
    {
        self.thumbnail = [cachedImage thumbnailByScalingProportionallyAndCroppingToSize:CGSizeMake(81, 81)];
        [self.parent didGetNewForRow:self.row inSection:self.section];
    }
    else
    {
        // Start an async download
        [manager downloadWithURL:self.photoUrl delegate:self];
    }    
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error {
    self.thumbnail = [[UIImage imageNamed:@"placeholder.png"] thumbnailOfSize:CGSizeMake(81, 81)];
    [self.parent didGetNewForRow:self.row inSection:self.section];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image {
    self.thumbnail = [image thumbnailByScalingProportionallyAndCroppingToSize:CGSizeMake(81, 81)];
    [self.parent didGetNewForRow:self.row inSection:self.section];
}

- (void)getDetails {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"news_content", @"request", [NSNumber numberWithInt:self.ID], @"id", nil];
    
    NSLog(@"%@: %@", NSStringFromSelector(_cmd), dict.description);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    [request setPostValue:[jsonWriter stringWithObject:dict] forKey:@"jsonData"];
    request.delegate = self;
    request.didFinishSelector = @selector(didGetDetails:);
    [request startAsynchronous];
}

- (void)didGetDetails:(ASIHTTPRequest *)request {
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *responseDict = [jsonParser objectWithString:[request responseString]];
    
    NSLog(@"%@: %@", NSStringFromSelector(_cmd), responseDict.description);
    
    id authorId = [responseDict objectForKey:@"author"];
    self.author = (!authorId || [authorId isKindOfClass:[NSNull class]]) ? @"" : authorId;
    self.text = (NSString *)[responseDict objectForKey:@"content"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.date = [df dateFromString:[responseDict objectForKey:@"date"]];
    self.photosCount = [[responseDict objectForKey:@"photos_count"] intValue];
    NSString *url = [responseDict objectForKey:@"url"];
    if (!url) url = @"";
    self.url = [NSURL URLWithString:url relativeToURL:kWEBSITE_URL];
    
    // Получение комментариев
    self.commentsCount = [[responseDict objectForKey:@"comments_count"] intValue];
    self.comments = [NSMutableArray arrayWithCapacity:self.commentsCount];
    NSArray *commentsArray = [responseDict objectForKey:@"comments"];
    for (int i = 0; i < self.commentsCount; i++) {
        Comment *comment = [[Comment alloc] init];
        NSDictionary *commentDictionary = [commentsArray objectAtIndex:i];
        comment.author = (NSString *)[commentDictionary objectForKey:@"author"];
        comment.date = [NSDate dateWithTimeIntervalSince1970:[((NSNumber *)[commentDictionary objectForKey:@"date"]) intValue]];
        comment.text = (NSString *)[commentDictionary objectForKey:@"content"];
        [self.comments insertObject:comment atIndex:i];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_NEW_DETAILS object:nil];
}

- (void)getPhotos {
    if (!self.photosCount) return;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"news_photo", @"request", [NSNumber numberWithInteger:self.ID], @"id", [NSNumber numberWithInteger:self.downloadingImage], @"number", nil];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    [request setPostValue:[jsonWriter stringWithObject:dict] forKey:@"jsonData"];
    request.delegate = self;
    request.didFinishSelector = @selector(didGetPhoto:);
    [request startAsynchronous];
}

- (void)didGetPhoto:(ASIHTTPRequest *)request {
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [jsonParser objectWithString:[request responseString]];
    NSString *photo = [dict objectForKey:@"photo"];
    if (!photo) photo = @"";
    NSString *url = [kWEBSITE stringByAppendingPathComponent:photo];
    [self.photoURLs insertObject:url atIndex:self.downloadingImage];
    
    if (++self.downloadingImage != self.photosCount) {
        [self getPhotos];
    }
    else {
        self.downloadingImage = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_PHOTOS object:nil];
    }
}

//- (void)loadPhotos {
//    [self.photoDownloader downloadPhoto:[self.photosURLs objectAtIndex:downloadingImage]];
//}
//
//- (void)photoDownloaderDidDownloadPhoto:(UIImage *)image {
//    [self.photos insertObject:image atIndex:downloadingImage];
//    [self.thumbnails insertObject:[image thumbnailByScalingProportionallyAndCroppingToSize:CGSizeMake(64, 64)] atIndex:downloadingImage];
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"didGetPhoto" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:downloadingImage++], @"number", nil]];
//    
//    if (downloadingImage < self.photosCount) {
//        [self loadPhotos];
//    }
//    else {
//        downloadingImage = 0;
//    }
//}

- (void)addCommentWithName:(NSString *)name andText:(NSString *)text {
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
    request.delegate = self;
    request.didFinishSelector = @selector(didAddComment:);
    [request startAsynchronous];
}

- (void)didAddComment:(ASIHTTPRequest *)request {
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *responseDict = [jsonParser objectWithString:[request responseString]];
    
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), responseDict.description);
    
    int result = [[responseDict objectForKey:@"response"] intValue];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_ADD_COMMENT object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:result] forKey:@"result"]];
}

@end
