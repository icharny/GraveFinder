//
//  GooglePlacesUtils.m
//  GraveFinder
//
//  Created by ICharny on 11/19/14.
//
//

#import "GooglePlacesUtils.h"

@implementation GooglePlacesUtils

+ (NSURL *)cemetariesNearMeUrlForLocation:(CLLocation *)currentLocation
{
    // https://maps.googleapis.com/maps/api/place/nearbysearch/output?parameters
    
    NSMutableString* urlString = [NSMutableString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=%s", GOOGLE_PLACES_API_KEY];
    [urlString appendFormat:@"&location=%1.10f,%1.10f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
    [urlString appendString:@"&rankby=distance"];
    [urlString appendString:@"&keyword=cemetery"];
    
    //NSLog(@"url: %@", urlString);
    
    return [NSURL URLWithString:urlString];
}

+ (NSURL *)placeDetailsUrlForReference:(NSString *)reference
{
    // https://maps.googleapis.com/maps/api/place/details/output?parameters
    
    NSMutableString* urlString = [NSMutableString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?key=%s", GOOGLE_PLACES_API_KEY];
    [urlString appendFormat:@"&reference=%@", reference];
    
    // NSLog(@"url: %@", urlString);
    
    return [NSURL URLWithString:urlString];
}

+ (void)getNearestCemeteryForLocation:(CLLocation *)location cemeteryFoundBlock:(void (^)(NSArray *))cemeteryFoundBlock afterEverythingBlock:(void (^)(void))afterEverythingBlock {
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[GooglePlacesUtils cemetariesNearMeUrlForLocation:location]]
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (data) {
                                   NSArray* cemeteries = [[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL] objectForKey:@"results"];
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if (cemeteries.count > 0) {
                                           cemeteryFoundBlock(cemeteries);
                                       } else {
                                           [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There are no cemeteries near you..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                       }
                                   });
                               } else {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [[[UIAlertView alloc] initWithTitle:@"Error" message:@"It appears that you are offline." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                   });
                               }
                               afterEverythingBlock();
                           }];
}

+ (void)getDirectionsToLocationWithReference:(NSString *)reference cemeteryFoundBlock:(void (^)(NSString *))cemeteryFoundBlock afterEverythingBlock:(void (^)(void))afterEverythingBlock {
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[GooglePlacesUtils placeDetailsUrlForReference:reference]]
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (data) {
                                   
                                   NSLog(@"place details: %@", [NSString stringWithUTF8String:[data bytes]]);
                                   
                                   NSString* address = [[[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL] objectForKey:@"result"] objectForKey:@"formatted_address"];
                                   if (address) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           cemeteryFoundBlock(address);
                                       });
                                   }
                               }
                               afterEverythingBlock();
                           }];
}



+ (NSDictionary *)breakdownAddress:(NSString *)address name:(NSString *)name
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    NSMutableArray* components = [NSMutableArray arrayWithArray:[address componentsSeparatedByString:@", "]];
    if (components.count > 0) {
        [dict setValue:[components objectAtIndex:(components.count - 1)] forKey:(NSString *)kABPersonAddressCountryKey];
        [components removeLastObject];
    }
    if (components.count > 0) {
        [dict setValue:[components objectAtIndex:(components.count - 1)] forKey:(NSString *)kABPersonAddressStateKey];
        [components removeLastObject];
    }
    if (components.count > 0) {
        [dict setValue:[components objectAtIndex:(components.count - 1)] forKey:(NSString *)kABPersonAddressCityKey];
        [components removeLastObject];
    }
    if (components.count > 0) {
        [dict setValue:[components objectAtIndex:(components.count - 1)] forKey:(NSString *)kABPersonAddressStreetKey];
        [components removeLastObject];
    } else {
        [dict setValue:name forKey:(NSString *)kABPersonAddressStreetKey];
    }
    
    return dict;
}

@end
