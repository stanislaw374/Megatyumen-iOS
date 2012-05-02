//
//  PartyAnnounce.h
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AnnounceDelegate <NSObject>
@optional
- (void)announcesDidLoad:(NSArray *)announces;
- (void)announcesDidFailWithError:(NSString *)error;
@end

@interface Announce : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSURL *image;
+ (void)getWithDelegate:(id <AnnounceDelegate>)delegate;
@end
