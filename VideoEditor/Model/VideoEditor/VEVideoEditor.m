//
//  VideoEditor.m
//  VideoEditor2
//
//  Created by Sukrit Sunama on 1/31/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import "VEVideoEditor.h"
#import "VEVideoEditorDelegate.h"
#import "VEPreviewViewController.h"
#import "VEVideoComposition.h"
#import "VEAudioComposition.h"
#import "VEUtilities.h"
#import "VEVideoTrack.h"
#import "VEAudioComponent.h"

@implementation VEVideoEditor

@synthesize delegate, previewViewController, videoComposition, audioComposition, encode, size, duration, fps, isProcessing, currentFrame, previewTime, assetWriter;

- (id)init {
    self = [super init];
    
    if (self) {
        videoComposition = [[VEVideoComposition alloc] init];
        audioComposition = [[VEAudioComposition alloc] init];
        previewViewController = [[VEPreviewViewController alloc] init];
        
        videoComposition.editor = self;
        audioComposition.editor = self;
        previewViewController.editor = self;
    }
    
    return self;
}

- (id)initWithURL:(NSURL *)url {
    self = [self init];
    
    if (self) {
        //Video
        VEVideoTrack *videoTrack = [[VEVideoTrack alloc] initWithURL:url];
        
        [videoComposition addComponent:videoTrack];
        size = videoTrack.size;
        fps = videoTrack.fps;
        
        //Audio
        VEAudioComponent *audioComponent = [[VEAudioComponent alloc] initWithURL:url];
        
        [audioComposition addComponent:audioComponent];
    }
    
    return self;
}

- (id)initWithPath:(NSString *)path {
    return [self initWithURL:[VEUtilities convertURLFromPath:path]];
}

- (id)initWithSize:(CGSize)_size fps:(double)_fps {
    self = [super init];
    
    if (!self) {
        
    }
    
    return self;
}

