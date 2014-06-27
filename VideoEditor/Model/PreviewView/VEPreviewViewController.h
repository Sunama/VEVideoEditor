//
//  PreviewViewController.h
//  VideoEditor2
//
//  Created by Sukrit Sunama on 1/31/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VEVideoEditor;

@interface VEPreviewViewController : UIViewController {
    VEVideoEditor *editor;
    
    float imageRatio;
    CGRect imageRect;
}

@property (nonatomic, strong) VEVideoEditor *editor;
@property float imageRatio;
@property CGRect imageRect;

@end
