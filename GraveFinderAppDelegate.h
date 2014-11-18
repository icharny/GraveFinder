//
//  GraveFinderAppDelegate.h
//  GraveFinder
//
//  Copyright 2014 Parse, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GraveFinderViewController;

@interface GraveFinderAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;

@property (nonatomic, strong) IBOutlet GraveFinderViewController *viewController;

@end
