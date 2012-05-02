//
//  Company.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 24.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol CompanyDelegate <NSObject>
@optional
- (void)companyDidFailWithError:(NSString *)error;
- (void)companyDetailsDidLoad;
- (void)companyImagesDidLoad;
- (void)companyDidCheckin;
- (void)companyFeedbacksDidLoad;
- (void)companyMenuDidLoad;
- (void)companyEventsDidLoad;
@end

@interface Company : NSObject
@property (unsafe_unretained, nonatomic) id <CompanyDelegate> delegate;

@property (nonatomic) int ID;                           // ID заведения
@property (nonatomic, strong) NSString *name;           // Название заведения
@property (nonatomic, strong) NSString *address;        // Адрес заведения
@property (nonatomic) CLLocationCoordinate2D coordinate;// Координаты
@property (nonatomic, strong) NSURL *logoURL;           // Логотип
@property (nonatomic) int feedbacksCount;               // Количество отзывов
@property (nonatomic) int checkinCount;                 // Количество чекинов
@property (nonatomic, strong) NSString *description;

@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *thumbnails;

@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *hours;

@property (nonatomic, strong) NSArray *feedbacks;
@property (nonatomic, strong) NSArray *menu;
@property (nonatomic, strong) NSArray *events;
@property (nonatomic) double distance;

- (void)getDetails;
- (void)getImages;
- (void)getMenu;
- (void)getFeedbacks;
- (void)getEvents;
- (void)checkin:(int)attitude withText:(NSString *)text;
@end
