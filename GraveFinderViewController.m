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
#import "GravesTableViewController.h"
#import "DataSingleton.h"
#import "ImageViewController.h"

@interface GraveFinderViewController ()

- (void)showRoute:(MKDirectionsResponse *)response;

@end

@implementation GraveFinderViewController

@synthesize mapView;
@synthesize cemeteryReference;

#pragma mark - UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
    //    [locationManager requestAlwaysAuthorization];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    cemeteryReference = nil;
    
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    [mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    if ([DataSingleton grave]) {
        [navButton setHidden:NO];
        [clearButton setHidden:NO];
        if ([[[DataSingleton grave] objectForKey:@"hasImage"] isEqual:@1]) {
            [imageButton setHidden:NO];
        } else {
            [imageButton setHidden:YES];
        }
    } else {
        [navButton setHidden:YES];
        [clearButton setHidden:YES];
        [imageButton setHidden:YES];
    }
    [super viewWillAppear:animated];
}

- (IBAction)centerOnUser:(id)sender {
    [mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (void)returnToGraveSearch {
    [self presentViewController:[[NameInputViewController alloc] initWithType:kFind] animated:YES completion:nil];
}

- (IBAction)locate:(id)sender {
    [DataSingleton reset];
    [self presentViewController:[[NameInputViewController alloc] initWithType:kFind] animated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    [DataSingleton reset];
    [self presentViewController:[[NameInputViewController alloc] initWithType:kSave] animated:YES completion:nil];
}

- (IBAction)clearMap:(id)sender {
    [mapView removeOverlays:[mapView overlays]];
    [mapView removeAnnotations:[mapView annotations]];
    [DataSingleton reset];
    cemeteryReference = nil;
    [DataSingleton reset];
    [clearButton setHidden:YES];
    [navButton setHidden:YES];
    [imageButton setHidden:YES];
    [self centerOnUser:nil];
}

- (IBAction)getDirections:(id)sender {
    PFObject* grave = [DataSingleton grave];
    CLLocation* currentLocation = [DataSingleton currentLocation];
    if (currentLocation && grave) {
        SHOW_LOADING(@"Loading")
        [GooglePlacesUtils getDirectionsToLocationWithReference:[grave objectForKey:@"cemeteryRef"]
                                             cemeteryFoundBlock:^(NSString *address) {
                                                 NSDictionary* launchOptions;
                                                 
                                                 //open native maps
                                                 NSDictionary* endDictionary = [self breakdownAddress:address name:[grave objectForKey:@"name"]];
                                                 MKMapItem* start = [MKMapItem mapItemForCurrentLocation];
                                                 CLLocation* cLocation = [[CLLocation alloc] initWithLatitude:[[grave objectForKey:@"cemeteryLat"] doubleValue] longitude:[[grave objectForKey:@"cemeteryLon"] doubleValue]];
                                                 MKMapItem* end = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:cLocation.coordinate addressDictionary:endDictionary]];
                                                 if ([currentLocation distanceFromLocation:cLocation] >= 250) {
                                                     launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
                                                 } else {
                                                     launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
                                                 }
                                                 [MKMapItem openMapsWithItems:@[start, end] launchOptions:launchOptions];
                                             }
                                           afterEverythingBlock:^{
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

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    [DataSingleton setCurrentLocation:userLocation.location];
}

- (void)showDirectionsToLocation:(CLLocation *)location {
    [mapView setCenterCoordinate:location.coordinate animated:TRUE];
    MapAnnotation* annotation = [[MapAnnotation alloc] initWithCoordinate:location.coordinate title:[[DataSingleton grave] objectForKey:@"name"]];
    [mapView addAnnotation:annotation];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:location.coordinate addressDictionary:nil]];
    request.requestsAlternateRoutes = NO;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            // Handle error
        } else {
            [self showRoute:response];
            [clearButton setHidden:NO];
            [navButton setHidden:NO];
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

- (void)showListOfGraves:(NSArray *)graves {
    [self presentViewController:[[GravesTableViewController alloc] init] animated:YES completion:nil];
}

- (IBAction)showImage:(id)sender {
    [self presentViewController:[[ImageViewController alloc] init] animated:YES completion:nil];
}

@end
