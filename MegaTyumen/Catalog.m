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
@property (nonatomic) int counter;
@property (nonatomic, strong) NSString *tmp_name;
@property (nonatomic, strong) CatalogCategory *requeiredCategory;
@property (nonatomic, unsafe_unretained) CLLocation *userLocation;
- (void)didGetCatalogByDistance:(ASIHTTPRequest *)request;
- (void)didGetTypes:(ASIHTTPRequest *)request;
- (void)didGetCuisines:(ASIHTTPRequest *)request;
- (void)loadLocal;
- (void)didGetCatalogByCategory:(ASIHTTPRequest *)request;
- (void)didGetCatalogByName:(ASIHTTPRequest *)request;
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
@synthesize counter = _counter;
@synthesize tmp_name = _tmp_name;
@synthesize requeiredCategory = _requeiredCategory;
@synthesize userLocation = _userLocation;

- (id)init {
    return [self initWithUserLocation:nil];
}

- (id)initWithUserLocation:(CLLocation *)location {
    if (self = [super init]) {
        self.categories = [[NSMutableArray alloc] init];
        [self.categories insertObject:[[NSMutableArray alloc] init] atIndex:0];
        [self.categories insertObject:[[NSMutableArray alloc] init] atIndex:1];
        [self.categories insertObject:[[NSMutableArray alloc] init] atIndex:2];
        
        self.allItems = [[NSMutableDictionary alloc] init];
        self.items = [[NSMutableDictionary alloc] init];
        self.allRows = [[NSMutableArray alloc] init];
        self.rows = [[NSMutableArray alloc] init];
        
        self.userLocation = location;
        
        [self loadLocal];
    }
    return self;
}

- (void)loadLocal {
    self.allSections = 1;
    self.allRows = [[NSMutableArray alloc] init];
    self.allItems = [[NSMutableDictionary alloc] init];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"catalog" ofType:@"txt"];
    NSString *catalogStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    
    NSArray *items = [jsonParser objectWithString:catalogStr];
    
    int index = 0;
    for (NSDictionary *item in items) {
        CatalogItem *catalogItem = [[CatalogItem alloc] init];
        catalogItem.ID = [[item objectForKey:@"id"] intValue];
        catalogItem.name = [item objectForKey:@"name"];
        catalogItem.type = [item objectForKey:@"type"];
        catalogItem.cuisine = [item objectForKey:@"kitchen"];
        catalogItem.weekdayHours = [item objectForKey:@"weekdays_hours"];
        catalogItem.breakHours = [item objectForKey:@"break_hours"];
        catalogItem.saturdayHours = [item objectForKey:@"saturday_hours"];
        catalogItem.sundayHours = [item objectForKey:@"sunday_hours"];
        catalogItem.phone = [item objectForKey:@"phone"];
        catalogItem.website = [item objectForKey:@"site"];
        catalogItem.bill = [[item objectForKey:@"check"] intValue];
        catalogItem.description = [[item objectForKey:@"description"] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        catalogItem.checkins = [[item objectForKey:@"checkins"] intValue];
        catalogItem.address = [item objectForKey:@"address"];
        CLLocationDegrees lat = [[item objectForKey:@"lat"] doubleValue];
        CLLocationDegrees lng = [[item objectForKey:@"lng"] doubleValue];
        catalogItem.location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
        catalogItem.distance = [catalogItem.location distanceFromLocation:self.userLocation];

        // Меню заведения
        NSDictionary *menu = [item objectForKey:@"menu"];
        if (menu.count) { 
            MenuItem *menuItem = [[MenuItem alloc] init];
            NSString *image = [menu objectForKey:@"image"];
            if (!image) image = @"";
            NSURL *imageUrl = [NSURL URLWithString:[kWEBSITE stringByAppendingString:image]];
            menuItem.imageUrl = imageUrl;
            //menuItem.image = [UIImage imageNamed:@"placeholder.png"];
            menuItem.title = [menu objectForKey:@"title"];
            menuItem.price = [[menu objectForKey:@"price"] floatValue];
            [catalogItem.menu insertObject:menuItem atIndex:0];
        }

        // Отзывы
//        NSArray *feedbacks = [item objectForKey:@"feedbacks"];
//        int i = 0;
//        for (NSDictionary *feedback in feedbacks) {
//            Feedback *feedbackObj = [[Feedback alloc] init];
//            NSString *image = [feedback objectForKey:@"image"];
//            if (!image) image = @"";
//            NSURL *imageUrl = [NSURL URLWithString:[kWEBSITE stringByAppendingString:image]];
//            feedbackObj.imageUrl = imageUrl;
//            //feedbackObj.image = [UIImage imageNamed:@"placeholder.png"];
//            feedbackObj.user = [feedback objectForKey:@"user"];
//            feedbackObj.to = catalogItem.name;
//            feedbackObj.text = [feedback objectForKey:@"text"];
//            feedbackObj.attitude = [[feedback objectForKey:@"attitude"] intValue];
//            feedbackObj.date = [NSDate dateWithTimeIntervalSince1970:[[feedback objectForKey:@"date"] intValue]];
//            [catalogItem.feedbacks insertObject:feedbackObj atIndex:i];
//            i++;
//        }
        
        // События
//        NSArray *events = [item objectForKey:@"events"];
//        i = 0;
//        for (NSDictionary *event in events) {
//            Event *eventObj = [[Event alloc] init];
//            NSString *image = [event objectForKey:@"image"];
//            if (!image) image = @"";
//            NSURL *imageUrl = [NSURL URLWithString:[kWEBSITE stringByAppendingString:image]];
//            eventObj.imageUrl = imageUrl;
//            //eventObj.image = [UIImage imageNamed:@"placeholder.png"];
//            eventObj.user = [event objectForKey:@"user"];
//            eventObj.text = [[[[event objectForKey:@"text"] stringByStrippingHTML] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\t" withString:@""];
//            eventObj.date = [NSDate dateWithTimeIntervalSince1970:[[event objectForKey:@"date"] intValue]];
//            [catalogItem.events insertObject:eventObj atIndex:i];
//            i++;
//        }
      
        // Фотки
        NSArray *photosUrls = [item objectForKey:@"photos"];
        int i = 0;
        for (NSString *photoUrl in photosUrls) {
            NSURL *url = [NSURL URLWithString:[kWEBSITE stringByAppendingString:photoUrl]];
            [catalogItem.photosUrls insertObject:url atIndex:i++];
        }
        if (!catalogItem.photosUrls.count) {
            [catalogItem.photosUrls addObject:@""];
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index++ inSection:0];
        [self.allItems setObject:catalogItem forKey:indexPath];
        
        //NSLog(@"Урлы фоток: %@", catalogItem.photosUrls.description);
    }
    
    [self.allRows insertObject:[NSNumber numberWithInt:index] atIndex:0];
}

