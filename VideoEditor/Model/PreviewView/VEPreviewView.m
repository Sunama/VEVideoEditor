//
//  VEPreviewView.m
//  VideoEditor2
//
//  Created by Sukrit Sunama on 2/23/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import "VEPreviewView.h"
#import "VEPreviewViewController.h"
#import "VEVideoEditor.h"

@implementation VEPreviewView

@synthesize controller;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CGSize size = frame.size;
    CGRect imageFrame;
	
	CGFloat imageRatio = size.width / size.height;
	CGFloat videoRatio = controller.editor.size.width / controller.editor.size.height;
	
	if (imageRatio < videoRatio) {
        imageFrame = CGRectMake(0, (size.height - (size.width / videoRatio)) / 2, size.width, (size.width / videoRatio));
    }
    else {
        imageFrame = CGRectMake((size.width - (videoRatio * size.height)) / 2, 0, (videoRatio * size.height), size.height);
    }
    
    controller.imageRect = imageFrame;
    controller.imageRatio = imageFrame.size.width / controller.editor.size.width;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    CGSize size = bounds.size;
    CGRect imageFrame;
	
	CGFloat imageRatio = size.width / size.height;
	CGFloat videoRatio = controller.editor.size.width / controller.editor.size.height;
	
	if (imageRatio < videoRatio) {
        imageFrame = CGRectMake(0, (size.height - (size.width / videoRatio)) / 2, size.width, (size.width / videoRatio));
    }
    else {
        imageFrame = CGRectMake((size.width - (videoRatio * size.height)) / 2, 0, (videoRatio * size.height), size.height);
    }
    
    controller.imageRect = imageFrame;
    controller.imageRatio = imageFrame.size.width / controller.editor.size.width;
}

@end
