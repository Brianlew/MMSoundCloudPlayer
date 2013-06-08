//
//  PlaySoundViewController.h
//  MMSoundCloudPlayer
//
//  Created by Brian Lewis on 6/8/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaySoundViewController : UIViewController

@property NSInteger durationInMilliseconds;
@property (strong, nonatomic) NSURL *streamUrl;


@property (weak, nonatomic) IBOutlet UISlider *soundCurrentPositionOutlet;
- (IBAction)playSound:(id)sender;
- (IBAction)pauseSound:(id)sender;
- (IBAction)seek:(id)sender;
@end
