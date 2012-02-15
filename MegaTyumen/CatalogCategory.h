//
//  CatalogClassifier.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 13.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatalogCategory : NSObject

@property (nonatomic) int index;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) int from;
@property (nonatomic) int to;
@property (nonatomic, strong) UIImage *image;

@end
