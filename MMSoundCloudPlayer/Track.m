//
//  Track.m
//  MMSoundCloudPlayer
//
//  Created by Brian Lewis on 6/11/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import "Track.h"

@implementation Track

-(void)fetchArtworkForImageView:(UIImageView *)imageView onOperationQueue:(NSOperationQueue *)operationQueue
{
    NSBlockOperation *getArtworkOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSData *artworkData = [NSData dataWithContentsOfURL:self.artworkUrl];
        UIImage *artwork = [UIImage imageWithData:artworkData];
        
        NSBlockOperation *showArtworkOperation = [NSBlockOperation blockOperationWithBlock:^{
            self.artWork = artwork;
            if (imageView != nil) {
                imageView.image = self.artWork;
            }
        }];
        
        [[NSOperationQueue mainQueue] addOperation:showArtworkOperation];
    }];
    
    [operationQueue addOperation:getArtworkOperation];
}

-(void)fetchWaveformImageForImageView:(UIImageView*)imageView onOperationQueue:(NSOperationQueue *)operationQueue
{
    NSBlockOperation *getWaveformOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSData *waveformData = [NSData dataWithContentsOfURL:self.waveformUrl];
        UIImage *waveform = [UIImage imageWithData:waveformData];
        
        NSBlockOperation *showArtworkOperation = [NSBlockOperation blockOperationWithBlock:^{
            self.waveformImage = waveform;
            if (imageView != nil) {
                imageView.image = self.waveformImage;
            }
        }];
        
        [[NSOperationQueue mainQueue] addOperation:showArtworkOperation];
    }];
    
    [operationQueue addOperation:getWaveformOperation];
}

+(Track*)createTrackFromTrack:(Track*)track
{
    Track *newTrack = [[Track alloc] init];
    newTrack.trackTitle = track.trackTitle;
    newTrack.username = track.username;
    newTrack.streamUrl = track.streamUrl;
    newTrack.waveformUrl = track.waveformUrl;
    newTrack.artworkUrl = track.artworkUrl;
    newTrack.artWork = track.artWork;
    newTrack.waveformImage = track.waveformImage;
    newTrack.durationInMilliseconds = track.durationInMilliseconds;
    newTrack.index = track.index;
    
    return newTrack;
}

@end
