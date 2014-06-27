//
//  VideoComponent.m
//  VideoEditor2
//
//  Created by Sukrit Sunama on 1/31/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import "VEVideoComponent.h"
#import "VEVideoComposition.h"
#import "VEVideoEditor.h"
#import "VEUtilities.h"

@implementation VEVideoComponent

@synthesize composition, view, presentTime, duration, previousImage;

- (id)initWithView:(UIView *)_view {
    self = [super init];
    
    if (self) {
        view =_view;
    }
    
    return self;
}

- (void)setPresentTime:(double)_presentTime {
    presentTime = _presentTime;
    [composition calculateDuration];
    [composition spliteComponent];
}

- (void)setDuration:(double)_duration {
    duration = _duration;
    [composition calculateDuration];
    [composition spliteComponent];
}

- (void)beginExport {
    
}

- (void)finishExport {
    CGImageRelease(previousImage);
}

- (CGImageRef)frameImageAtTime:(double)time {
    if ([self updateAtTime:time] || !previousImage) {
        UIGraphicsBeginImageContext(view.frame.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGAffineTransform transform = CGAffineTransformMakeTranslation(view.frame.size.width, 0.0);
        transform = CGAffineTransformScale(transform, -1.0, 1.0);
        CGContextScaleCTM(context, -1.0, -1.0);
        CGContextTranslateCTM(context, -view.frame.size.width, -view.frame.size.height);
        CGContextConcatCTM(context, transform);
        
        [view.layer renderInContext:context];
        CGImageRef image = CGBitmapContextCreateImage(context);
        UIGraphicsEndImageContext();
        
        previousImage = CGImageCreateCopy(image);
        
        return image;
    }
    else {
        return CGImageCreateCopy(previousImage);
    }
}

- (CGImageRef)nextFrameImage {
    return [self frameImageAtTime:(composition.editor.currentFrame / composition.editor.fps) - presentTime];
}

- (BOOL)updateAtTime:(double)time {
    if (!isEnterScene) {
        isEnterScene = YES;
        
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)updateNextFrame {
    return [self updateAtTime:(composition.editor.currentFrame / composition.editor.fps) - presentTime];
}

- (void)dispose {
    CGImageRelease(previousImage);
}

@end
