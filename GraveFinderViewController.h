//
//  GraveFinderViewController.h
//  GraveFinder
//
//  Copyright 2014 Parse, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface GraveFinderViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
{
    IBOutlet MKMapView* mapView;
    IBOutlet UILabel* locationLabel;
    CLLocationManager* locationManager;
    CLLocation* currentLocation;
}

@property (nonatomic, strong) MKMapView* mapView;
@property (nonatomic, strong) UILabel* locationLabel;
@property (nonatomic, strong) CLLocation* currentLocation;

- (IBAction)getNearestCemetery:(id)sender;

@end
