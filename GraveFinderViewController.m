//
//  GraveFinderViewController.m
//  GraveFinder
//
//  Copyright 2014 Parse, Inc. All rights reserved.
//

#import "GraveFinderViewController.h"
#import <Parse/Parse.h>
#import "MapAnnotation.h"

#define GOOGLE_PLACES_API_KEY "AIzaSyCqaQI6GsT6KJGfSxGFXu52OqOUdEMr-Nw"

@interface GraveFinderViewController ()

- (NSURL *)cemetariesNearMeUrl;

@end

@implementation GraveFinderViewController

@synthesize mapView;
@synthesize locationLabel;
@synthesize currentLocation;

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
    
    mapView.delegate = self;
    mapView.showsUserLocation = TRUE;
    [mapView setUserTrackingMode:MKUserTrackingModeFollow animated:TRUE];
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
                                               NSString* name = [cemetery objectForKey:@"name"];
                                               locationLabel.text = name;
                                               NSDictionary* location = [[cemetery objectForKey:@"geometry"] objectForKey:@"location"];
                                               CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[location objectForKey:@"lat"] doubleValue], [[location  objectForKey:@"lng"] doubleValue]);
                                               [mapView setCenterCoordinate:coordinate animated:TRUE];
                                               MapAnnotation* annotation = [[MapAnnotation alloc] init];
                                               annotation.coordinate = coordinate;
                                               [annotation setTitle:name];
                                               [mapView addAnnotation:annotation];
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

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    currentLocation = newLocation;
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
    
    NSLog(@"url: %@", urlString);
    
    return [NSURL URLWithString:urlString];
}

@end
