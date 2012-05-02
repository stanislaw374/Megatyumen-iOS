//
//  PartyAnnounces.h
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 19.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

//#define kNOTIFICATION_DID_GET_ANNOUNCES @"megatyumen.didGetAnnounces"

@interface Announces : NSObject

@property (nonatomic, strong) NSMutableArray *items;

- (void)getItems;

@end