- (void)getCatalogByDistanceWithLat:(double)lat andLng:(double)lng {
    //lng = 57.07288; lat = 65.33060;
    NSString *lat_ = [NSString stringWithFormat:@"%lf", lat];
    NSString *lng_ = [NSString stringWithFormat:@"%lf", lng];
    NSString *tmp = lat_;
    lat_ = lng_;
    lng_ = tmp;
    NSString *token = [Authorization sharedAuthorization].token;
    
    NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:@"catalog_by_distance", @"request", lat_, @"lat", lng_, @"lng", token, @"token", nil];
    
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:requestDict] forKey:@"jsonData"];
    request.delegate = self;
    request.didFinishSelector = @selector(didGetCatalogByDistance:);
    [request startAsynchronous];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), requestDict.description);
}

- (void)didGetCatalogByDistance:(ASIHTTPRequest *)request {
    //NSLog(@"Loaded catalog by distance!");
    
    self.allSections = 3;
    self.allRows = [NSMutableArray arrayWithCapacity:self.allSections];
    self.allItems = [NSMutableDictionary dictionary];
    
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSArray *catalog = [jsonParser objectWithString:[request responseString]];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), catalog.description);
    
    //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:[request responseString] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    //[alertView show];
    //return;
    //BOOL response = 
    
    const int rowsCnt = 3;
    int rows[rowsCnt] = { };
    self.counter = 0;
    
    for (int i = 0; i < catalog.count; i++)
    {
        NSDictionary *item = [catalog objectAtIndex:i];
        
        //NSLog(@"%@", item.description);
        
        int ID = [[item objectForKey:@"id"] intValue];
        NSString *name = [item objectForKey:@"name"];
        NSString *address = [item objectForKey:@"address"];
        int distance = [[item objectForKey:@"distance"] doubleValue] * 1000;
        NSString *image = [item objectForKey:@"image"];
        if (!image) image = @"";
        NSString *imageUrl =  [kWEBSITE stringByAppendingPathComponent:image];
        
        int section;
        if (distance < 100) {
            section = 0;
        }
        else if (distance < 150) {
            section = 1;
        }
        else {//if (distance < 200) {
            section = 2;
        }
//        else {
//            continue;
//        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rows[section]++ inSection:section];
        self.counter++;
        
        CatalogItem *catalogItem = [[CatalogItem alloc] init];
        catalogItem.ID = ID;
        catalogItem.name = name;
        catalogItem.address = address;
        //[catalogItem.photos addObject:[UIImage imageNamed:@"placeholder.png"]];
        [catalogItem.photosUrls addObject:imageUrl];
        catalogItem.distance = distance;
        [self.allItems setObject:catalogItem forKey:indexPath];

        //[SDWebImageDownloader downloaderWithURL:[NSURL URLWithString:image] delegate:self userInfo:indexPath];
    }

    for (int i = 0; i < self.allSections; i++) {
        [self.allRows insertObject:[NSNumber numberWithInt:rows[i]] atIndex:i];
    }
    
    if (1) { //!self.counter
        self.searchString = self.searchString;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_CATALOG_BY_DISTANCE object:nil];
    }
    
}

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

