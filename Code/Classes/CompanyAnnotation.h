//
//  CompanyAnnotation.h
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 27.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YandexMapKit.h"
#import "Company.h"

@interface CompanyAnnotation : NSObject <YMKAnnotation>
@property (nonatomic, strong) Company *company;
+ (CompanyAnnotation *)annotationForCompany:(Company *)company;
@end


