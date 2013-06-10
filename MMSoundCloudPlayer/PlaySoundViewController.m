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

-(void)updateSoundProgressSlider;
@end

@implementation PlaySoundViewController

@synthesize musicPlayer, streamUrl, soundCurrentPositionOutlet, durationInMilliseconds, artworkImageView, artworkImage, waveformUrl, waveformProgressView;

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
    
    artworkImageView.image = artworkImage;
    NSLog(@"Duration: %i", durationInMilliseconds);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playSound:(id)sender {
    timerToUpdateSlider = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateSoundProgressSlider) userInfo:nil repeats:YES];
    [musicPlayer play];
}

- (IBAction)pauseSound:(id)sender {
    [musicPlayer pause];
    [timerToUpdateSlider invalidate];
}

- (IBAction)seek:(id)sender {
    CGFloat chosenPosition = soundCurrentPositionOutlet.value;
    NSLog(@"Chosen Position: %f", soundCurrentPositionOutlet.value);
    [musicPlayer seekToTime:CMTimeMake(durationInMilliseconds*chosenPosition, 1000)];
    
    waveformProgressView.frame = CGRectMake(waveformProgressView.frame.origin.x, waveformProgressView.frame.origin.y, chosenPosition*280, waveformProgressView.frame.size.height);
}

- (IBAction)backToSearchResults:(id)sender {
    
    [timerToUpdateSlider invalidate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateSoundProgressSlider
{
    NSLog(@"current position: %f", soundCurrentPositionOutlet.value);
    [soundCurrentPositionOutlet setValue:(soundCurrentPositionOutlet.value + 1000.00/(durationInMilliseconds)) animated:YES];
    waveformProgressView.frame = CGRectMake(waveformProgressView.frame.origin.x, waveformProgressView.frame.origin.y, waveformProgressView.frame.size.width + 1000.00*280/durationInMilliseconds, waveformProgressView.frame.size.height);
    
}
@end
