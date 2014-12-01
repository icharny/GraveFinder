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

@synthesize currentLocation;
@synthesize grave;
@synthesize firstName, lastName, fullName, img64;
@synthesize deceasedYear;
@synthesize gravesArray;

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
}

+ (void)setFullName:(NSString *)fullName {
    [DataSingleton getSingleon].fullName = fullName;
}

+ (void)setFirstName:(NSString *)firstName {
    [DataSingleton getSingleon].firstName = firstName;
}

+ (void)setLastName:(NSString *)lastName {
    [DataSingleton getSingleon].lastName = lastName;
}

+ (void)setGraves:(NSArray *)graves {
    [DataSingleton getSingleon].gravesArray = graves;
}

+ (void)setDeceasedYear:(NSNumber *)deceased {
    [DataSingleton getSingleon].deceasedYear = deceased;
}

+ (void)setImage64:(NSString *)image64 {
    [DataSingleton getSingleon].img64 = image64;
}

@end
