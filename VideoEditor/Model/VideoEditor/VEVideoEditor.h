//
//  VideoEditor.h
//  VideoEditor2
//
//  Created by Sukrit Sunama on 1/31/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "VEVideoEditorDelegate.h"

@class VEPreviewViewController, VEVideoComposition, VEAudioComposition, VEVideoComponent, VETimer;

@interface VEVideoEditor : NSObject {
    id <VEVideoEditorDelegate> delegate;
    VEPreviewViewController *previewViewController;
    VEVideoComposition *videoComposition;
    VEAudioComposition *audioComposition;
    
    NSString *encode;
    CGSize size;
    double duration;
    double fps;
    
    BOOL isProcessing;
    long currentFrame;
    double previewTime;
    
    AVAssetWriter *assetWriter;
    NSOperationQueue *videoEncodingOperationQueue;
    CVPixelBufferRef buffers[30];
    
    VETimer *decodingTimer;
    VETimer *encodingTimer;
    VETimer *convertingImageTimer;
    VETimer *rotateVideoTimer;
    VETimer *drawImageTimer;
    VETimer *createImageTimer;
    VETimer *rotateImageTimer;
}

@property (nonatomic, strong) id <VEVideoEditorDelegate> delegate;
@property (nonatomic, strong) VEPreviewViewController *previewViewController;
@property (nonatomic, strong) VEVideoComposition *videoComposition;
@property (nonatomic, strong) VEAudioComposition *audioComposition;

@property (nonatomic, strong) NSString *encode;
@property (nonatomic, setter = setSize:) CGSize size;
@property double duration;
@property double fps;

@property (readonly) BOOL isProcessing;
@property (readonly) long currentFrame;
@property (readonly) double previewTime;

@property (nonatomic, strong) AVAssetWriter *assetWriter;

@property (nonatomic, strong) VETimer *decodingTimer;
@property (nonatomic, strong) VETimer *encodingTimer;
@property (nonatomic, strong) VETimer *convertingImageTimer;
@property (nonatomic, strong) VETimer *rotateVideoTimer;
@property (nonatomic, strong) VETimer *drawImageTimer;
@property (nonatomic, strong) VETimer *createImageTimer;
@property (nonatomic, strong) VETimer *rotateImageTimer;

- (id)initWithURL:(NSURL *)url;
- (id)initWithPath:(NSString *)path;
- (id)initWithSize:(CGSize)_size fps:(double)_fps;
- (void)setSize:(CGSize)_size;
- (void)exportToURL:(NSURL *)url;
- (void)exportToPath:(NSString *)path;
- (void)previewAtTime:(double)time;
- (void)previewUpdateOnlyComponent:(VEVideoComponent *)component;
- (void)dispose;

@end
