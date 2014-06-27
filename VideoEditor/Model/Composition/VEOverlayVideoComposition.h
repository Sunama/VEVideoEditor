//
//  VEOverlayVideoComposition.h
//  VideoEditor
//
//  Created by Apple Macintosh on 4/17/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import "VEVideoComposition.h"

@interface VEOverlayVideoComposition : VEVideoComposition {
    UIView *view;
    CGImageRef previousImage;
    
    UIImageOrientation previewOrientation;
    UIImageOrientation overlayOrientation;
    
    NSInteger previousSplited;
}

@property (nonatomic, strong, setter = setEditor:) VEVideoEditor *editor;

- (void)setEditor:(VEVideoEditor *)_editor;

@end
