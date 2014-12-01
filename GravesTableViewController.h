//
//  GravesTableViewController.h
//  GraveFinder
//
//  Created by ICharny on 11/19/14.
//
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>

@interface GravesTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView* tableView;
}

- (IBAction)back:(id)sender;

@end
