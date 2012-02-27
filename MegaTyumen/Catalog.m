//
//  Catalog.m
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 04.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Catalog.h"
#import "Authorization.h"
#import "SBJson.h"
#import "Constants.h"
#import "CatalogItem.h"
#import "ASIFormDataRequest.h"
#import "UIImage+Thumbnail.h"
#import "CatalogCategory.h"
#import "MenuItem.h"
#import "Feedback.h"
#import "Event.h"
#import "NSString+HTML.h"

@interface Catalog()
@property (nonatomic) int allSections;
@property (nonatomic, strong) NSMutableArray *allRows;
@property (nonatomic, strong) NSMutableDictionary *allItems;
//----------------------------------------------------------
//@property (nonatomic) int counter;
//@property (nonatomic, strong) NSString *tmp_name;
//@property (nonatomic, strong) CatalogCategory *requeiredCategory;
//- (void)didGetCatalogByDistance:(ASIHTTPRequest *)request;
//- (void)didGetTypes:(ASIHTTPRequest *)request;
//- (void)didGetCuisines:(ASIHTTPRequest *)request;
//- (void)loadLocal;
//- (void)didGetCatalogByCategory:(ASIHTTPRequest *)request;
//- (void)didGetCatalogByName:(ASIHTTPRequest *)request;
@end

@implementation Catalog
@synthesize sections = _sections;
@synthesize rows = _rows;
@synthesize items = _items;
@synthesize searchString = _searchString;
@synthesize allItems = _allItems;
@synthesize allSections = _allSections;
@synthesize allRows = _allRows;
@synthesize categories = _categories;
//@synthesize counter = _counter;
//@synthesize tmp_name = _tmp_name;
//@synthesize requeiredCategory = _requeiredCategory;
@synthesize userLocation = _userLocation;

#pragma mark - Lazy Instantiation

- (NSMutableArray *)rows {
    if (!_rows) {
        _rows = [[NSMutableArray alloc] init];
    }
    return _rows;
}

- (NSMutableDictionary *)items {
    if (!_items) {
        _items = [[NSMutableDictionary alloc] init];
    }
    return _items;
}

- (NSMutableArray *)allRows {
    if (!_allRows) {
        _allRows = [[NSMutableArray alloc] init];
    }
    return _allRows;
}

- (NSMutableDictionary *)allItems {
    if (!_allItems) {
        _allItems = [[NSMutableDictionary alloc] init];
    }
    return _allItems;
}

- (id)init {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:57 longitude:65];
    return [self initWithUserLocation:location];
}

- (id)initWithUserLocation:(CLLocation *)location {
    if (self = [super init]) {
//        self.categories = [[NSMutableArray alloc] init];
//        [self.categories insertObject:[[NSMutableArray alloc] init] atIndex:0];
//        [self.categories insertObject:[[NSMutableArray alloc] init] atIndex:1];
//        [self.categories insertObject:[[NSMutableArray alloc] init] atIndex:2];
        self.userLocation = location;
    }
    return self;
}

