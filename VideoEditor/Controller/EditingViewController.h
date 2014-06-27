//
//  EditingViewController.h
//  VideoEditor
//
//  Created by Apple Macintosh on 7/11/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "VideoEditor.h"

@interface EditingViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    IBOutlet UIImageView *videoImageView;
    IBOutlet UIToolbar *toolBar;
    IBOutlet UISlider *timeSlider;
    IBOutlet UILabel *timeLabel;
    IBOutlet UILabel *timeCounterLabel;
    
    VEVideoEditor *videoEditor;
    UIActionSheet *componentActionSheet;
    UIImagePickerController *videoPickerViewController;
    UIAlertView *informationAlertView;
    
    double previewTime;
}

@property (nonatomic, retain) VEVideoEditor *videoEditor;

- (IBAction)back:(id)sender;
- (IBAction)addComponent:(id)sender;
- (IBAction)remove:(id)sender;
- (IBAction)process:(id)sender;
- (IBAction)timeSlide:(id)sender;

@end
