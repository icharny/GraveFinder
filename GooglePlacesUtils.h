//
//  GooglePlacesUtils.h
//  GraveFinder
//
//  Created by ICharny on 11/19/14.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>

#define GOOGLE_PLACES_API_KEY "AIzaSyCqaQI6GsT6KJGfSxGFXu52OqOUdEMr-Nw"

@interface GooglePlacesUtils : NSObject

+ (NSURL *)cemetariesNearMeUrlForLocation:(CLLocation *)currentLocation;
+ (NSURL *)placeDetailsUrlForReference:(NSString *)reference;

+ (void)getNearestCemeteryForLocation:(CLLocation *)location cemeteryFoundBlock:(void (^)(NSArray*))cemeteryFoundBlock afterEverythingBlock:(void (^)(void))afterEverythingBlock;
+ (void)getDirectionsToLocationWithReference:(NSString *)reference cemeteryFoundBlock:(void (^)(NSString *))cemeteryFoundBlock afterEverythingBlock:(void (^)(void))afterEverythingBlock;;

+ (NSDictionary *)breakdownAddress:(NSString *)address name:(NSString *)name;

@end