- (void)exportToURL:(NSURL *)url {
    [VEUtilities removeFileAtURL:url];
    isProcessing =  YES;
    
    NSError *error = nil;
    assetWriter = [[AVAssetWriter alloc] initWithURL:url fileType:AVFileTypeQuickTimeMovie error:&error];
    NSParameterAssert(assetWriter);
    assetWriter.shouldOptimizeForNetworkUse = NO;
    
    //Video
    if ([encode length] == 0) {
        encode = AVVideoCodecH264;
    }
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   encode, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput *assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    assetWriterVideoInput.expectsMediaDataInRealTime = YES;
    
    /*
     if (orientation == UIImageOrientationUp) {
     assetWriterVideoInput.transform = CGAffineTransformMake(0, 1.0, -1.0, 0, size.width, 0);
     }
     else if (orientation == UIImageOrientationDown) {
     assetWriterVideoInput.transform = CGAffineTransformMake(0, -1.0, 1.0, 0, 0, size.width);
     }
     else if (orientation == UIImageOrientationLeft) {
     assetWriterVideoInput.transform = CGAffineTransformMake(1.0, 0, 0, 1.0, 0, 0);
     }
     else if (orientation == UIImageOrientationRight) {
     assetWriterVideoInput.transform = CGAffineTransformMake(-1.0, 0, 0, -1.0, size.width, size.height);
     }
     */
    
    NSDictionary *bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey, nil];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:assetWriterVideoInput sourcePixelBufferAttributes:bufferAttributes];
    
    NSParameterAssert(assetWriterVideoInput);
    NSParameterAssert([assetWriter canAddInput:assetWriterVideoInput]);
    [assetWriter addInput:assetWriterVideoInput];
    
    //Audio
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    
    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                   [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                   [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                   [NSData dataWithBytes:&channelLayout length: sizeof(AudioChannelLayout) ], AVChannelLayoutKey,
                                   [NSNumber numberWithInt:64000], AVEncoderBitRateKey,
                                   nil];
    AVAssetWriterInput *assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
    NSParameterAssert(assetWriterAudioInput);
    NSParameterAssert([assetWriter canAddInput:assetWriterAudioInput]);
    [assetWriter addInput:assetWriterAudioInput];
    
    if (![assetWriter startWriting]) {
        isProcessing = NO;
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setValue:[NSString stringWithFormat:@"Cannot to start writing for reason : %@", error.localizedDescription] forKey:NSLocalizedDescriptionKey];
        NSError *error = [[NSError alloc] initWithDomain:@"VideoEditor" code:1 userInfo:info];
        
        [delegate videoEditor:self exportFinishWithError:error];
    }
    [assetWriter startSessionAtSourceTime:kCMTimeZero];
    
    [videoComposition beginExport];
    [audioComposition beginExport];
    
    currentFrame = 0;
    __block BOOL isFinishVideo = NO;
    __block BOOL isFinishAudio = NO;
    
    //Write Video
    dispatch_queue_t videoQueue = dispatch_queue_create("Wite Video", NULL);
    
    [assetWriterVideoInput requestMediaDataWhenReadyOnQueue:videoQueue usingBlock:^{
        
        while ([assetWriterVideoInput isReadyForMoreMediaData]) {
            CGImageRef image = [videoComposition nextFrameImage];
            CVPixelBufferRef buffer = [VEUtilities pixelBufferFromCGImage:image];
            
            if (![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(currentFrame, fps)]) {
                isProcessing = NO;
                NSMutableDictionary *info = [NSMutableDictionary dictionary];
                [info setValue:[NSString stringWithFormat:@"Cannon append pixel buffer at frame %ld (%.2fs)", currentFrame, CMTimeGetSeconds(CMTimeMake(currentFrame, fps))] forKey:NSLocalizedDescriptionKey];
                NSError *error = [[NSError alloc] initWithDomain:@"VideoEditor" code:2 userInfo:info];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate videoEditor:self exportFinishWithError:error];
                });
            }
            
            CGImageRelease(image);
            CVPixelBufferRelease(buffer);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate videoEditor:self progressTo:currentFrame / (duration * fps)];
            });
            
            currentFrame++;
            
            if (currentFrame >= duration * fps) {
                [assetWriterVideoInput markAsFinished];
                
                isFinishVideo = YES;
                
                if (isFinishAudio) {
                    isProcessing = NO;
                    [assetWriter endSessionAtSourceTime:CMTimeMakeWithSeconds(duration, fps)];
                    
                    [assetWriter finishWritingWithCompletionHandler:^ {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [delegate videoEditor:self exportFinishWithError:nil];
                        });
                    }];
                }
                
                break;
            }
        }
    }];
    
    //Write Audio
    dispatch_queue_t audioQueue = dispatch_queue_create("Wite Audio", NULL);
    
    [assetWriterAudioInput requestMediaDataWhenReadyOnQueue:audioQueue usingBlock:^ {
        while(assetWriterAudioInput.readyForMoreMediaData)
        {
            CMSampleBufferRef nextBuffer = [audioComposition nextSampleBuffer];
            if(nextBuffer != NULL) {
                //append buffer
                [assetWriterAudioInput appendSampleBuffer:nextBuffer];
            }
            else {
                [assetWriterAudioInput markAsFinished];
                
                isFinishAudio = YES;
                
                if (isFinishVideo) {
                    isProcessing = NO;
                    [assetWriter endSessionAtSourceTime:CMTimeMakeWithSeconds(duration, fps)];
                    [assetWriter finishWritingWithCompletionHandler:^ {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [delegate videoEditor:self exportFinishWithError:nil];
                        });
                    }];
                }
                
                break;
            }
        }
    }];
}

- (void)exportToPath:(NSString *)path{
    
}

- (void)setSize:(CGSize)_size {
    size = _size;
    
    previewViewController.view.frame = previewViewController.view.frame;
}

- (void)previewAtTime:(double)time {
    previewTime = time;
    CGImageRef image = [videoComposition frameImageAtTime:time];
    ((UIImageView *)previewViewController.view).image = [UIImage imageWithCGImage:image];
    
    CGImageRelease(image);
}

- (void)previewUpdateOnlyComponent:(VEVideoComponent *)component {
    CGImageRef image = [videoComposition frameImageUpdateOnlyComponent:component];
    ((UIImageView *)previewViewController.view).image = [UIImage imageWithCGImage:image];
    
    CGImageRelease(image);
}

- (void)dispose {
    [videoComposition dispose];
}

@end
