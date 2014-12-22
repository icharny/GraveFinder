//
//  GraveFinderAppDelegate.m
//  GraveFinder
//
//  Copyright 2014 Parse, Inc. All rights reserved.
//

#import <Parse/Parse.h>

// If you want to use any of the UI components, uncomment this line
// #import <ParseUI/ParseUI.h>

// If you are using Facebook, uncomment this line
// #import <ParseFacebookUtils/PFFacebookUtils.h>

#import "GraveFinderAppDelegate.h"
#import "GraveFinderViewController.h"
#import "DataSingleton.h"

@implementation GraveFinderAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // ****************************************************************************
    // Uncomment and fill in with your Parse credentials:
    [Parse setApplicationId:@"3EGyiVArwgIRcV30xUsjZtOfdKn9kILYP2F7DM3f"
                  clientKey:@"H56jR3zQFt29sAo7dPtswvNQCwfKexFp3jmX1SIt"];
    //
    // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
    // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
    // [PFFacebookUtils initializeFacebook];
    // ****************************************************************************

    [PFUser enableAutomaticUser];

    PFACL *defaultACL = [PFACL ACL];

    // If you would like all objects to be private by default, remove this line.
    [defaultACL setPublicReadAccess:YES];

    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];

    // Override point for customization after application launch.

    [DataSingleton reset];
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    return YES;
}
@end
