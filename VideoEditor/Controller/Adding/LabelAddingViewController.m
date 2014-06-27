//
//  LabelAddingViewController.m
//  VideoEditor
//
//  Created by Apple Macintosh on 7/12/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import "LabelAddingViewController.h"
#import "VideoEditor.h"
#import "Utilities.h"

@interface LabelAddingViewController ()

@end

@implementation LabelAddingViewController

@synthesize videoEditor;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    timeSlider1.value = 0.0f;
    timeSlider2.value = 1.0f;
    xSlider.value = 0.0f;
    ySlider.value = 0.0f;
    
    [self timeSlider1ChangeValue:self];
    [self timeSlider2ChangeValue:self];
    [self xPositionChangeValue:self];
    [self yPositionChangeValue:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Action

- (IBAction)timeSlider1ChangeValue:(id)sender {
    double time = timeSlider1.value * videoEditor.duration;
    
    [videoEditor previewAtTime:time];
    timeLabel1.text = [Utilities minutesWithSeconds:time];
    timeCounterLabel1.text = [NSString stringWithFormat:@"- %@", [Utilities minutesWithSeconds:(videoEditor.duration - time)]];
}

- (IBAction)timeSlider2ChangeValue:(id)sender {
    double time = timeSlider2.value * videoEditor.duration;
    
    [videoEditor previewAtTime:time];
    timeLabel2.text = [Utilities minutesWithSeconds:time];
    timeCounterLabel2.text = [NSString stringWithFormat:@"- %@", [Utilities minutesWithSeconds:(videoEditor.duration - time)]];
}

- (IBAction)xPositionChangeValue:(id)sender {
    xTextField.text = [NSString stringWithFormat:@"%.0f", xSlider.value * videoEditor.size.width];
}

- (IBAction)yPositionChangeValue:(id)sender {
    yTextField.text = [NSString stringWithFormat:@"%.0f", ySlider.value * videoEditor.size.height];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xSlider.value * videoEditor.size.width, ySlider.value * videoEditor.size.height, 0.0f, 0.0f)];
    label.font = [UIFont fontWithName:label.font.fontName size:videoEditor.size.height * 0.2f];
    label.text = labelTextField.text;
    label.backgroundColor = [UIColor clearColor];
    
    CGSize labelSize = [labelTextField.text sizeWithFont:label.font];
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, labelSize.width, labelSize.height);
    
    VEVideoComponent *component = [[VEVideoComponent alloc] initWithView:label];
    
    double time1 = timeSlider1.value * videoEditor.duration;
    double time2 = timeSlider2.value * videoEditor.duration;
    
    if (timeSlider2.value < timeSlider1.value) {
        double timeTemp = time1;
        time1 = time2;
        time2 = timeTemp;
    }
    
    component.presentTime = time1;
    component.duration = time2 - time1;
    
    [videoEditor.videoComposition addComponent:component];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [videoEditor previewAtTime:videoEditor.previewTime];
    }];
}

@end
