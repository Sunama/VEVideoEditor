//
//  VEOverlayVideoComposition.m
//  VideoEditor
//
//  Created by Apple Macintosh on 4/17/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import "VEOverlayVideoComposition.h"
#import "VEVideoComponent.h"
#import "VEOverlayVideoEditor.h"
#import "VEUtilities.h"
#import "VEVideoTrack.h"

@implementation VEOverlayVideoComposition

- (id)init {
    self = [super init];
    
    if (self != nil) {
        view = [[UIView alloc] init];
    }
    
    return self;
}

- (void)setEditor:(VEVideoEditor *)_editor {
    editor = _editor;
    
    view.frame = CGRectMake(0.0f, 0.0f, editor.size.width, editor.size.height);
    
    CGAffineTransform transform = ((VEOverlayVideoEditor *)editor).transform;
    
    if (transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0) {
        NSLog(@"up");
        previewOrientation = UIImageOrientationLeftMirrored;
        overlayOrientation = UIImageOrientationLeft;
    }
    if (transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0) {
        NSLog(@"down");
        previewOrientation = UIImageOrientationRightMirrored;
        overlayOrientation = UIImageOrientationRight;
    }
    if (transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0) {
        NSLog(@"left");
        previewOrientation = UIImageOrientationUpMirrored;
        overlayOrientation = UIImageOrientationDown;
    }
    if (transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0) {
        NSLog(@"right");
        previewOrientation = UIImageOrientationDownMirrored;
        overlayOrientation = UIImageOrientationUp;
    }
}

- (void)addComponent:(VEVideoComponent *)component {
    [super addComponent:component];
    [view addSubview:component.view];
}

- (void)removeComponent:(VEVideoComponent *)component {
    [component.view removeFromSuperview];
    [super removeComponent:component];
}

- (void)removeAllComponents {
    for (VEVideoComponent *component in components) {
        [component.view removeFromSuperview];
    }
    
    [super removeAllComponents];
}

- (void)bringToFront:(VEVideoComponent *)component {
    if ([components indexOfObject:component] != NSNotFound) {
        [super bringToFront:component];
        
        [component.view removeFromSuperview];
        [view addSubview:component.view];
    }
}

- (void)sendToBack:(VEVideoComponent *)component {
    if ([components indexOfObject:component] != NSNotFound) {
        [super sendToBack:component];
        
        [component.view removeFromSuperview];
        [view insertSubview:component.view atIndex:0];
    }
}

- (void)rearrangeComponent:(VEVideoComponent *)component To:(int)index {
    if ([components indexOfObject:component] != NSNotFound) {
        [super rearrangeComponent:component To:index];
        
        [component.view removeFromSuperview];
        [view insertSubview:component.view atIndex:index];
    }
}

- (void)calculateDuration {
    previousSplited = -2;
}

- (void)beginExport {
    view.frame = CGRectMake(0.0f, 0.0f, editor.size.width, editor.size.height);
    previousSplited = -2;
    
    [super beginExport];
}

- (CGImageRef)nextFrameImage {
    NSArray *nextComponents = [self componentsAtTime:CMTimeGetSeconds(((VEOverlayVideoEditor *)editor).presentationTime)];
    BOOL isUpdate = NO;
    
    if (previousSplited != currentSplited) {
        for (NSNumber *time in spliteTime) {
        }
        
        for (UIView *subview in view.subviews) {
            [subview removeFromSuperview];
        }
        
        for (VEVideoComponent *component in nextComponents) {
            [view addSubview:component.view];
        }
    }
    
    for (VEVideoComponent *component in nextComponents) {
        if ([component updateNextFrame]) {
            isUpdate = YES;
        }
    }
    
    if (isUpdate || previousSplited != currentSplited) {
        CGImageRelease(previousImage);
        
        UIGraphicsBeginImageContext(view.frame.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        if (overlayOrientation == UIImageOrientationUp || overlayOrientation == UIImageOrientationDown) {
            [VEUtilities applyTransformToContext:context withOrientation:overlayOrientation andSize:view.frame.size];
        }
        
        [view.layer renderInContext:context];
        previousImage = CGBitmapContextCreateImage(context);
        UIGraphicsEndImageContext();
        
        if (overlayOrientation == UIImageOrientationLeft || overlayOrientation == UIImageOrientationRight) {
            previousImage = [VEUtilities imageByRotatingImage:previousImage fromImageOrientation:overlayOrientation];
        }
        
        previousSplited = currentSplited;
    }
    
    return previousImage;
}

- (CGImageRef)frameImageAtTime:(double)time {
    NSArray *nextComponents = [self componentsAtTime:time];
    
    if (previousSplited != currentSplited) {
        for (NSNumber *time in spliteTime) {
        }
        
        for (UIView *subview in view.subviews) {
            [subview removeFromSuperview];
        }
        
        for (VEVideoComponent *component in nextComponents) {
            [view addSubview:component.view];
        }
    }
    
    for (VEVideoComponent *component in nextComponents) {
        [component updateAtTime:time];
    }
    
    //Video Image
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:((VEOverlayVideoEditor *)editor).inputAsset];
    generator.appliesPreferredTrackTransform = NO;
    CMTime thumbTime = CMTimeMakeWithSeconds(time, editor.fps);
    CGImageRef image = [generator copyCGImageAtTime:thumbTime actualTime:nil error:nil];
    //End
    
    UIGraphicsBeginImageContext(view.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [VEUtilities drawImage:image toContext:context withOrientation:previewOrientation];
    
    [VEUtilities applyTransformToContext:context withOrientation:previewOrientation andSize:editor.size];
    
    [view.layer renderInContext:context];
    
    CGImageRelease(image);
    image = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    
    return image;
}

@end
