//
//  GravesTableViewController.m
//  GraveFinder
//
//  Created by ICharny on 11/19/14.
//
//

//
// This is the template PFQueryTableViewController subclass file. Use it to customize your own subclass.
//

#import "GravesTableViewController.h"
#import "GraveFinderViewController.h"
#import "DataSingleton.h"

@implementation GravesTableViewController

- (IBAction)back:(id)sender {
    [(GraveFinderViewController *)self.presentingViewController returnToGraveSearch];
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    PFObject* grave = [[DataSingleton graves] objectAtIndex:[indexPath row]];
    cell.textLabel.text = [[grave objectForKey:@"fullName"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSMutableString* deceasedString = [NSMutableString stringWithString:@"Year Deceased: "];
    NSString* year = [grave objectForKey:@"deceasedYear"];
    if ([year isEqualToString:@""]) {
        [deceasedString appendString:@"unknown"];
    } else {
        [deceasedString appendString:year];
    }
    cell.detailTextLabel.text = deceasedString;
    PFFile *theImage = [grave objectForKey:@"imageFile"];
    NSData *imageData = [theImage getData];
    UIImage *image = [UIImage imageWithData:imageData];
    cell.imageView.image = image;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray* graves = [DataSingleton graves];
    return graves.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject* grave = [[DataSingleton graves] objectAtIndex:[indexPath row]];
    [DataSingleton setGrave:grave];
    CLLocation* cLocation = [[CLLocation alloc] initWithLatitude:[[grave objectForKey:@"cemeteryLat"] doubleValue] longitude:[[grave objectForKey:@"cemeteryLon"] doubleValue]];
    [(GraveFinderViewController *)self.presentingViewController showDirectionsToLocation:cLocation];
}

@end