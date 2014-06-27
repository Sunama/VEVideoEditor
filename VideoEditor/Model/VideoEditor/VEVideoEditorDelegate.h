//
//  VEVideoEditorDelegate.h
//  VideoEditor
//
//  Created by Apple Macintosh on 7/11/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VEVideoEditor;

@protocol VEVideoEditorDelegate <NSObject>

- (void)videoEditor:(VEVideoEditor *)videoEditor exportFinishWithError:(NSError *)error;
- (void)videoEditor:(VEVideoEditor *)videoEditor progressTo:(double)progress;

@end