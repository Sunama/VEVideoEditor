//
//  VideoTrack.h
//  VideoEditor2
//
//  Created by Sukrit Sunama on 1/31/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import "VEVideoComponent.h"
#import <AVFoundation/AVFoundation.h>

@interface VEVideoTrack : VEVideoComponent {
    AVURLAsset *inputAsset;
    AVAssetReader *reader;
    AVAssetReaderTrackOutput *readerOutput;
    UIImageOrientation orientation;
    UIImageOrientation rotate;
    UIImageOrientation resultOrientation;
    
    double currentTime;
    
    CGSize size;
    double fps;
    
    double trimFromTime;
    double trimDuration;
}

@property (nonatomic, readonly) UIImageOrientation orientation;
@property (nonatomic, setter = setRotate:) UIImageOrientation rotate;

@property (readonly) CGSize size;
@property (readonly) double fps;

@property double trimFromTime;
@property double trimDuration;

- (id)initWithURL:(NSURL *)url;
- (id)initWithPath:(NSString *)path;

@end
