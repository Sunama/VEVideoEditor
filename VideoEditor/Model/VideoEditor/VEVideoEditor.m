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
#import "VETimer.h"

@implementation VEVideoEditor

@synthesize delegate, previewViewController, videoComposition, audioComposition, encode, size, duration, fps, isProcessing, currentFrame, previewTime, assetWriter, decodingTimer, encodingTimer, convertingImageTimer, rotateImageTimer, drawImageTimer, rotateVideoTimer, createImageTimer;

- (id)init {
    self = [super init];
    
    if (self) {
        videoComposition = [[VEVideoComposition alloc] init];
        audioComposition = [[VEAudioComposition alloc] init];
        previewViewController = [[VEPreviewViewController alloc] init];
        
        videoComposition.editor = self;
        audioComposition.editor = self;
        previewViewController.editor = self;
        
        encodingTimer = [[VETimer alloc] init];
        decodingTimer = [[VETimer alloc] init];
        convertingImageTimer = [[VETimer alloc] init];
        rotateVideoTimer = [[VETimer alloc] init];
        drawImageTimer = [[VETimer alloc] init];
        createImageTimer = [[VETimer alloc] init];
        rotateImageTimer = [[VETimer alloc] init];
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
    [self exportStandardMethodToURL:url];
}

- (void)exportStandardMethodToURL:(NSURL *)url {
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
            
            [encodingTimer startProcess];
            
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
            
            [encodingTimer endProcess];
            
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
                            NSLog(@"\n%.0f\n%.0f\n%.0f\n%.0f\n%.0f\n%.0f\n%.0f", decodingTimer.totalTime, convertingImageTimer.totalTime, rotateVideoTimer.totalTime, createImageTimer.totalTime, rotateImageTimer.totalTime, drawImageTimer.totalTime, encodingTimer.totalTime);
                            
                            [delegate videoEditor:self exportFinishWithError:nil];
                            
                            NSLog(@"Decoding = %.0f, %.0f", decodingTimer.averageTime, decodingTimer.totalTime);
                            NSLog(@"Converting Image = %.0f, %.0f", convertingImageTimer.averageTime, convertingImageTimer.totalTime);
                            NSLog(@"Rotate Video = %.0f, %.0f", rotateVideoTimer.averageTime, rotateVideoTimer.totalTime);
                            NSLog(@"Create Image = %.0f, %.0f", createImageTimer.averageTime, createImageTimer.totalTime);
                            NSLog(@"Rotate Image = %.0f, %.0f", rotateImageTimer.averageTime, rotateImageTimer.totalTime);
                            NSLog(@"Draw Image = %.0f, %.0f", drawImageTimer.averageTime, drawImageTimer.totalTime);
                            NSLog(@"Encoding = %.0f, %.0f", encodingTimer.averageTime, encodingTimer.totalTime);
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

- (void)exportMultiThreadMethodToURL:(NSURL *)url {
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
    
    videoEncodingOperationQueue = [[NSOperationQueue alloc] init];
    videoEncodingOperationQueue.name = @"Video Encoding";
    
    __block int decodePointer = 0;
    __block int decodeCurrentFrame = 0;
    __block int encodePointer = 0;
    __block int encodeCurrentFrame = 0;
    
    [videoEncodingOperationQueue addOperationWithBlock:^{
        while (decodeCurrentFrame < duration * fps) {
            while (decodeCurrentFrame - encodeCurrentFrame > 29) {
                usleep(1);
            }
            
            CGImageRef image = [videoComposition nextFrameImage];
            buffers[decodePointer] = [VEUtilities pixelBufferFromCGImage:image];
            
            CGImageRelease(image);
            
            currentFrame++;
            decodeCurrentFrame++;
            decodePointer++;
            if (decodePointer > 29) {
                decodePointer = 0;
            }
        }
    }];
    
    //Write Video
    dispatch_queue_t videoQueue = dispatch_queue_create("Wite Video", NULL);
    
    [assetWriterVideoInput requestMediaDataWhenReadyOnQueue:videoQueue usingBlock:^{
        
        while ([assetWriterVideoInput isReadyForMoreMediaData]) {
            while (encodeCurrentFrame >= decodeCurrentFrame && encodeCurrentFrame < duration * fps) {
                usleep(1);
            }
            
            [encodingTimer startProcess];
            
            CVPixelBufferRef buffer = buffers[encodePointer];
            
            if (![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(encodeCurrentFrame, fps)]) {
                isProcessing = NO;
                NSMutableDictionary *info = [NSMutableDictionary dictionary];
                [info setValue:[NSString stringWithFormat:@"Cannon append pixel buffer at frame %d (%.2fs)", encodeCurrentFrame, CMTimeGetSeconds(CMTimeMake(encodeCurrentFrame, fps))] forKey:NSLocalizedDescriptionKey];
                NSError *error = [[NSError alloc] initWithDomain:@"VideoEditor" code:2 userInfo:info];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [delegate videoEditor:self exportFinishWithError:error];
                });
            }
            
            
            CVPixelBufferRelease(buffer);
            
            [encodingTimer endProcess];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate videoEditor:self progressTo:encodeCurrentFrame / (duration * fps)];
            });
            
            encodeCurrentFrame++;
            
            encodePointer++;
            if (encodePointer > 29) {
                encodePointer = 0;
            }
            
            if (encodeCurrentFrame >= duration * fps) {
                [assetWriterVideoInput markAsFinished];
                
                isFinishVideo = YES;
                
                if (isFinishAudio) {
                    isProcessing = NO;
                    [assetWriter endSessionAtSourceTime:CMTimeMakeWithSeconds(duration, fps)];
                    
                    [assetWriter finishWritingWithCompletionHandler:^ {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [delegate videoEditor:self exportFinishWithError:nil];
                            
                            NSLog(@"Decoding = %.0f, %.0f", decodingTimer.averageTime, decodingTimer.totalTime);
                            NSLog(@"Converting Image = %.0f, %.0f", convertingImageTimer.averageTime, convertingImageTimer.totalTime);
                            NSLog(@"Rotate Video = %.0f, %.0f", rotateVideoTimer.averageTime, rotateVideoTimer.totalTime);
                            NSLog(@"Create Image = %.0f, %.0f", createImageTimer.averageTime, createImageTimer.totalTime);
                            NSLog(@"Rotate Image = %.0f, %.0f", rotateImageTimer.averageTime, rotateImageTimer.totalTime);
                            NSLog(@"Draw Image = %.0f, %.0f", drawImageTimer.averageTime, drawImageTimer.totalTime);
                            NSLog(@"Encoding = %.0f, %.0f", encodingTimer.averageTime, encodingTimer.totalTime);
                        });
                    }];
                    
                    break;
                }
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