- (void)getTypes {
    NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:@"catalog_types", @"request", nil];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:requestDict] forKey:@"jsonData"];
    request.delegate = self;
    request.didFinishSelector = @selector(didGetTypes:);
    [request startAsynchronous];
    
    NSLog(@"Отправил запрос типов заведений: %@", requestDict.description);
}

- (void)didGetTypes:(ASIHTTPRequest *)request {
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *responceDict = [jsonParser objectWithString:[request responseString]];
    NSArray *array = [responceDict objectForKey:@"catalog"];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), responceDict.description);
    
    [self.categories insertObject:[NSMutableArray arrayWithCapacity:array.count] atIndex:0];
    
    for (int i = 0; i < array.count; i++) {
        NSDictionary *dict = [array objectAtIndex:i];
        NSDictionary *idDict = [dict objectForKey:@"id"];
        NSString *ID = [idDict objectForKey:@"$id"];
        NSString *name = [dict objectForKey:@"name"];
        
        CatalogCategory *catalogCategory = [[CatalogCategory alloc] init];
        catalogCategory.ID = ID;
        catalogCategory.name = name;
        catalogCategory.index = 0;
        
        if ([catalogCategory.name isEqualToString:@"Бары"]) {
            catalogCategory.image = [UIImage imageNamed:@"bars.png"];
        }
        else if ([catalogCategory.name isEqualToString:@"Блинные"]) {
            catalogCategory.image = [UIImage imageNamed:@"blin.png"];
        }
        else if ([catalogCategory.name isEqualToString:@"Кафе"]) {
            catalogCategory.image = [UIImage imageNamed:@"cafe.png"];
        }
        else if ([catalogCategory.name isEqualToString:@"Кофейни"]) {
            catalogCategory.image = [UIImage imageNamed:@"coffee.png"];
        }
        else if ([catalogCategory.name isEqualToString:@"Кондитерские"]) {
            catalogCategory.image = [UIImage imageNamed:@"conditer.png"];
        }
        else if ([catalogCategory.name isEqualToString:@"Кулинарии"]) {
            catalogCategory.image = [UIImage imageNamed:@"kulinaria.png"];
        }
        else if ([catalogCategory.name isEqualToString:@"Пекарни"]) {
            catalogCategory.image = [UIImage imageNamed:@"pekar.png"];
        }
        else if ([catalogCategory.name isEqualToString:@"Пиццерии"]) {
            catalogCategory.image = [UIImage imageNamed:@"pizza.png"];
        }
        else if ([catalogCategory.name isEqualToString:@"Рестораны"]) {
            catalogCategory.image = [UIImage imageNamed:@"restaurants.png"];
        }
        else if ([catalogCategory.name isEqualToString:@"Столовые"]) {
            catalogCategory.image = [UIImage imageNamed:@"stolovie.png"];
        }
        else if ([catalogCategory.name isEqualToString:@"Фаст-фуды"]) {
            catalogCategory.image = [UIImage imageNamed:@"fastfood.png"];
        }
        
        [[self.categories objectAtIndex:0] insertObject:catalogCategory atIndex:i];
    }    
    
    NSLog(@"Получил типы заведений: %@", responceDict.description);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_CATALOG_TYPES object:nil];
}

- (void)getCuisines {
    NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:@"catalog_cuisines", @"request", nil];
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:requestDict] forKey:@"jsonData"];
    request.delegate = self;
    request.didFinishSelector = @selector(didGetCuisines:);
    [request startAsynchronous];
    
    NSLog(@"Отправил запрос типов кухонь: %@", requestDict.description);
}

