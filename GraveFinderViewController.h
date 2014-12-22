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
    NSString* cemeteryReference;
    IBOutlet UIButton* navButton;
    IBOutlet UIButton* clearButton;
    IBOutlet UIButton* imageButton;
    IBOutlet UILabel* cemeteryNameLabel;
}

@property (nonatomic, strong) MKMapView* mapView;
@property (nonatomic, strong) UILabel* locationLabel;
@property (nonatomic, strong) NSString* cemeteryReference;
@property (nonatomic, strong) UIImageView* imageView;

- (IBAction)clearMap:(id)sender;
- (IBAction)centerOnUser:(id)sender;
- (IBAction)getDirections:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)locate:(id)sender;
- (IBAction)showImage:(id)sender;
- (void)showDirectionsToLocation:(CLLocation *)location;
- (void)showListOfGraves;
- (void)returnToGraveSearch;@end