//- (void)loadLocal {
//    self.allSections = 1;
//    self.allRows = [[NSMutableArray alloc] init];
//    self.allItems = [[NSMutableDictionary alloc] init];
//    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"catalog" ofType:@"txt"];
//    NSString *catalogStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//    
//    NSArray *items = [jsonParser objectWithString:catalogStr];
//    
//    int index = 0;
//    for (NSDictionary *item in items) {
//        CatalogItem *catalogItem = [[CatalogItem alloc] init];
//        catalogItem.ID = [[item objectForKey:@"id"] intValue];
//        catalogItem.name = [item objectForKey:@"name"];
//        catalogItem.type = [item objectForKey:@"type"];
//        catalogItem.cuisine = [item objectForKey:@"kitchen"];
//        catalogItem.weekdayHours = [item objectForKey:@"weekdays_hours"];
//        catalogItem.breakHours = [item objectForKey:@"break_hours"];
//        catalogItem.saturdayHours = [item objectForKey:@"saturday_hours"];
//        catalogItem.sundayHours = [item objectForKey:@"sunday_hours"];
//        catalogItem.phone = [item objectForKey:@"phone"];
//        catalogItem.website = [item objectForKey:@"site"];
//        catalogItem.bill = [[item objectForKey:@"check"] intValue];
//        catalogItem.description = [[item objectForKey:@"description"] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//        catalogItem.checkins = [[item objectForKey:@"checkins"] intValue];
//        catalogItem.address = [item objectForKey:@"address"];
//        CLLocationDegrees lat = [[item objectForKey:@"lat"] doubleValue];
//        CLLocationDegrees lng = [[item objectForKey:@"lng"] doubleValue];
//        catalogItem.location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
//        catalogItem.distance = [catalogItem.location distanceFromLocation:self.userLocation];
//
//        // Меню заведения
//        NSDictionary *menu = [item objectForKey:@"menu"];
//        if (menu.count) { 
//            MenuItem *menuItem = [[MenuItem alloc] init];
//            NSString *image = [menu objectForKey:@"image"];
//            if (!image) image = @"";
//            NSURL *imageUrl = [NSURL URLWithString:[kWEBSITE stringByAppendingString:image]];
//            menuItem.imageUrl = imageUrl;
//            //menuItem.image = [UIImage imageNamed:@"placeholder.png"];
//            menuItem.title = [menu objectForKey:@"title"];
//            menuItem.price = [[menu objectForKey:@"price"] floatValue];
//            [catalogItem.menu insertObject:menuItem atIndex:0];
//        }
//
//        // Отзывы
////        NSArray *feedbacks = [item objectForKey:@"feedbacks"];
////        int i = 0;
////        for (NSDictionary *feedback in feedbacks) {
////            Feedback *feedbackObj = [[Feedback alloc] init];
////            NSString *image = [feedback objectForKey:@"image"];
////            if (!image) image = @"";
////            NSURL *imageUrl = [NSURL URLWithString:[kWEBSITE stringByAppendingString:image]];
////            feedbackObj.imageUrl = imageUrl;
////            //feedbackObj.image = [UIImage imageNamed:@"placeholder.png"];
////            feedbackObj.user = [feedback objectForKey:@"user"];
////            feedbackObj.to = catalogItem.name;
////            feedbackObj.text = [feedback objectForKey:@"text"];
////            feedbackObj.attitude = [[feedback objectForKey:@"attitude"] intValue];
////            feedbackObj.date = [NSDate dateWithTimeIntervalSince1970:[[feedback objectForKey:@"date"] intValue]];
////            [catalogItem.feedbacks insertObject:feedbackObj atIndex:i];
////            i++;
////        }
//        
//        // События
////        NSArray *events = [item objectForKey:@"events"];
////        i = 0;
////        for (NSDictionary *event in events) {
////            Event *eventObj = [[Event alloc] init];
////            NSString *image = [event objectForKey:@"image"];
////            if (!image) image = @"";
////            NSURL *imageUrl = [NSURL URLWithString:[kWEBSITE stringByAppendingString:image]];
////            eventObj.imageUrl = imageUrl;
////            //eventObj.image = [UIImage imageNamed:@"placeholder.png"];
////            eventObj.user = [event objectForKey:@"user"];
////            eventObj.text = [[[[event objectForKey:@"text"] stringByStrippingHTML] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
////            eventObj.date = [NSDate dateWithTimeIntervalSince1970:[[event objectForKey:@"date"] intValue]];
////            [catalogItem.events insertObject:eventObj atIndex:i];
////            i++;
////        }
//      
//        // Фотки
//        NSArray *photosUrls = [item objectForKey:@"photos"];
//        int i = 0;
//        for (NSString *photoUrl in photosUrls) {
//            NSURL *url = [NSURL URLWithString:[kWEBSITE stringByAppendingString:photoUrl]];
//            [catalogItem.photosUrls insertObject:url atIndex:i++];
//        }
//        if (!catalogItem.photosUrls.count) {
//            [catalogItem.photosUrls addObject:@""];
//        }
//        
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index++ inSection:0];
//        [self.allItems setObject:catalogItem forKey:indexPath];
//        
//        //NSLog(@"Урлы фоток: %@", catalogItem.photosUrls.description);
//    }
//    
//    [self.allRows insertObject:[NSNumber numberWithInt:index] atIndex:0];
//}

- (void)getCatalogByDistance {
    self.allSections = 0;
    [self.allRows removeAllObjects];
    [self.allItems removeAllObjects];
    //int limit = 10;
    NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:@"catalog_by_distance", @"request", [NSNumber numberWithDouble:self.userLocation.coordinate.latitude], @"lat", [NSNumber numberWithDouble:self.userLocation.coordinate.longitude], @"lng", nil];
    
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:requestDict] forKey:@"jsonData"];
    //request.delegate = self;
    //request.didFinishSelector = @selector(didGetCatalogByDistance:);
    request.timeOutSeconds = kREQUEST_TIMEOUT;
    [request startSynchronous];
    
