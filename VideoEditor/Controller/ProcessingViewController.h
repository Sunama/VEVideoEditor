//
//  ProcessingViewController.h
//  VideoEditor
//
//  Created by Apple Macintosh on 7/11/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VE.h"

@interface ProcessingViewController : UIViewController <VEVideoEditorDelegate, UIAlertViewDelegate>  {
    IBOutlet UIProgressView *progressView;
    IBOutlet UILabel *progressLabel;
    
    UIAlertView *informationAlertView;
    
    VEVideoEditor *videoEditor;
    NSDate *startDate;
    NSInteger progressCount;
}

@property (nonatomic, retain) VEVideoEditor *videoEditor;

@end