- (void)didGetCuisines:(ASIHTTPRequest *)request {
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSDictionary *responceDict = [jsonParser objectWithString:[request responseString]];
    NSArray *array = [responceDict objectForKey:@"catalog"];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), responceDict.description);
    
    //if (array.count) { self.cuisineTypes = [NSMutableArray array]; }
    [self.categories insertObject:[NSMutableArray arrayWithCapacity:array.count] atIndex:1];
    
    for (int i = 0; i < array.count; i++) {
        NSDictionary *dict = [array objectAtIndex:i];
        //NSDictionary *idDict = [dict objectForKey:@"id"];
        //NSString *ID = [idDict objectForKey:@"$id"];
        //int ID = [[dict objectForKey:@"id"] intValue];
        NSString *ID = [dict objectForKey:@"id"];
        NSString *name = [dict objectForKey:@"name"];
        
        CatalogCategory *catalogType = [[CatalogCategory alloc] init];
        catalogType.ID = ID;
        catalogType.name = name;
        catalogType.index = 1;
        
        if ([catalogType.name isEqualToString:@"американская"]) {
            catalogType.image = [UIImage imageNamed:@"american.png"];
        }
        else if ([catalogType.name isEqualToString:@"восточная"]) {
            catalogType.image = [UIImage imageNamed:@"east.png"];
        }
        else if ([catalogType.name isEqualToString:@"итальянская"]) {
            catalogType.image = [UIImage imageNamed:@"italian.png"];
        }
        else if ([catalogType.name isEqualToString:@"японская"]) {
            catalogType.image = [UIImage imageNamed:@"japan.png"];
        }
        else if ([catalogType.name isEqualToString:@"мексиканская"]) {
            catalogType.image = [UIImage imageNamed:@"mexican.png"];
        }
        else if ([catalogType.name isEqualToString:@"китайская"]) {
            catalogType.image = [UIImage imageNamed:@"china.png"];
        }
        else if ([catalogType.name isEqualToString:@"европейская"]) {
            catalogType.image = [UIImage imageNamed:@"europe.png"];
        }
        else if ([catalogType.name isEqualToString:@"фьюжн"]) {
            catalogType.image = [UIImage imageNamed:@"fusion.png"];
        }
        else if ([catalogType.name isEqualToString:@"интернациональная"]) {
            catalogType.image = [UIImage imageNamed:@"international.png"];
        }
        else if ([catalogType.name isEqualToString:@"кавказская"]) {
            catalogType.image = [UIImage imageNamed:@"kavkaz.png"];
        }
        else if ([catalogType.name isEqualToString:@"русская"]) {
            catalogType.image = [UIImage imageNamed:@"russian.png"];
        }
        else if ([catalogType.name isEqualToString:@"украинская"]) {
            catalogType.image = [UIImage imageNamed:@"ukraine.png"];
        }
        else if ([catalogType.name isEqualToString:@"узбекская"]) {
            catalogType.image = [UIImage imageNamed:@"uzbek.png"];
        }
        else if ([catalogType.name isEqualToString:@"китайская"]) {
            catalogType.image = [UIImage imageNamed:@"china.png"];
        }
        
        [[self.categories objectAtIndex:1] insertObject:catalogType atIndex:i];
    }    
    
    NSLog(@"Получил типы кухонь: %@", responceDict.description);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_CATALOG_CUISINES object:nil];
}

- (void)getBills {
    [self.categories insertObject:[NSMutableArray arrayWithCapacity:7] atIndex:2];
    CatalogCategory *type = [[CatalogCategory alloc] init];
    type.index = 2;
    type.name = @"< 500";
    type.from = 0;
    type.to = 500;
    type.image = [UIImage imageNamed:@"500.png"];
    [[self.categories objectAtIndex:2] insertObject:type atIndex:0];
    type = [[CatalogCategory alloc] init];
    type.index = 2;
    type.name = @"500-700";
    type.from = 500;
    type.to = 700;
    type.image = [UIImage imageNamed:@"500-700.png"];
    [[self.categories objectAtIndex:2] insertObject:type atIndex:1];
    type = [[CatalogCategory alloc] init];
    type.index = 2;
    type.name = @"700-1000";
    type.from = 700;
    type.to = 1000;
    type.image = [UIImage imageNamed:@"700-1000.png"];
    [[self.categories objectAtIndex:2] insertObject:type atIndex:2];
    type = [[CatalogCategory alloc] init];
    type.index = 2;
    type.name = @"1000-1500";
    type.from = 1000;
    type.to = 1500;
    type.image = [UIImage imageNamed:@"1000-1500.png"];
    [[self.categories objectAtIndex:2] insertObject:type atIndex:3];
    type = [[CatalogCategory alloc] init];
    type.index = 2;
    type.name = @"1500-2000";
    type.from = 1500;
    type.to = 2000;
    type.image = [UIImage imageNamed:@"1500-2000.png"];
    [[self.categories objectAtIndex:2] insertObject:type atIndex:4];
    type = [[CatalogCategory alloc] init];
    type.index = 2;
    type.name = @"2000-3000";
    type.from = 2000;
    type.to = 3000;
    type.image = [UIImage imageNamed:@"2000-3000.png"];
    [[self.categories objectAtIndex:2] insertObject:type atIndex:5];
    type = [[CatalogCategory alloc] init];
    type.index = 2;
    type.name = @"> 3000";
    type.from = 3000;
    type.to = 99999;
    type.image = [UIImage imageNamed:@"3000.png"];
    [[self.categories objectAtIndex:2] insertObject:type atIndex:6];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_CATALOG_BILLS object:nil];
}

