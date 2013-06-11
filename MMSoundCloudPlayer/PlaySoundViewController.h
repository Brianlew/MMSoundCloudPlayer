//
//  PlaySoundViewController.h
//  MMSoundCloudPlayer
//
//  Created by Brian Lewis on 6/8/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "RetainPlaySoundViewControllerProtocol.h"

@interface PlaySoundViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) AVPlayer *musicPlayer;

@property (strong, nonatomic) NSArray *playlistArray;
@property NSInteger currentIndex;

@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet UIView *waveformProgressBar;
@property (weak, nonatomic) IBOutlet UIView *waveformView;
@property (weak, nonatomic) IBOutlet UIImageView *waveformShapeView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (strong, nonatomic) id<RetainPlaySoundViewControllerProtocol> delegate;


- (IBAction)playSound:(id)sender;
- (IBAction)pauseSound:(id)sender;
- (IBAction)skipToPreviousSong:(id)sender;
- (IBAction)skipToNextSong:(id)sender;
- (IBAction)backToSearchResults:(id)sender;
@end
