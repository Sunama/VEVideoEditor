//
//  PerformanceViewController.h
//  VideoEditor
//
//  Created by Sukit Sunama on 12/19/2557 BE.
//  Copyright (c) 2557 Afternoon Tea Break. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VE.h"

@interface PerformanceViewController : UIViewController <VEVideoEditorDelegate> {
    IBOutlet UITextView *processTextView;
    
    VEVideoEditor *videoEditor;
    NSDate *startDate;
    
    NSMutableArray *memories;
    float sumUsedMemory;
    float samplingTime;
    
    int sample;
    int experiments;
    int method;
    
    NSMutableArray *samplePaths;
}

@property (nonatomic, retain) VEVideoEditor *videoEditor;

@end
