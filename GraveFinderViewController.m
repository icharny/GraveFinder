//
//  GraveFinderViewController.m
//  GraveFinder
//
//  Copyright 2014 Parse, Inc. All rights reserved.
//

#import "GraveFinderViewController.h"
#import <Parse/Parse.h>
#import "MapAnnotation.h"
#import <AddressBook/AddressBook.h>
#import "NameInputViewController.h"

#define GOOGLE_PLACES_API_KEY "AIzaSyCqaQI6GsT6KJGfSxGFXu52OqOUdEMr-Nw"

@interface GraveFinderViewController ()

- (NSURL *)cemetariesNearMeUrl;
- (NSURL *)placeDetailsUrlForReference:(NSString *)reference;
- (void)getDirections;
- (void)showRoute:(MKDirectionsResponse *)response;
- (NSDictionary *)breakdownAddress:(NSString *)address name:(NSString *)name;

@end

@implementation GraveFinderViewController

@synthesize mapView;
@synthesize locationLabel;
@synthesize currentLocation, cemeteryLocation;
@synthesize cemeteryReference;

#pragma mark - UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    locationLabel.text = @"";
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestAlwaysAuthorization];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    currentLocation = nil;
    cemeteryLocation = nil;
    cemeteryReference = nil;
    
    mapView.delegate = self;
    mapView.showsUserLocation = TRUE;
    [mapView setUserTrackingMode:MKUserTrackingModeFollow animated:TRUE];
}

- (IBAction)centerOnUser:(id)sender
{
    [mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
}

- (IBAction)locate:(id)sender {
    [self presentViewController:[[NameInputViewController alloc] init] animated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    [self presentViewController:[[NameInputViewController alloc] init] animated:YES completion:nil];
}

- (IBAction)clearMap:(id)sender
{
    [mapView removeOverlays:[mapView overlays]];
    [mapView removeAnnotations:[mapView annotations]];
    cemeteryLocation = nil;
    cemeteryReference = nil;
}

- (IBAction)getDirections:(id)sender
{
    PFQuery* query = [PFQuery queryWithClassName:@"Grave"];
    [query whereKey:@"firstName" equalTo:@"First Name"];
    [query whereKey:@"lastName" equalTo:@"Last Name"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu graves.", (unsigned long)objects.count);
            // Do something with the found objects
            if (objects.count > 0) {
                PFObject* grave = (PFObject *)[objects firstObject];
                CLLocation* cLocation = [[CLLocation alloc] initWithLatitude:[[grave objectForKey:@"cemeteryLat"] doubleValue] longitude:[[grave objectForKey:@"cemeteryLon"] doubleValue]];
                NSString* cRef = [grave objectForKey:@"cemeteryRef"];
                NSString* cName = [grave objectForKey:@"name"];
                if (currentLocation && cLocation && cRef) {
                    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[self placeDetailsUrlForReference:cRef]]
                                                       queue:[[NSOperationQueue alloc] init]
                                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                               if (data) {
                                                   NSLog(@"place details: %@", [NSString stringWithUTF8String:[data bytes]]);
                                                   
                                                   NSString* address = [[[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL] objectForKey:@"result"] objectForKey:@"formatted_address"];
                                                   if (address) {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           NSDictionary* launchOptions;
                                                           
                                                           //open native maps
                                                           NSDictionary* endDictionary = [self breakdownAddress:address name:cName];
                                                           MKMapItem* start = [MKMapItem mapItemForCurrentLocation];
                                                           MKMapItem* end = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:cLocation.coordinate addressDictionary:endDictionary]];
                                                           if ([currentLocation distanceFromLocation:cLocation] >= 250) {
                                                               launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
                                                           } else {
                                                               launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
                                                           }
                                                           [MKMapItem openMapsWithItems:@[start, end] launchOptions:launchOptions];
                                                       });
                                                   }
                                               }
                                           }];
                }

            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There are no graves with that name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                });
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
//    if (currentLocation && cemeteryLocation && cemeteryReference) {
//        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[self placeDetailsUrlForReference:cemeteryReference]]
//                                           queue:[[NSOperationQueue alloc] init]
//                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//                                   if (data) {
//                                       NSLog(@"place details: %@", [NSString stringWithUTF8String:[data bytes]]);
//                                       
//                                       NSString* address = [[[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL] objectForKey:@"result"] objectForKey:@"formatted_address"];
//                                       if (address) {
//                                           dispatch_async(dispatch_get_main_queue(), ^{
//                                               NSDictionary* launchOptions;
//                                               
//                                               //open native maps
//                                               NSDictionary* endDictionary = [self breakdownAddress:address name:locationLabel.text];
//                                               MKMapItem* start = [MKMapItem mapItemForCurrentLocation];
//                                               MKMapItem* end = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:cemeteryLocation.coordinate addressDictionary:endDictionary]];
//                                               if ([currentLocation distanceFromLocation:cemeteryLocation] >= 250) {
//                                                   launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
//                                               } else {
//                                                   launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
//                                               }
//                                               [MKMapItem openMapsWithItems:@[start, end] launchOptions:launchOptions];
//                                           });
//                                       }
//                                   }
//                               }];
//    }
}

