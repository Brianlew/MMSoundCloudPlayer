//
//  PlaySoundViewController.h
//  MMSoundCloudPlayer
//
//  Created by Brian Lewis on 6/8/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PlaySoundViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) AVPlayer *musicPlayer;

@property NSInteger durationInMilliseconds;
@property (strong, nonatomic) NSURL *streamUrl;
@property (strong, nonatomic) NSURL *waveformUrl;
@property (strong, nonatomic) UIImage *artworkImage;
@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet UIView *waveformProgressBar;
@property (weak, nonatomic) IBOutlet UIView *waveformView;
@property (weak, nonatomic) IBOutlet UIImageView *waveformShapeView;


- (IBAction)playSound:(id)sender;
- (IBAction)pauseSound:(id)sender;
- (IBAction)backToSearchResults:(id)sender;
@end
