//
//  ImageViewController.m
//  GraveFinder
//
//  Created by ICharny on 11/26/14.
//
//

#import "ImageViewController.h"
#import "DataSingleton.h"
#import <Parse/Parse.h>

@implementation ImageViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    PFObject* grave = [DataSingleton grave];
    PFFile* theImage = [grave objectForKey:@"imageFile"];
    NSData* imageData = [theImage getData];
    UIImage *image = [UIImage imageWithData:imageData];
    if (image) {
        imageView.image = image;
    }
}

- (IBAction)back:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