- (void)getCatalogByCategory:(CatalogCategory *)category andLat:(double)lat andLng:(double)lng {
    //{ “request” : “catalog_by_type”, “type_id” : “id_типа”, “lat” : “широта”, “lng” : “долгота” }
    
    self.requeiredCategory = category;
    
    NSString *lat_ = [NSString stringWithFormat:@"%lf", lat];
    NSString *lng_ = [NSString stringWithFormat:@"%lf", lng];
    
    NSDictionary *requestDict;
    switch (category.index) {
        case 0:
            requestDict = [NSDictionary dictionaryWithObjectsAndKeys:@"catalog_by_type", @"request", lat_, @"lat", lng_, @"lng", [NSNumber numberWithInt:category.ID], @"type_id", nil];
            break;
        case 1:
            requestDict = [NSDictionary dictionaryWithObjectsAndKeys:@"catalog_by_cuisine", @"request", lat_, @"lat", lng_, @"lng", [NSNumber numberWithInt:category.ID], @"cuisine_id", nil];
            break;
        case 2:
            requestDict = [NSDictionary dictionaryWithObjectsAndKeys:@"catalog_by_bill", @"request", lat_, @"lat", lng_, @"lng", [NSNumber numberWithInt:category.ID], @"bill_id", nil];
            break;
    }    
    
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:requestDict] forKey:@"jsonData"];
    request.delegate = self;
    request.didFinishSelector = @selector(didGetCatalogByCategory:);
    [request startAsynchronous];
    
    NSLog(@"GetCatalogByCategory: %@", requestDict.description);
}

#warning Заглушка

- (void)didGetCatalogByCategory:(ASIHTTPRequest *)request {
    
    self.sections = 1;
    self.rows = [[NSMutableArray alloc] init];
    self.items = [[NSMutableDictionary alloc] init];
    
    int row = 0;
    for (int i = 0; i < self.allItems.count; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        CatalogItem *item = [self.allItems objectForKey:indexPath];
        switch (self.requeiredCategory.index) {
            case 0:
                if ([item.type rangeOfString:self.requeiredCategory.name].location != NSNotFound) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                    [self.items setObject:item forKey:indexPath];
                    row++;
                }
                break;
            case 1:
                if ([item.cuisine isKindOfClass:[NSNull class]]) break;
                if ([item.cuisine rangeOfString:self.requeiredCategory.name].location != NSNotFound) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                    [self.items setObject:item forKey:indexPath];
                    row++;
                }
                break;
            case 2: 
                if (item.bill < self.requeiredCategory.to && item.bill >= self.requeiredCategory.from) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                    [self.items setObject:item forKey:indexPath];
                    row++;
                }
                break;
        }
    }
    [self.rows insertObject:[NSNumber numberWithInt:row] atIndex:0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_CATALOG_BY_CATEGORY object:nil];
}

#warning Заглушка

- (void)getCatalogByName:(NSString *)name andLat:(double)lat andLng:(double)lng {
    self.tmp_name = name;
    
    NSString *lat_ = [NSString stringWithFormat:@"%lf", lat];
    NSString *lng_ = [NSString stringWithFormat:@"%lf", lng];

    NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:@"catalog_by_name", @"request", lat_, @"lat", lng_, @"lng", name, @"name", nil];
    
    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:kAPI_URL];
    [request setPostValue:[jsonWriter stringWithObject:requestDict] forKey:@"jsonData"];
    request.delegate = self;
    request.didFinishSelector = @selector(didGetCatalogByName:);
    [request startAsynchronous];
    
    NSLog(@"GetCatalogByName: %@", requestDict.description);
}

- (void)didGetCatalogByName:(ASIHTTPRequest *)request {
    //self.searchString = self.tmp_name;
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [parser objectWithString:[request responseString]];
    
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), dict.description);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_DID_GET_CATALOG_BY_NAME object:nil];
}

@end

 