//
//  LabelAddingViewController.h
//  VideoEditor
//
//  Created by Apple Macintosh on 7/12/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VEVideoEditor;

@interface LabelAddingViewController : UIViewController {
    IBOutlet UITextField *labelTextField;
    IBOutlet UISlider *timeSlider1;
    IBOutlet UISlider *timeSlider2;
    IBOutlet UILabel *timeLabel1;
    IBOutlet UILabel *timeLabel2;
    IBOutlet UILabel *timeCounterLabel1;
    IBOutlet UILabel *timeCounterLabel2;
    IBOutlet UISlider *xSlider;
    IBOutlet UISlider *ySlider;
    IBOutlet UITextField *xTextField;
    IBOutlet UITextField *yTextField;
    
    VEVideoEditor *videoEditor;
}

@property (nonatomic, retain) VEVideoEditor *videoEditor;

- (IBAction)timeSlider1ChangeValue:(id)sender;
- (IBAction)timeSlider2ChangeValue:(id)sender;
- (IBAction)xPositionChangeValue:(id)sender;
- (IBAction)yPositionChangeValue:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
