//
//  MainViewController.h
//  VideoEditor
//
//  Created by Apple Macintosh on 7/11/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface MainViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    IBOutlet UIButton *overlayButton;
    
    UIImagePickerController *videoPickerViewController;
    NSURL *url;
}

- (IBAction)overlay:(id)sender;

@end
