//
//  VEPreviewView.h
//  VideoEditor2
//
//  Created by Sukrit Sunama on 2/23/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VEPreviewViewController;

@interface VEPreviewView : UIImageView {
    VEPreviewViewController *controller;
}

@property (nonatomic, strong) VEPreviewViewController *controller;

@end