//    if (request.error) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"O_O" message:request.error.description delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
//        [alert show];
//        return;
//    }
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), requestDict.description);
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [jsonParser objectWithString:[request responseString]];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
    
    BOOL result = [[dict objectForKey:@"response"] boolValue];
    
    if (result) {
        self.allSections = 4;
        const int rowsCnt = 4;
        int rows[rowsCnt] = { };
        
        NSArray *catalog = [dict objectForKey:@"catalog"];
        //int row = 0;
        for (NSDictionary *company in catalog) {
            int ID = [[company objectForKey:@"id"] intValue];
            NSString *name = [company objectForKey:@"name"];
            NSString *address = [company objectForKey:@"address"];
            double distance = [[company objectForKey:@"distance"] doubleValue] * 1000;
            NSString *image = [company objectForKey:@"image"];
            
            int section;
            if (distance < 100) {
                section = 0;
            }
            else if (distance < 150) {
                section = 1;
            }
            else if (distance < 300) {
                section = 2;
            }
            else section = 3;
            
            CatalogItem *c = [[CatalogItem alloc] init];
            c.ID = ID;
            c.name = name;
            c.address = address;
            c.logo = [NSURL URLWithString:image relativeToURL:kWEBSITE_URL];
            c.distance = distance;
            c.checkinCount = [[company objectForKey:@"comments_count"] intValue];
            double lat = [[company objectForKey:@"lat"] doubleValue];
            double lng = [[company objectForKey:@"lng"] doubleValue];
            c.location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rows[section]++ inSection:section];
            [self.allItems setObject:c forKey:indexPath];
        }
        for (int i = 0; i < self.allSections; i++) {
            [self.allRows insertObject:[NSNumber numberWithInt:rows[i]] atIndex:i];
        }
    }
    self.searchString = @"";
}

- (void)getCatalogByName:(NSString *)name {
    
    self.allSections = 0;
    [self.allRows removeAllObjects];
    [self.allItems removeAllObjects];
    
    NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:@"catalog_by_name", @"request", [NSNumber numberWithDouble:self.userLocation.coordinate.latitude], @"lat", [NSNumber numberWithDouble:self.userLocation.coordinate.longitude], @"lng", name, @"name", nil];
    
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:requestDict] forKey:@"jsonData"];
    request.timeOutSeconds = kREQUEST_TIMEOUT;
    [request startSynchronous];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), requestDict.description);
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [jsonParser objectWithString:[request responseString]];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
    
    BOOL result = [[dict objectForKey:@"response"] boolValue];
    
    if (result) {
        self.allSections = 4;
        const int rowsCnt = 4;
        int rows[rowsCnt] = { };
        
        NSArray *catalog = [dict objectForKey:@"catalog"];
        //int row = 0;
        for (NSDictionary *company in catalog) {
            int ID = [[company objectForKey:@"id"] intValue];
            NSString *name = [company objectForKey:@"name"];
            NSString *address = [company objectForKey:@"address"];
            double distance = [[company objectForKey:@"distance"] doubleValue] * 1000;
            NSString *image = [company objectForKey:@"image"];
            
            int section;
            if (distance < 100) {
                section = 0;
            }
            else if (distance < 150) {
                section = 1;
            }
            else if (distance < 300) {
                section = 2;
            }
            else section = 3;
            
            CatalogItem *c = [[CatalogItem alloc] init];
            c.ID = ID;
            c.name = name;
            c.address = address;
            c.logo = [NSURL URLWithString:image relativeToURL:kWEBSITE_URL];
            c.distance = distance;
            //--------------------
            c.checkinCount = [[company objectForKey:@"comments_count"] intValue];
            //double lat = [[company objectForKey:@"lat"] doubleValue];
            //double lng = [[company objectForKey:@"lng"] doubleValue];
            //c.location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rows[section]++ inSection:section];
            [self.allItems setObject:c forKey:indexPath];
        }
        for (int i = 0; i < self.allSections; i++) {
            [self.allRows insertObject:[NSNumber numberWithInt:rows[i]] atIndex:i];
        }
    }
    self.searchString = @"";
}

//- (void)didGetCatalogByName:(ASIHTTPRequest *)request {
//    //self.searchString = self.tmp_name;
//    
//    SBJsonParser *parser = [[SBJsonParser alloc] init];
//    NSDictionary *dict = [parser objectWithString:[request responseString]];
//    
//    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_CATALOG_BY_NAME object:nil];
//}

