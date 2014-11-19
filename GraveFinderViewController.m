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

@interface GraveFinderViewController ()

- (void)getDirections;
- (void)showRoute:(MKDirectionsResponse *)response;

@end

@implementation GraveFinderViewController

@synthesize mapView;
@synthesize locationLabel;
@synthesize currentLocation, cemeteryLocation;
@synthesize cemeteryReference;
@synthesize userRegion;

#pragma mark - UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    locationLabel.text = @"";
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    currentLocation = nil;
    cemeteryLocation = nil;
    cemeteryReference = nil;
    
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    [mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (IBAction)centerOnUser:(id)sender {
    if (currentLocation) {
        //        [mapView setRegion:MKCoordinateRegionMake(mapView.userLocation.location.coordinate, MKCoordinateSpanMake(.005, .005)) animated:YES];
        [mapView setRegion:userRegion animated:YES];
        [mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
        [mapView setUserTrackingMode:MKUserTrackingModeFollow animated:NO];
        //    [mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];
    }
}

- (IBAction)locate:(id)sender {
    [self presentViewController:[[NameInputViewController alloc] initWithCurrentLocation:currentLocation type:kFind] animated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    [self presentViewController:[[NameInputViewController alloc] initWithCurrentLocation:currentLocation type:kSave] animated:YES completion:nil];
}

- (IBAction)clearMap:(id)sender {
    [mapView removeOverlays:[mapView overlays]];
    [mapView removeAnnotations:[mapView annotations]];
    cemeteryLocation = nil;
    cemeteryReference = nil;
}

- (IBAction)getDirections:(id)sender {
    SHOW_LOADING
    PFQuery* query = [PFQuery queryWithClassName:@"Grave"];
    [query whereKey:@"firstName" equalTo:@"First Name"];
    [query whereKey:@"lastName" equalTo:@"Last Name"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            HIDE_LOADING
        });
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
                    [GooglePlacesUtils getDirectionsToLocationWithReference:cRef
                                                         cemeteryFoundBlock:^(NSString *address) {
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
                                                         }
                                                       afterEverythingBlock:nil];
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
}

- (IBAction)getNearestCemetery:(id)sender {
    if (currentLocation) {
        SHOW_LOADING
        [GooglePlacesUtils getNearestCemeteryForLocation:currentLocation cemeteryFoundBlock:^(NSArray* cemeteries) {
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
            // [grave saveEventually];
            [grave saveInBackground];
            
            [self getDirections];
        } afterEverythingBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                HIDE_LOADING
            });
        }];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    currentLocation = newLocation;
    userRegion = [mapView region];
}

- (void)getDirections {
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

- (NSDictionary *)breakdownAddress:(NSString *)address name:(NSString *)name
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
