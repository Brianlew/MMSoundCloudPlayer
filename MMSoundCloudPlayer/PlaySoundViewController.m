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
#import "ViewController.h"
#import "Constants.h"
#import "Track.h"

@interface PlaySoundViewController ()
{
    NSOperationQueue *operationQueue;
    
    NSTimer *timerToUpdateProgressBar;
    CGFloat timerInterval;
    
    Track *currentTrack;
    Track *previousTrack;
    Track *nextTrack;
}

-(void)updateSoundProgressBar;
-(void)setUpGestureRecognizer;
-(void)seek;
-(void)loadTrack:(Track*)track forIndex:(NSInteger)index;

@end

@implementation PlaySoundViewController

@synthesize musicPlayer, currentIndex, playlistArray, artworkImageView, waveformProgressBar, waveformView, waveformShapeView, titleLabel, usernameLabel;

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
    operationQueue = [[NSOperationQueue alloc] init];

    self.delegate = (ViewController*)self.presentingViewController;
    
    currentTrack = [[Track alloc] init];
    nextTrack = [[Track alloc] init];
    previousTrack = [[Track alloc] init];

    timerInterval = .1;
    
    [self setUpGestureRecognizer];
        
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [timerToUpdateProgressBar invalidate];

    NSLog(@"MusicPlayer Rate: %f", musicPlayer.rate);
    if ([keyPath isEqualToString:@"rate"]) {
        if (musicPlayer.rate) {
             timerToUpdateProgressBar = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(updateSoundProgressBar) userInfo:nil repeats:YES];
            NSLog(@"Playing");
        }
        else {
            NSLog(@"Paused");
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [self loadTrack:currentTrack forIndex:currentIndex];
    
    if (currentIndex > 0) {
        [self loadTrack:previousTrack forIndex:currentIndex-1];
    }
    if (currentIndex < playlistArray.count -1) {
        [self loadTrack:nextTrack forIndex:currentIndex+1];
    }

    [self displayCurrentTrack];
}

-(void)displayCurrentTrack
{
    waveformProgressBar.frame = CGRectMake(waveformProgressBar.frame.origin.x, waveformProgressBar.frame.origin.y, 0, waveformProgressBar.frame.size.height);
    
    titleLabel.text = currentTrack.trackTitle;
    usernameLabel.text = currentTrack.username;
    
    if (currentTrack.artWork == nil) {
        artworkImageView.image = [UIImage imageNamed:@"cloud.png"];
    }
    else
    {
        artworkImageView.image = currentTrack.artWork;
    }
    
    if (currentTrack.waveformImage == nil) {
        waveformShapeView.image = [UIImage imageNamed:@"sampleWaveForm.png"];
    }
    else
    {
        waveformShapeView.image = currentTrack.waveformImage;
    }
    
    [musicPlayer removeObserver:self forKeyPath:@"rate"];
    musicPlayer = [AVPlayer playerWithURL:currentTrack.streamUrl];
    [musicPlayer addObserver:self forKeyPath:@"rate" options:0 context:nil];
    
    [musicPlayer play];
}

-(void)loadTrack:(Track*)track forIndex:(NSInteger)index
{    
    track.index = index;
    track.trackTitle = playlistArray[index][@"title"];
    track.username = playlistArray[index][@"user"][@"username"];;

    NSString *streamUrlString = [NSString stringWithFormat:@"%@?client_id=%@", playlistArray[index][@"stream_url"], sClientId];
    track.streamUrl = [NSURL URLWithString:streamUrlString];
    
    track.durationInMilliseconds = [playlistArray[index][@"duration"] integerValue];
    track.waveformUrl = [NSURL URLWithString:playlistArray[index][@"waveform_url"]];
    
    if (playlistArray[index][@"artwork_url"] != [NSNull null]) {
        track.artworkUrl = [NSURL URLWithString:playlistArray[index][@"artwork_url"]];
    }
    else if (playlistArray[index][@"user"][@"avatar_url"] != [NSNull null])
    {
        track.artworkUrl = [NSURL URLWithString:playlistArray[index][@"user"][@"avatar_url"]];
    }
    
    if (track.index == currentIndex) {
        [track fetchArtworkForImageView:artworkImageView onOperationQueue:operationQueue];
        [track fetchWaveformImageForImageView:waveformShapeView onOperationQueue:operationQueue];
    }
    else
    {
        [track fetchArtworkForImageView:nil onOperationQueue:operationQueue];
        [track fetchWaveformImageForImageView:nil onOperationQueue:operationQueue];

    }
}

