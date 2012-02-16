//
//  EventItem.h
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebImageDownloader.h"

@interface Event : NSObject <SDWebImageDownloaderDelegate>

@property (nonatomic, strong) NSURL *imageUrl;
@property (nonatomic, copy) NSString *announce;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *companyName;
@property (nonatomic) int companyID;
@property (nonatomic, strong) NSDate *date;

@end