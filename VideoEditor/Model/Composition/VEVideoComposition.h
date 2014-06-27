//
//  VideoComposition.h
//  VideoEditor2
//
//  Created by Sukrit Sunama on 1/31/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class VEVideoComponent, VEVideoEditor;

@interface VEVideoComposition : NSObject {
    VEVideoEditor *editor;
    NSMutableArray *components;
    
    NSMutableArray *spliteTime;
    NSMutableArray *currentComponents;
    NSInteger currentSplited;
}

@property (nonatomic, strong, setter = setEditor:) VEVideoEditor *editor;
@property (nonatomic, strong) NSMutableArray *components;

- (void)addComponent:(VEVideoComponent *)component;
- (void)removeComponent:(VEVideoComponent *)component;
- (void)removeAllComponents;
- (void)removeAllComponentsExceptVideoTrack;
- (void)bringToFront:(VEVideoComponent *) component;
- (void)sendToBack:(VEVideoComponent *) component;
- (void)rearrangeComponent:(VEVideoComponent *) component To:(int)index;
- (void)calculateDuration;

- (NSArray *)componentsAtTime:(double)time;
- (NSArray *)componentsAtFrame:(long)frame;
- (void)spliteComponent;

- (void)beginExport;
- (CGImageRef)frameImageAtTime:(double)time;
- (CGImageRef)frameImageUpdateOnlyComponent:(VEVideoComponent *)component;
- (CGImageRef)nextFrameImage;
- (BOOL)updateAtTime:(double)time;
- (void)dispose;

@end
