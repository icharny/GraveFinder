//
//  NameInputViewController.m
//  GraveFinder
//
//  Created by ICharny on 11/18/14.
//
//

#import "NameInputViewController.h"
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import "GraveFinderViewController.h"
#import "DataSingleton.h"

#define firstYear 1500
#define numberOfYears 550

@implementation NameInputViewController

@synthesize activeTextField;
@synthesize type;
@synthesize setup;
@synthesize orgFrame;

- (instancetype)initWithType:(NameInputType)t {
    self = [self init];
    type = t;
    setup = NO;
    return self;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return numberOfYears + 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row == 0) {
        return @"";
    } else {
        return [NSString stringWithFormat:@"%ld", firstYear - 1 + row];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage* buttonImage;
    if (type == kSave) {
        buttonImage = [UIImage imageNamed:@"add"];
    } else {
        buttonImage = [UIImage imageNamed:@"search"];
    }
    
    [goButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [photoButton setBackgroundColor:[UIColor colorWithRed:250.f/255.f green:250.f/255.f blue:250.f/255.f alpha:1]];
    
    // create a UIPicker view as a custom keyboard view
    UIPickerView* pickerView = [[UIPickerView alloc] init];
    [pickerView sizeToFit];
    pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = YES;
    if (![deceasedTextField.text isEqualToString:@""]) {
        [pickerView selectRow:([deceasedTextField.text integerValue] - firstYear + 1) inComponent:0 animated:NO];
    }
    deceasedTextField.inputView = pickerView;
    
    // create a done view + done button, attach to it a doneClicked action, and place it in a toolbar as an accessory input view...
    // Prepare done button
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle = UIBarStyleDefault;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    
    UIBarButtonItem* setButton = [[UIBarButtonItem alloc] initWithTitle:@"Set Date"
                                                                  style:UIBarButtonItemStyleBordered target:self
                                                                 action:@selector(doneClicked:)];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Return"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(returnPicker:)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:setButton, doneButton, nil]];
    
    // Plug the keyboardDoneButtonView into the text field...
    deceasedTextField.inputAccessoryView = keyboardDoneButtonView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!setup) {
        firstNameTextField.text = [DataSingleton firstName];
        lastNameTextField.text = [DataSingleton lastName];
        NSNumber* deceasedYear = [DataSingleton deceasedYear];
        if (deceasedYear) {
            deceasedTextField.text = [NSString stringWithFormat:@"%@", deceasedYear];
        }
        
        if (type == kFind) {
            CGRect frame = scrollView.frame;
            frame.size.height -= photoView.frame.size.height;
            scrollView.frame = frame;
            [photoView removeFromSuperview];
            [scrollView sizeToFit];
        }
        
        scrollView.contentSize = scrollView.frame.size;
        setup = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    orgFrame = self.view.frame;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    activeTextField = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    activeTextField = nil;
    return YES;
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    if (!keyboardShowing) {
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        CGRect frame = self.view.frame;
        frame.size.height -= kbSize.height;
        self.view.frame = frame;
        [self.view layoutSubviews];
        keyboardShowing = YES;
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    if (keyboardShowing) {
        self.view.frame = orgFrame;
        scrollView.contentSize = scrollView.frame.size;
        keyboardShowing = NO;
        [self.view layoutSubviews];
    }
}

- (IBAction)find:(id)sender {
    if (activeTextField) {
        [activeTextField resignFirstResponder];
    }
    
    NSString* firstName = [firstNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* lastName = [lastNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    NSString* deceasedYear = deceasedTextField.text;
    
    [DataSingleton setFirstName:firstName];
    [DataSingleton setLastName:lastName];
    [DataSingleton setFullName:fullName];
    
    firstName = [firstName lowercaseString];
    lastName = [lastName lowercaseString];
    
    if ([firstName isEqualToString:@""] && [lastName isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please input at least one name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        if (type == kSave) {
            CLLocation* currentLocation = [DataSingleton currentLocation];
            if (currentLocation) {
                SHOW_LOADING(@"Saving")
                [GooglePlacesUtils getNearestCemeteryForLocation:currentLocation cemeteryFoundBlock:^(NSArray* cemeteries) {
                    NSDictionary* cemetery = (NSDictionary *)[cemeteries objectAtIndex:0];
                    
                    // NSLog(@"cemetery: %@", cemetery);
                    
                    NSString* name = [cemetery objectForKey:@"name"];
                    NSDictionary* location = [[cemetery objectForKey:@"geometry"] objectForKey:@"location"];
                    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[location objectForKey:@"lat"] doubleValue], [[location  objectForKey:@"lng"] doubleValue]);
                    NSString* cemeteryReference = [cemetery objectForKey:@"reference"];
                    
                    PFObject* grave = [PFObject objectWithClassName:@"Grave"];
                    grave[@"firstName"] = [firstName lowercaseString];
                    grave[@"lastName"] = [lastName lowercaseString];
                    grave[@"fullName"] = fullName;
                    grave[@"deceasedYear"] = deceasedYear;
                    
                    UIImage* image = [photoButton backgroundImageForState:UIControlStateNormal];
                    if (image) {
                        grave[@"hasImage"] = @1;
                    } else {
                        grave[@"hasImage"] = @0;
                    }
                    
                    // Resize image
                    UIGraphicsBeginImageContext(CGSizeMake(640, 960));
                    [image drawInRect: CGRectMake(0, 0, 640, 960)];
                    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    NSData *data = UIImageJPEGRepresentation(smallImage, 0.05f);
                    
                    CFUUIDRef uuid = CFUUIDCreate(NULL);
                    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
                    CFRelease(uuid);
                    PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@.jpeg", uuidStr] data:data];
                    [grave setObject:imageFile forKey:@"imageFile"];                    grave[@"cemeteryName"] = name;
                    grave[@"cemeteryLat"] = [NSNumber numberWithDouble:coordinate.latitude];
                    grave[@"cemeteryLon"] = [NSNumber numberWithDouble:coordinate.longitude];
                    grave[@"cemeteryRef"] = cemeteryReference;
                    //                    [DataSingleton setGrave:grave];
                    // [grave saveEventually];
                    [grave saveInBackground];
                } afterEverythingBlock:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HIDE_LOADING
                        [self back:nil];
                    });
                }];
            }
        } else {
            SHOW_LOADING(@"Searching")
            PFQuery* query = [PFQuery queryWithClassName:@"Grave"];
            if (![firstName isEqualToString:@""]) {
                [query whereKey:@"firstName" equalTo:firstName];
            }
            if (![lastName isEqualToString:@""]) {
                [query whereKey:@"lastName" equalTo:lastName];
            }
            if (![deceasedYear isEqualToString:@""]) {
                [query whereKey:@"deceasedYear" equalTo:deceasedYear];
            }
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    HIDE_LOADING
                });
                if (!error) {
                    [DataSingleton setGraves:objects];
                    // The find succeeded.
                    if (objects.count == 1) {
                        PFObject* grave = (PFObject *)[objects firstObject];
                        [DataSingleton setGrave:grave];
                        CLLocation* cLocation = [[CLLocation alloc] initWithLatitude:[[grave objectForKey:@"cemeteryLat"] doubleValue] longitude:[[grave objectForKey:@"cemeteryLon"] doubleValue]];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                            [(GraveFinderViewController *)self.presentingViewController showDirectionsToLocation:cLocation];
                        });
                    } else if (objects.count > 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                            [(GraveFinderViewController *)self.presentingViewController showListOfGraves:objects];
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There are no graves with that name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        });
                    }
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
    }
}

