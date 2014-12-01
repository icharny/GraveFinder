//
//  DataSingleton.h
//  GraveFinder
//
//  Created by ICharny on 11/20/14.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface DataSingleton : NSObject {
    CLLocation* currentLocation;
    PFObject* grave;
    
    NSString* firstName;
    NSString* lastName;
    NSString* fullName;
    
    NSNumber* deceasedYear;
    
    NSString* img64;
    
    NSArray* gravesArray;
}

@property (nonatomic, strong) CLLocation* currentLocation;
@property (nonatomic, strong) PFObject* grave;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;
@property (nonatomic, strong) NSString* fullName;
@property (nonatomic, strong) NSNumber* deceasedYear;
@property (nonatomic, strong) NSString* img64;
@property (nonatomic, strong) NSArray* gravesArray;

+ (void)reset;

+ (CLLocation *)currentLocation;
+ (PFObject *)grave;
+ (NSString *)firstName;
+ (NSString *)lastName;
+ (NSString *)fullName;
+ (NSNumber *)deceasedYear;
+ (NSString *)image64;
+ (NSArray *)graves;

+ (void)setCurrentLocation:(CLLocation *)currentLocation;
+ (void)setGrave:(PFObject *)grave;
+ (void)setFullName:(NSString *)fullName;
+ (void)setFirstName:(NSString *)firstName;
+ (void)setLastName:(NSString *)lastName;
+ (void)setDeceasedYear:(NSNumber *)deceased;
+ (void)setImage64:(NSString *)image64;
+ (void)setGraves:(NSArray *)graves;

@end
