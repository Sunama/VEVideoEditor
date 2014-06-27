//
//  LibraryViewController.h
//  VideoEditor
//
//  Created by Apple Macintosh on 7/14/56 BE.
//  Copyright (c) 2556 Afternoon Tea Break. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface LibraryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *videoTableView;
    
    NSMutableArray *videos;
    MPMoviePlayerViewController *moviePlayerController;
}

- (IBAction)back:(id)sender;

@end
