//
//  CompanyAnnotation.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 27.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CompanyAnnotation.h"

@implementation CompanyAnnotation
@synthesize company = _company;

+ (CompanyAnnotation *)annotationForCompany:(Company *)company {
    CompanyAnnotation *a = [[CompanyAnnotation alloc] init];
    a.company = company;
    return a;
}

- (NSString *)title {
    return self.company.name;
}

- (NSString *)subtitle {
    return self.company.address;
}

- (YMKMapCoordinate)coordinate {
    return self.company.coordinate;
}

@end
