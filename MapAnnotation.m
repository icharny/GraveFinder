//
//  MapAnnotation.m
//  GraveFinder
//
//  Created by ICharny on 11/18/14.
//
//

#import "MapAnnotation.h"

@implementation MapAnnotation 
@synthesize coordinate;
@synthesize title;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t {
    self = [self init];
    coordinate = c;
    title = t;
    return self;
}

@end
