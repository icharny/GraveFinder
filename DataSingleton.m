//
//  DataSingleton.m
//  GraveFinder
//
//  Created by ICharny on 11/20/14.
//
//

#import "DataSingleton.h"

@interface DataSingleton ()

+ (instancetype)getSingleon;

@end

@implementation DataSingleton

@synthesize locationManager;
@synthesize currentLocation;
@synthesize grave;
@synthesize firstName, lastName, fullName, img64;
@synthesize deceasedYear;
@synthesize gravesArray;
@synthesize hasData;

static DataSingleton* singleton = nil;

- (instancetype)init {
    self = [super init];
    self.currentLocation = nil;
    self.grave = nil;
    self.fullName = @"";
    self.firstName = @"";
    self.lastName = @"";
    self.gravesArray = [NSArray array];
    self.deceasedYear = nil;
    self.img64 = nil;
    
    self.locationManager = [[CLLocationManager alloc] init];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.hasData = NO;
    return self;
}

+ (instancetype)getSingleon {
    if (!singleton) {
        singleton = [[DataSingleton alloc] init];
    }
    return singleton;
}

+ (void)reset {
    DataSingleton* s = [DataSingleton getSingleon];
    s.grave = nil;
    s.fullName = @"";
    s.firstName = @"";
    s.lastName = @"";
    s.gravesArray = [NSArray array];
    s.img64 = nil;
    s.deceasedYear = nil;
    s.hasData = NO;
}

+ (BOOL)hasData {
    return [DataSingleton getSingleon].hasData;
}

+ (CLLocationManager *)locationManager {
    return [DataSingleton getSingleon].locationManager;
}

+ (CLLocation *)currentLocation {
    return [DataSingleton getSingleon].currentLocation;
}

+ (PFObject *)grave {
    return [DataSingleton getSingleon].grave;
}

+ (NSString *)firstName {
    return [DataSingleton getSingleon].firstName;
}

+ (NSString *)lastName {
    return [DataSingleton getSingleon].lastName;
}

+ (NSArray *)graves {
    return [DataSingleton getSingleon].gravesArray;
}

+ (NSString *)fullName {
    return [DataSingleton getSingleon].fullName;
}

+ (NSString *)image64 {
    return [DataSingleton getSingleon].img64;
}

+ (NSNumber *)deceasedYear {
    return [DataSingleton getSingleon].deceasedYear;
}

+ (void)setCurrentLocation:(CLLocation *)currentLocation {
    [DataSingleton getSingleon].currentLocation = currentLocation;
}

+ (void)setGrave:(PFObject *)grave {
    [DataSingleton getSingleon].grave = grave;
    [DataSingleton getSingleon].hasData = YES;
}

+ (void)setFullName:(NSString *)fullName {
    [DataSingleton getSingleon].fullName = fullName;
    [DataSingleton getSingleon].hasData = YES;
}

+ (void)setFirstName:(NSString *)firstName {
    [DataSingleton getSingleon].firstName = firstName;
    [DataSingleton getSingleon].hasData = YES;
}

+ (void)setLastName:(NSString *)lastName {
    [DataSingleton getSingleon].lastName = lastName;
    [DataSingleton getSingleon].hasData = YES;
}

+ (void)setGraves:(NSArray *)graves {
    [DataSingleton getSingleon].gravesArray = graves;
    [DataSingleton getSingleon].hasData = YES;
}

+ (void)setDeceasedYear:(NSNumber *)deceased {
    [DataSingleton getSingleon].deceasedYear = deceased;
    [DataSingleton getSingleon].hasData = YES;
}

+ (void)setImage64:(NSString *)image64 {
    [DataSingleton getSingleon].img64 = image64;
}

@end