//- (void)didGetCatalogByDistance:(ASIHTTPRequest *)request {
//    //NSLog(@"Loaded catalog by distance!");
//    
//    self.allSections = 3;
//    self.allRows = [NSMutableArray arrayWithCapacity:self.allSections];
//    self.allItems = [NSMutableDictionary dictionary];
//    
//    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//    NSArray *catalog = [jsonParser objectWithString:[request responseString]];
//    
//    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), catalog.description);
//    
//    //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:[request responseString] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
//    //[alertView show];
//    //return;
//    //BOOL response = 
//    
//    const int rowsCnt = 3;
//    int rows[rowsCnt] = { };
//    self.counter = 0;
//    
//    for (int i = 0; i < catalog.count; i++)
//    {
//        NSDictionary *item = [catalog objectAtIndex:i];
//        
//        //NSLog(@"%@", item.description);
//        
//        int ID = [[item objectForKey:@"id"] intValue];
//        NSString *name = [item objectForKey:@"name"];
//        NSString *address = [item objectForKey:@"address"];
//        int distance = [[item objectForKey:@"distance"] doubleValue] * 1000;
//        NSString *image = [item objectForKey:@"image"];
//        if (!image) image = @"";
//        NSString *imageUrl =  [kWEBSITE stringByAppendingPathComponent:image];
//        
//        int section;
//        if (distance < 100) {
//            section = 0;
//        }
//        else if (distance < 150) {
//            section = 1;
//        }
//        else {//if (distance < 200) {
//            section = 2;
//        }
////        else {
////            continue;
////        }
//        
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rows[section]++ inSection:section];
//        self.counter++;
//        
//        CatalogItem *catalogItem = [[CatalogItem alloc] init];
//        catalogItem.ID = ID;
//        catalogItem.name = name;
//        catalogItem.address = address;
//        //[catalogItem.photos addObject:[UIImage imageNamed:@"placeholder.png"]];
//        //[catalogItem.photosUrls addObject:imageUrl];
//        catalogItem.distance = distance;
//        [self.allItems setObject:catalogItem forKey:indexPath];
//
//        //[SDWebImageDownloader downloaderWithURL:[NSURL URLWithString:image] delegate:self userInfo:indexPath];
//    }
//
//    for (int i = 0; i < self.allSections; i++) {
//        [self.allRows insertObject:[NSNumber numberWithInt:rows[i]] atIndex:i];
//    }
//    
//    if (1) { //!self.counter
//        self.searchString = self.searchString;
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_CATALOG_BY_DISTANCE object:nil];
//    }
//    
//}

//- (void)imageDownloader:(SDWebImageDownloader *)downloader didFinishWithImage:(UIImage *)image {
//    if (!image) { image = [UIImage imageNamed:@"placeholder.png"]; }
//    
//    NSIndexPath *indexPath = downloader.userInfo;
//    CatalogItem *item = [self.allItems objectForKey:indexPath];
//    //item.thumbnail = [image thumbnailByScalingProportionallyAndCroppingToSize:CGSizeMake(81, 81)];
//    
//    if (--self.counter == 0) {
//        self.searchString = self.searchString;
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"didGetCatalogByDistance" object:nil];
//    }
//}

- (void)setSearchString:(NSString *)searchString {
    _searchString = searchString;
    
    if (!self.searchString.length) {
        self.sections = self.allSections;
        self.rows = self.allRows;
        self.items = self.allItems;
    }
    else {
        self.sections = 1;
        int cnt = 0;
        self.items = [NSMutableDictionary dictionary];
        
        for (CatalogItem *item in self.allItems.allValues) {
            if ([item.name rangeOfString:self.searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cnt++ inSection:0];
                [self.items setObject:item forKey:indexPath];
            }
        }
        
        self.rows = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:cnt]];
    }
}