- (IBAction)getNearestCemetery:(id)sender
{
    if (currentLocation) {
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[self cemetariesNearMeUrl]]
                                           queue:[[NSOperationQueue alloc] init]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (data) {
                                       NSArray* cemeteries = [[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL] objectForKey:@"results"];
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           if (cemeteries.count > 0) {
                                               NSDictionary* cemetery = (NSDictionary *)[cemeteries objectAtIndex:0];
                                               
                                               NSLog(@"cemetery: %@", cemetery);
                                               
                                               NSString* name = [cemetery objectForKey:@"name"];
                                               locationLabel.text = name;
                                               NSDictionary* location = [[cemetery objectForKey:@"geometry"] objectForKey:@"location"];
                                               CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[location objectForKey:@"lat"] doubleValue], [[location  objectForKey:@"lng"] doubleValue]);
                                               cemeteryLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
                                               cemeteryReference = [cemetery objectForKey:@"reference"];
                                               [mapView setCenterCoordinate:coordinate animated:TRUE];
                                               MapAnnotation* annotation = [[MapAnnotation alloc] initWithCoordinate:coordinate title:name];
                                               [mapView addAnnotation:annotation];
                                               
                                               PFObject* grave = [PFObject objectWithClassName:@"Grave"];
                                               grave[@"firstName"] = @"First Name";
                                               grave[@"lastName"] = @"Last Name";
                                               grave[@"cemeteryName"] = name;
                                               grave[@"cemeteryLat"] = [NSNumber numberWithDouble:coordinate.latitude];
                                               grave[@"cemeteryLon"] = [NSNumber numberWithDouble:coordinate.longitude];
                                               grave[@"cemeteryRef"] = cemeteryReference;
                                               [grave saveEventually];
                                               
                                               [self getDirections];
                                           } else {
                                               [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There are no cemeteries near you..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                           }
                                       });
                                   } else {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [[[UIAlertView alloc] initWithTitle:@"Error" message:@"It appears that you are offline." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                       });
                                   }
                               }];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    currentLocation = newLocation;
}

- (void)getDirections
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:cemeteryLocation.coordinate addressDictionary:nil]];
    request.requestsAlternateRoutes = NO;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            // Handle error
        } else {
            [self showRoute:response];
        }
    }];
}

- (void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute* route in response.routes) {
        [mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        for (MKRouteStep* step in route.steps) {
            NSLog(@"%@", step.instructions);
        }
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer* renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 5.0;
    return renderer;
}

- (NSURL *)cemetariesNearMeUrl
{
    // https://maps.googleapis.com/maps/api/place/nearbysearch/output?parameters
    // 42.289697,-71.170569
    NSMutableString* urlString = [NSMutableString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=%s", GOOGLE_PLACES_API_KEY];
    //    [urlString appendFormat:@"&location=%@,%@", @"42.289697", @"-71.170569"]; // replace with real location
    [urlString appendFormat:@"&location=%1.10f,%1.10f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude]; // replace with real location
    [urlString appendString:@"&rankby=distance"];
    [urlString appendString:@"&keyword=cemetery"];
    
    //NSLog(@"url: %@", urlString);
    
    return [NSURL URLWithString:urlString];
}

- (NSURL *)placeDetailsUrlForReference:(NSString *)reference
{
    // https://maps.googleapis.com/maps/api/place/details/json?reference=CmRYAAAAciqGsTRX1mXRvuXSH2ErwW-jCINE1aLiwP64MCWDN5vkXvXoQGPKldMfmdGyqWSpm7BEYCgDm-iv7Kc2PF7QA7brMAwBbAcqMr5i1f4PwTpaovIZjysCEZTry8Ez30wpEhCNCXpynextCld2EBsDkRKsGhSLayuRyFsex6JA6NPh9dyupoTH3g&key=AddYourOwnKeyHere
    
    NSMutableString* urlString = [NSMutableString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?key=%s", GOOGLE_PLACES_API_KEY];
    [urlString appendFormat:@"&reference=%@", reference];
    
    NSLog(@"url: %@", urlString);
    
    return [NSURL URLWithString:urlString];
}

- (NSDictionary *)breakdownAddress:(NSString *)address name:(NSString *)name
{
    //    const CFStringRef  kABPersonAddressStreetKey ;
    //    const CFStringRef  kABPersonAddressCityKey ;
    //    const CFStringRef  kABPersonAddressStateKey ;
    //    const CFStringRef  kABPersonAddressZIPKey ;
    //    const CFStringRef  kABPersonAddressCountryKey ;
    
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
