//
//  GraveFinderViewController.h
//  GraveFinder
//
//  Copyright 2014 Parse, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GooglePlacesUtils.h"
#import <MapKit/MapKit.h>

@interface GraveFinderViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
{
    IBOutlet MKMapView* mapView;
    IBOutlet UILabel* locationLabel;
    CLLocationManager* locationManager;
    CLLocation* currentLocation;
    CLLocation* cemeteryLocation;
    NSString* cemeteryReference;
    MKCoordinateRegion userRegion;
}

@property (nonatomic, strong) MKMapView* mapView;
@property (nonatomic, strong) UILabel* locationLabel;
@property (nonatomic, strong) CLLocation* currentLocation;
@property (nonatomic, strong) CLLocation* cemeteryLocation;
@property (nonatomic, strong) NSString* cemeteryReference;
@property (nonatomic) MKCoordinateRegion userRegion;

- (IBAction)getNearestCemetery:(id)sender;
- (IBAction)clearMap:(id)sender;
- (IBAction)centerOnUser:(id)sender;
- (IBAction)getDirections:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)locate:(id)sender;
@end