- (NSArray *)getTypes {
    NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:@"catalog_types", @"request", nil];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:requestDict] forKey:@"jsonData"];
    request.delegate = self;
    request.didFinishSelector = @selector(didGetTypes:);
    [request startSynchronous];
    
    NSLog(@"Отправил запрос типов заведений: %@", requestDict.description);
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [jsonParser objectWithString:[request responseString]];
    NSArray *types = [dict objectForKey:@"types"];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    BOOL response = [[dict objectForKey:@"response"] boolValue];
    if (response) {
        for (NSDictionary *type in types) {
            NSDictionary *idDict = [type objectForKey:@"id"];
            NSString *ID = [idDict objectForKey:@"$id"];
            NSString *name = [type objectForKey:@"name"];
            UIImage *image;
            
            if ([name isEqualToString:@"Бары"]) {
                image = [UIImage imageNamed:@"bars.png"];
            }
            else if ([name isEqualToString:@"Блинные"]) {
                image = [UIImage imageNamed:@"blin.png"];
            }
            else if ([name isEqualToString:@"Кафе"]) {
                image = [UIImage imageNamed:@"cafe.png"];
            }
            else if ([name isEqualToString:@"Кофейни"]) {
                image = [UIImage imageNamed:@"coffee.png"];
            }
            else if ([name isEqualToString:@"Кондитерские"]) {
                image = [UIImage imageNamed:@"conditer.png"];
            }
            else if ([name isEqualToString:@"Кулинария"]) {
                image = [UIImage imageNamed:@"kulinaria.png"];
            }
            else if ([name isEqualToString:@"Пекарня"]) {
                image = [UIImage imageNamed:@"pekar.png"];
            }
            else if ([name isEqualToString:@"Пиццерии"]) {
                image = [UIImage imageNamed:@"pizza.png"];
            }
            else if ([name isEqualToString:@"Рестораны"]) {
                image = [UIImage imageNamed:@"restaurants.png"];
            }
            else if ([name isEqualToString:@"Столовые"]) {
                image = [UIImage imageNamed:@"stolovie.png"];
            }
            else if ([name isEqualToString:@"Фаст-фуды"]) {
                image = [UIImage imageNamed:@"fastfood.png"];
            }
            
            NSDictionary *t = [NSDictionary dictionaryWithObjectsAndKeys:ID, @"id", name, @"name", image, @"image", [NSNumber numberWithInt:0], @"index", nil];
            [result addObject:t];
        }    
    }
    return result;
}

//- (void)didGetTypes:(ASIHTTPRequest *)request {
//    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//    NSDictionary *responceDict = [jsonParser objectWithString:[request responseString]];
//    NSArray *array = [responceDict objectForKey:@"catalog"];
//    
//    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), responceDict.description);
//    
//    [self.categories insertObject:[NSMutableArray arrayWithCapacity:array.count] atIndex:0];
//    
//    for (int i = 0; i < array.count; i++) {
//        NSDictionary *dict = [array objectAtIndex:i];
//        NSDictionary *idDict = [dict objectForKey:@"id"];
//        NSString *ID = [idDict objectForKey:@"$id"];
//        NSString *name = [dict objectForKey:@"name"];
//        
//        CatalogCategory *catalogCategory = [[CatalogCategory alloc] init];
//        catalogCategory.ID = ID;
//        catalogCategory.name = name;
//        catalogCategory.index = 0;
//        
//        if ([catalogCategory.name isEqualToString:@"Бары"]) {
//            catalogCategory.image = [UIImage imageNamed:@"bars.png"];
//        }
//        else if ([catalogCategory.name isEqualToString:@"Блинные"]) {
//            catalogCategory.image = [UIImage imageNamed:@"blin.png"];
//        }
//        else if ([catalogCategory.name isEqualToString:@"Кафе"]) {
//            catalogCategory.image = [UIImage imageNamed:@"cafe.png"];
//        }
//        else if ([catalogCategory.name isEqualToString:@"Кофейни"]) {
//            catalogCategory.image = [UIImage imageNamed:@"coffee.png"];
//        }
//        else if ([catalogCategory.name isEqualToString:@"Кондитерские"]) {
//            catalogCategory.image = [UIImage imageNamed:@"conditer.png"];
//        }
//        else if ([catalogCategory.name isEqualToString:@"Кулинария"]) {
//            catalogCategory.image = [UIImage imageNamed:@"kulinaria.png"];
//        }
//        else if ([catalogCategory.name isEqualToString:@"Пекарня"]) {
//            catalogCategory.image = [UIImage imageNamed:@"pekar.png"];
//        }
//        else if ([catalogCategory.name isEqualToString:@"Пиццерии"]) {
//            catalogCategory.image = [UIImage imageNamed:@"pizza.png"];
//        }
//        else if ([catalogCategory.name isEqualToString:@"Рестораны"]) {
//            catalogCategory.image = [UIImage imageNamed:@"restaurants.png"];
//        }
//        else if ([catalogCategory.name isEqualToString:@"Столовые"]) {
//            catalogCategory.image = [UIImage imageNamed:@"stolovie.png"];
//        }
//        else if ([catalogCategory.name isEqualToString:@"Фаст-фуды"]) {
//            catalogCategory.image = [UIImage imageNamed:@"fastfood.png"];
//        }
//        
//        [[self.categories objectAtIndex:0] insertObject:catalogCategory atIndex:i];
//    }    
//    
//    NSLog(@"Получил типы заведений: %@", responceDict.description);
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_CATALOG_TYPES object:nil];
//}

