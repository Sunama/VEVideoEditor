//
//  PreviewViewController.m
//  VideoEditor2
//
//  Created by Sukrit Sunama on 1/31/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import "VEPreviewViewController.h"
#import "VEPreviewView.h"

@interface VEPreviewViewController ()

@end

@implementation VEPreviewViewController

@synthesize editor, imageRatio, imageRect;

- (id)init {
    self = [super init];
    
    if (self) {
        self.view = [[VEPreviewView alloc] init];
        ((VEPreviewView *)self.view).controller = self;
        ((UIImageView *)self.view).contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
