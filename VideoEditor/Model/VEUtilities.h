//
//  VEUtilities.h
//  VideoEditor2
//
//  Created by Sukrit Sunama on 2/4/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VEUtilities : NSObject

+ (NSString *)bundlePath:(NSString *)fileName;
+ (NSString *)documentsPath:(NSString *)fileName;
+ (NSString *)urlBundlePath:(NSString *)fileName;
+ (NSURL *)urlDocumentsPath:(NSString *)fileName;
+ (NSString *)convertPathFromURL:(NSURL *)url;
+ (NSURL *)convertURLFromPath:(NSString *)path;

+ (void)removeFileAtURL:(NSURL *)url;

+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image;

+ (CGImageRef)imageByRotatingImage:(CGImageRef)imgRef fromImageOrientation:(UIImageOrientation)orientation;
+ (void)drawImage:(CGImageRef)image toContext:(CGContextRef)context withOrientation:(UIImageOrientation)orientation;
+ (void)applyTransformToContext:(CGContextRef)context withOrientation:(UIImageOrientation)orientation andSize:(CGSize)size;

+ (void)saveImage:(CGImageRef)image atDocumentPath:(NSString *)path;

@end