- (NSArray *)getCuisines {
    NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:@"catalog_cuisines", @"request", nil];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:requestDict] forKey:@"jsonData"];
    request.delegate = self;
    request.didFinishSelector = @selector(didGetCuisines:);
    [request startSynchronous];
    
    NSLog(@"Отправил запрос типов кухонь: %@", requestDict.description);
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [jsonParser objectWithString:[request responseString]];
    NSArray *cuisines = [dict objectForKey:@"cuisines"];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
    
    //if (array.count) { self.cuisineTypes = [NSMutableArray array]; }
    //[self.categories insertObject:[NSMutableArray arrayWithCapacity:array.count] atIndex:1];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    BOOL response = [[dict objectForKey:@"response"] boolValue];
    if (response) {
        for (NSDictionary *cuisine in cuisines) {
            //NSDictionary *dict = [array objectAtIndex:i];
            //NSDictionary *idDict = [dict objectForKey:@"id"];
            //NSString *ID = [idDict objectForKey:@"$id"];
            //int ID = [[dict objectForKey:@"id"] intValue];
            NSString *ID = [cuisine objectForKey:@"id"];
            NSString *name = [cuisine objectForKey:@"name"];
            UIImage *image;
            
    //        CatalogCategory *catalogType = [[CatalogCategory alloc] init];
    //        catalogType.ID = ID;
    //        catalogType.name = name;
    //        catalogType.index = 1;
            
            if ([name isEqualToString:@"американская"]) {
                image = [UIImage imageNamed:@"american.png"];
            }
            else if ([name isEqualToString:@"восточная"]) {
                image = [UIImage imageNamed:@"east.png"];
            }
            else if ([name isEqualToString:@"итальянская"]) {
                image = [UIImage imageNamed:@"italian.png"];
            }
            else if ([name isEqualToString:@"японская"]) {
                image = [UIImage imageNamed:@"japan.png"];
            }
            else if ([name isEqualToString:@"мексиканская"]) {
                image = [UIImage imageNamed:@"mexican.png"];
            }
            else if ([name isEqualToString:@"китайская"]) {
                image = [UIImage imageNamed:@"china.png"];
            }
            else if ([name isEqualToString:@"европейская"]) {
                image = [UIImage imageNamed:@"europe.png"];
            }
            else if ([name isEqualToString:@"фьюжн"]) {
                image = [UIImage imageNamed:@"fusion.png"];
            }
            else if ([name isEqualToString:@"интернациональная"]) {
                image = [UIImage imageNamed:@"international.png"];
            }
            else if ([name isEqualToString:@"кавказская"]) {
                image = [UIImage imageNamed:@"kavkaz.png"];
            }
            else if ([name isEqualToString:@"русская"]) {
                image = [UIImage imageNamed:@"russian.png"];
            }
            else if ([name isEqualToString:@"украинская"]) {
                image = [UIImage imageNamed:@"ukraine.png"];
            }
            else if ([name isEqualToString:@"узбекская"]) {
                image = [UIImage imageNamed:@"uzbek.png"];
            }
            else if ([name isEqualToString:@"китайская"]) {
                image = [UIImage imageNamed:@"china.png"];
            }
            else if ([name isEqualToString:@"татарская"]) {
                image = [UIImage imageNamed:@"tatar.png"];
            }
            name = [name capitalizedString];
            NSDictionary *c = [NSDictionary dictionaryWithObjectsAndKeys:ID, @"id", name, @"name", image, @"image", [NSNumber numberWithInt:1], @"index", nil];
            [result addObject:c];
            //[[self.categories objectAtIndex:1] insertObject:catalogType atIndex:i];
        } 
    }
    return result;
}

