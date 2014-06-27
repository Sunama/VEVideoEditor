//
//  VideoComponent.h
//  VideoEditor2
//
//  Created by Sukrit Sunama on 1/31/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class VEVideoComposition;

@interface VEVideoComponent : NSObject {
    VEVideoComposition *composition;
    
    UIView *view;
    double presentTime;
    double duration;
    
    CGImageRef previousImage;
    BOOL isEnterScene;
}

@property (nonatomic, strong) VEVideoComposition *composition;

@property (nonatomic, strong) UIView *view;
@property (nonatomic, setter = setPresentTime:) double presentTime;
@property (nonatomic, setter = setDuration:) double duration;
@property (readonly) CGImageRef previousImage;

- (id)initWithView:(UIView *)_view;

- (void)setPresentTime:(double)_presentTime;
- (void)setDuration:(double)_duration;

- (void)beginExport;
- (void)finishExport;
- (CGImageRef)frameImageAtTime:(double)time;
- (CGImageRef)nextFrameImage;

- (BOOL)updateAtTime:(double)time;
- (BOOL)updateNextFrame;
- (void)dispose;

@end