- (IBAction)back:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)takePhoto:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.videoQuality = UIImagePickerControllerQualityTypeLow;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (IBAction)returnPicker:(id)sender {
    [deceasedTextField resignFirstResponder];
    activeTextField = nil;
}

- (IBAction)doneClicked:(id)sender {
    [self returnPicker:sender];
    UIPickerView* pickerView = (UIPickerView *)deceasedTextField.inputView;
    long selected = [pickerView selectedRowInComponent:0];
    if (selected > 0) {
        deceasedTextField.text = [NSString stringWithFormat:@"%ld", [pickerView selectedRowInComponent:0] + firstYear - 1];
    } else {
        deceasedTextField.text = @"";
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage* img = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (img) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGPoint center = photoButton.center;
            CGRect frame = photoButton.frame;
            double ratio = img.size.height/img.size.width;
            if (ratio > 1) {
                frame.size.width = frame.size.height / ratio;
            } else {
                frame.size.height = frame.size.width * ratio;
            }
            photoButton.frame = frame;
            photoButton.center = center;
            [photoButton setBackgroundImage:img forState:UIControlStateNormal];
            [photoButton setTitle:@"" forState:UIControlStateNormal];
        });
    }
}

- (IBAction)clear:(id)sender {
    firstNameTextField.text = @"";
    lastNameTextField.text = @"";
    deceasedTextField.text = @"";
    
    [photoButton setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
    CGRect frame = photoButton.frame;
    frame.size.height = 126;
    frame.size.width = 126;
    photoButton.frame = frame;
    [photoButton setTitle:@"Set Photo" forState:UIControlStateNormal];
}

- (NSURL *)placeDetailsUrlForReference:(NSString *)reference
{
    // https://maps.googleapis.com/maps/api/place/details/output?parameters
    
    NSMutableString* urlString = [NSMutableString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?key=%s", GOOGLE_PLACES_API_KEY];
    [urlString appendFormat:@"&reference=%@", reference];
    
    // NSLog(@"url: %@", urlString);
    
    return [NSURL URLWithString:urlString];
}

@end