//- (void)didGetCuisines:(ASIHTTPRequest *)request {
//    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//    NSDictionary *responceDict = [jsonParser objectWithString:[request responseString]];
//    NSArray *array = [responceDict objectForKey:@"catalog"];
//    
//    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), responceDict.description);
//    
//    //if (array.count) { self.cuisineTypes = [NSMutableArray array]; }
//    [self.categories insertObject:[NSMutableArray arrayWithCapacity:array.count] atIndex:1];
//    
//    for (int i = 0; i < array.count; i++) {
//        NSDictionary *dict = [array objectAtIndex:i];
//        //NSDictionary *idDict = [dict objectForKey:@"id"];
//        //NSString *ID = [idDict objectForKey:@"$id"];
//        //int ID = [[dict objectForKey:@"id"] intValue];
//        NSString *ID = [dict objectForKey:@"id"];
//        NSString *name = [dict objectForKey:@"name"];
//        
//        CatalogCategory *catalogType = [[CatalogCategory alloc] init];
//        catalogType.ID = ID;
//        catalogType.name = name;
//        catalogType.index = 1;
//        
//        if ([catalogType.name isEqualToString:@"американская"]) {
//            catalogType.image = [UIImage imageNamed:@"american.png"];
//        }
//        else if ([catalogType.name isEqualToString:@"восточная"]) {
//            catalogType.image = [UIImage imageNamed:@"east.png"];
//        }
//        else if ([catalogType.name isEqualToString:@"итальянская"]) {
//            catalogType.image = [UIImage imageNamed:@"italian.png"];
//        }
//        else if ([catalogType.name isEqualToString:@"японская"]) {
//            catalogType.image = [UIImage imageNamed:@"japan.png"];
//        }
//        else if ([catalogType.name isEqualToString:@"мексиканская"]) {
//            catalogType.image = [UIImage imageNamed:@"mexican.png"];
//        }
//        else if ([catalogType.name isEqualToString:@"китайская"]) {
//            catalogType.image = [UIImage imageNamed:@"china.png"];
//        }
//        else if ([catalogType.name isEqualToString:@"европейская"]) {
//            catalogType.image = [UIImage imageNamed:@"europe.png"];
//        }
//        else if ([catalogType.name isEqualToString:@"фьюжн"]) {
//            catalogType.image = [UIImage imageNamed:@"fusion.png"];
//        }
//        else if ([catalogType.name isEqualToString:@"интернациональная"]) {
//            catalogType.image = [UIImage imageNamed:@"international.png"];
//        }
//        else if ([catalogType.name isEqualToString:@"кавказская"]) {
//            catalogType.image = [UIImage imageNamed:@"kavkaz.png"];
//        }
//        else if ([catalogType.name isEqualToString:@"русская"]) {
//            catalogType.image = [UIImage imageNamed:@"russian.png"];
//        }
//        else if ([catalogType.name isEqualToString:@"украинская"]) {
//            catalogType.image = [UIImage imageNamed:@"ukraine.png"];
//        }
//        else if ([catalogType.name isEqualToString:@"узбекская"]) {
//            catalogType.image = [UIImage imageNamed:@"uzbek.png"];
//        }
//        else if ([catalogType.name isEqualToString:@"китайская"]) {
//            catalogType.image = [UIImage imageNamed:@"china.png"];
//        }
//        else if ([catalogType.name isEqualToString:@"татарская"]) {
//            catalogType.image = [UIImage imageNamed:@"tatar.png"];
//        }
//        
//        [[self.categories objectAtIndex:1] insertObject:catalogType atIndex:i];
//    }    
//    
//    NSLog(@"Получил типы кухонь: %@", responceDict.description);
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_CATALOG_CUISINES object:nil];
//}

- (NSArray *)getBills {
    //[self.categories insertObject:[NSMutableArray arrayWithCapacity:7] atIndex:2];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSDictionary *bill = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2], @"index", @"< 500", @"name", [NSNumber numberWithInt:0], @"from", [NSNumber numberWithInt:500], @"to", [UIImage imageNamed:@"500.png"], @"image", nil];
    [result addObject:bill];
    bill = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2], @"index", @"500-700", @"name", [NSNumber numberWithInt:500], @"from", [NSNumber numberWithInt:700], @"to", [UIImage imageNamed:@"500-700.png"], @"image", nil];
    [result addObject:bill];
    bill = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2], @"index", @"700-1000", @"name", [NSNumber numberWithInt:700], @"from", [NSNumber numberWithInt:1000], @"to", [UIImage imageNamed:@"700-1000.png"], @"image", nil];
    [result addObject:bill];
    bill = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2], @"index", @"1000-1500", @"name", [NSNumber numberWithInt:1000], @"from", [NSNumber numberWithInt:1500], @"to", [UIImage imageNamed:@"1000-1500.png"], @"image", nil];
    [result addObject:bill];
    bill = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2], @"index", @"1500-2000", @"name", [NSNumber numberWithInt:1500], @"from", [NSNumber numberWithInt:2000], @"to", [UIImage imageNamed:@"1500-2000.png"], @"image", nil];
    [result addObject:bill];
    bill = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2], @"index", @"2000-3000", @"name", [NSNumber numberWithInt:2000], @"from", [NSNumber numberWithInt:3000], @"to", [UIImage imageNamed:@"2000-3000.png"], @"image", nil];
    [result addObject:bill];
    bill = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2], @"index", @"> 3000", @"name", [NSNumber numberWithInt:3000], @"from", [NSNumber numberWithInt:99999], @"to", [UIImage imageNamed:@"3000.png"], @"image", nil];
    [result addObject:bill];
    