-(void)setUpGestureRecognizer
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(seek)];
    UITapGestureRecognizer *seekGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(seek)];
    seekGesture.delegate = self;
    
    [waveformView addGestureRecognizer:seekGesture];
    [waveformView addGestureRecognizer:panGesture];
}

- (IBAction)playSound:(id)sender {
    [musicPlayer play];
}

- (IBAction)pauseSound:(id)sender {
    [musicPlayer pause];
}

- (IBAction)skipToPreviousSong:(id)sender {
    [musicPlayer pause];
    currentIndex--;
    nextTrack = [Track createTrackFromTrack:currentTrack];
    currentTrack = [Track createTrackFromTrack:previousTrack];
    [self displayCurrentTrack];
    
    if (currentIndex <= 0) {
        [self loadTrack:previousTrack forIndex:playlistArray.count-1];
    }
    else
    {
        [self loadTrack:previousTrack forIndex:currentIndex-1];
    }
    
    if (currentIndex < 0) {
        currentIndex = playlistArray.count - 1;
    }
}

- (IBAction)skipToNextSong:(id)sender {
    [musicPlayer pause];
    currentIndex++;
    previousTrack = [Track createTrackFromTrack:currentTrack];
    currentTrack = [Track createTrackFromTrack:nextTrack];
    [self displayCurrentTrack];
    
    if (currentIndex >= playlistArray.count - 1) {
        [self loadTrack:nextTrack forIndex:0];
    }
    else
    {
        [self loadTrack:nextTrack forIndex:currentIndex+1];
    }
    
    if (currentIndex > playlistArray.count - 1) {
        currentIndex = 0;
    }
}

- (void)seek {
    
    CGPoint seekPosition = [waveformView.gestureRecognizers[0] locationInView:waveformView];
    
    UIPanGestureRecognizer *panGesture = waveformView.gestureRecognizers[1];
    
    if (panGesture.state == UIGestureRecognizerStateBegan || panGesture.state == UIGestureRecognizerStateChanged || panGesture.state == UIGestureRecognizerStateEnded) {
        seekPosition = [panGesture locationInView:waveformView];
    }
    
    NSLog(@"Seek Position x: %f", seekPosition.x);
    
    if (seekPosition.x < 0) {
        seekPosition.x = 0;
        [musicPlayer pause];
    }
    if (seekPosition.x > waveformView.frame.size.width) {
        seekPosition.x = waveformView.frame.size.width;
        [musicPlayer pause];
    }
    
    [musicPlayer seekToTime:CMTimeMake(currentTrack.durationInMilliseconds*seekPosition.x/waveformView.frame.size.width, 1000)];

    waveformProgressBar.frame = CGRectMake(waveformProgressBar.frame.origin.x, waveformProgressBar.frame.origin.y, seekPosition.x, waveformProgressBar.frame.size.height);
    

    NSLog(@"progress width: %f", waveformProgressBar.frame.size.width);
}

- (IBAction)backToSearchResults:(id)sender {
    
    [self.delegate retainPlaySoundViewController];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateSoundProgressBar
{    
    CGFloat progressWidth = waveformView.frame.size.width * CMTimeGetSeconds([musicPlayer currentTime]) / (currentTrack.durationInMilliseconds/1000.00);
    
    NSLog(@"MusicPlayer's currentTime: %f, progressWidth: %f, CurrentTrackDuration: %i", CMTimeGetSeconds([musicPlayer currentTime]), progressWidth, currentTrack.durationInMilliseconds);
    
    if(progressWidth < 0 )
    {
        progressWidth = 0;
    }
    if (progressWidth > waveformView.frame.size.width) {
        progressWidth = waveformView.frame.size.width;
    }
    
    [UIView animateWithDuration:timerInterval animations:^{
        waveformProgressBar.frame = CGRectMake(waveformView.frame.origin.x, waveformView.frame.origin.y, progressWidth, waveformView.frame.size.height);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
