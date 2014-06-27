//
//  VEOverlayVideoEditor.h
//  VideoEditor
//
//  Created by Apple Macintosh on 4/17/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import "VEVideoEditor.h"

@interface VEOverlayVideoEditor : VEVideoEditor {
    AVURLAsset *inputAsset;
    AVAssetReader *reader;
    AVAssetReaderTrackOutput *readerOutput;
    CGAffineTransform transform;
    UIImageOrientation orientation;
    UIView *view;
    CMTime presentationTime;
}

@property (nonatomic, strong) AVURLAsset *inputAsset;
@property CGAffineTransform transform;
@property CMTime presentationTime;

@end