//    CatalogCategory *type = [[CatalogCategory alloc] init];
//    type.index = 2;
//    type.name = @"< 500";
//    type.from = 0;
//    type.to = 500;
//    type.image = [UIImage imageNamed:@"500.png"];
//    [[self.categories objectAtIndex:2] insertObject:type atIndex:0];
//    type = [[CatalogCategory alloc] init];
//    type.index = 2;
//    type.name = @"500-700";
//    type.from = 500;
//    type.to = 700;
//    type.image = [UIImage imageNamed:@"500-700.png"];
//    [[self.categories objectAtIndex:2] insertObject:type atIndex:1];
//    type = [[CatalogCategory alloc] init];
//    type.index = 2;
//    type.name = @"700-1000";
//    type.from = 700;
//    type.to = 1000;
//    type.image = [UIImage imageNamed:@"700-1000.png"];
//    [[self.categories objectAtIndex:2] insertObject:type atIndex:2];
//    type = [[CatalogCategory alloc] init];
//    type.index = 2;
//    type.name = @"1000-1500";
//    type.from = 1000;
//    type.to = 1500;
//    type.image = [UIImage imageNamed:@"1000-1500.png"];
//    [[self.categories objectAtIndex:2] insertObject:type atIndex:3];
//    type = [[CatalogCategory alloc] init];
//    type.index = 2;
//    type.name = @"1500-2000";
//    type.from = 1500;
//    type.to = 2000;
//    type.image = [UIImage imageNamed:@"1500-2000.png"];
//    [[self.categories objectAtIndex:2] insertObject:type atIndex:4];
//    type = [[CatalogCategory alloc] init];
//    type.index = 2;
//    type.name = @"2000-3000";
//    type.from = 2000;
//    type.to = 3000;
//    type.image = [UIImage imageNamed:@"2000-3000.png"];
//    [[self.categories objectAtIndex:2] insertObject:type atIndex:5];
//    type = [[CatalogCategory alloc] init];
//    type.index = 2;
//    type.name = @"> 3000";
//    type.from = 3000;
//    type.to = 99999;
//    type.image = [UIImage imageNamed:@"3000.png"];
//    [[self.categories objectAtIndex:2] insertObject:type atIndex:6];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_CATALOG_BILLS object:nil];
    return result;
}

- (void)getCatalogByCategory:(NSDictionary *)category { 
    self.allSections = 0;
    [self.allRows removeAllObjects];
    [self.allItems removeAllObjects];
    
    NSString *requestValue;
    switch ([[category objectForKey:@"index"] intValue]) {
        case 0: requestValue = @"catalog_by_type"; break;
        case 1: requestValue = @"catalog_by_cuisine"; break;
        case 2: requestValue = @"catalog_by_bill"; break;
    }
    NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:requestValue, @"request", [NSNumber numberWithDouble:self.userLocation.coordinate.latitude], @"lat", [NSNumber numberWithDouble:self.userLocation.coordinate.longitude], @"lng", [category objectForKey:@"id"], @"id", nil];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), requestDict);
    
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:requestDict] forKey:@"jsonData"];
    request.timeOutSeconds = kREQUEST_TIMEOUT;
    [request startSynchronous];
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:request.responseString];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict);
    
    BOOL response = [[dict objectForKey:@"response"] boolValue];
    if (response) {
        self.allSections = 1;
        [self.allRows removeAllObjects];
        [self.allItems removeAllObjects];
        int row = 0;
        NSArray *catalog = [dict objectForKey:@"catalog"];
        for (NSDictionary *company in catalog) {
            CatalogItem *c = [[CatalogItem alloc] init];
            c.ID = [[company objectForKey:@"id"] intValue];
            c.name = [company objectForKey:@"name"];
            c.address = [company objectForKey:@"address"];
            c.checkinCount = [[company objectForKey:@"comments_count"] intValue];
            c.distance = [[company objectForKey:@"distance"] doubleValue] * 1000;
            c.type = [category objectForKey:@"name"];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row++ inSection:0];
            [self.allItems setObject:c forKey:indexPath];
        }
        [self.allRows addObject:[NSNumber numberWithInt:row]];
    }
    self.searchString = @"";
}

@end

 