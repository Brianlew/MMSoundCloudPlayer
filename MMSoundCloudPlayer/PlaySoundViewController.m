//
//  PlaySoundViewController.m
//  MMSoundCloudPlayer
//
//  Created by Brian Lewis on 6/8/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import "PlaySoundViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@interface PlaySoundViewController ()
{
    NSTimer *timerToUpdateSlider;
}

-(void)updateSoundProgressBar;
-(void)setUpGestureRecognizer;

@end

@implementation PlaySoundViewController

@synthesize musicPlayer, streamUrl, soundCurrentPositionOutlet, durationInMilliseconds, artworkImageView, artworkImage, waveformUrl, waveformProgressBar, waveformView;

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
    
 /*   if (musicPlayer != nil) {
        [musicPlayer replaceCurrentItemWithPlayerItem:[AVPlayer playerWithURL:streamUrl]];
    }
    else
    {
        musicPlayer = [AVPlayer playerWithURL:streamUrl];

    }*/
    
    [self setUpGestureRecognizer];
    
    artworkImageView.image = artworkImage;
    NSLog(@"Duration: %i", durationInMilliseconds);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpGestureRecognizer
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(seek:)];
    UITapGestureRecognizer *seekGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(seek:)];
    seekGesture.delegate = self;
   // seekGesture.maximumNumberOfTouches = 1;
   // seekGesture.minimumNumberOfTouches = 1;
    [waveformView addGestureRecognizer:seekGesture];
    [waveformView addGestureRecognizer:panGesture];

    
}

- (IBAction)playSound:(id)sender {
    timerToUpdateSlider = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateSoundProgressBar) userInfo:nil repeats:YES];
    [musicPlayer play];
}

- (IBAction)pauseSound:(id)sender {
    [musicPlayer pause];
    [timerToUpdateSlider invalidate];
}

- (IBAction)seek:(id)sender {
    
    CGPoint seekPosition = [waveformView.gestureRecognizers[0] locationInView:waveformView];
    
    UIPanGestureRecognizer *panGesture = waveformView.gestureRecognizers[1];
    
    if (panGesture.state == UIGestureRecognizerStateBegan || panGesture.state == UIGestureRecognizerStateChanged || panGesture.state == UIGestureRecognizerStateEnded) {
        seekPosition = [panGesture locationInView:waveformView];
    }
    
    [musicPlayer seekToTime:CMTimeMake(durationInMilliseconds*seekPosition.x/waveformView.frame.size.width, 1000)];

    NSLog(@"Seek Position x: %f", seekPosition.x);
    
    waveformProgressBar.frame = CGRectMake(waveformProgressBar.frame.origin.x, waveformProgressBar.frame.origin.y, seekPosition.x, waveformProgressBar.frame.size.height);
    
    NSLog(@"progress width: %f", waveformProgressBar.frame.size.width);
}

- (IBAction)backToSearchResults:(id)sender {
    
    [timerToUpdateSlider invalidate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateSoundProgressBar
{
    NSLog(@"current position: %f", soundCurrentPositionOutlet.value);
    
    waveformProgressBar.frame = CGRectMake(waveformView.frame.origin.x, waveformView.frame.origin.y, waveformProgressBar.frame.size.width + 1000.00*280/durationInMilliseconds, waveformView.frame.size.height);
    
}
@end
