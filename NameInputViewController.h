//
//  NameInputViewController.h
//  GraveFinder
//
//  Created by ICharny on 11/18/14.
//
//

#import <UIKit/UIKit.h>
#import "GooglePlacesUtils.h"

#define SHOW_LOADING(msg) \
    UIActionSheet* actionSheetLoad = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@...Please wait", msg] delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil]; \
    [actionSheetLoad showInView:self.view];

#define HIDE_LOADING \
    [actionSheetLoad dismissWithClickedButtonIndex:0 animated:YES]; 

typedef enum {
    kFind,
    kSave
} NameInputType;

@interface NameInputViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    UITextField* activeTextField;
    IBOutlet UIScrollView* scrollView;
    IBOutlet UIView* photoView;
    IBOutlet UITextField* firstNameTextField;
    IBOutlet UITextField* lastNameTextField;
    IBOutlet UITextField* deceasedTextField;
    IBOutlet UIButton* goButton;
    IBOutlet UIButton* photoButton;
    NameInputType type;
    BOOL setup;
    BOOL keyboardShowing;
    CGRect orgFrame;
}

@property(nonatomic, strong) UITextField* activeTextField;
@property(nonatomic) NameInputType type;
@property(nonatomic) BOOL setup;
@property(nonatomic) CGRect orgFrame;

- (instancetype)initWithType:(NameInputType)type;
- (IBAction)find:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (IBAction)doneClicked:(id)sender;
- (IBAction)returnPicker:(id)sender;
- (IBAction)clear:(id)sender;

@end
