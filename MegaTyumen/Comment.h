//
//  NewComment.h
//  MegaTyumen
//
//  Created by Stanislaw Lazienki on 28.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *text;

@end
