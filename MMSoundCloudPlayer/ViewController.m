//
//  ViewController.m
//  MMSoundCloudPlayer
//
//  Created by Brian Lewis on 6/7/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PlaySoundViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"

@interface ViewController ()
{
    NSString *clientId;
    NSOperationQueue *operationQueue;
    PlaySoundViewController *playSoundViewController;
    
   // AVPlayer *musicPlayer;
    NSArray *collection;
    NSMutableArray *artworkArray;
    
    UIImage *nextArtworkImage;
    
    
}

-(void)loadArtworkWithUrl:(NSURL*)artworkUrl atIndexPath:(NSIndexPath*)indexPath;
//-(void)playSound:(NSURL *)streamUrl;
@end

@implementation ViewController

@synthesize searchBar, tableView, nowPlayingButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
        
    operationQueue = [[NSOperationQueue alloc] init];
    
    searchBar.delegate = self;
    tableView.delegate = self;
    tableView.dataSource = self;
    
    nowPlayingButton.hidden = YES;
    
    if (playSoundViewController ==  nil) {
        UIStoryboard *storyboard = self.storyboard;
        playSoundViewController = [storyboard instantiateViewControllerWithIdentifier:@"playSoundVC"];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Search button was clicked: %@", self.searchBar.text);
    self.searchBar.showsCancelButton = NO;
    [self.searchBar resignFirstResponder];
    [artworkArray removeAllObjects];
    playSoundViewController.currentIndex = -1;
    
    NSString *searchText = self.searchBar.text;
    NSString *encodedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Encoded Search Text: %@", encodedSearchText);
    NSString *urlString = [NSString stringWithFormat:@"https://api.soundcloud.com/search/sounds.json?client_id=%@&q=%@", sClientId, encodedSearchText];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        collection = [responseDictionary objectForKey:@"collection"];
        artworkArray = [[NSMutableArray alloc] initWithCapacity:collection.count];
        [tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];

        [tableView reloadData];
    } ];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return collection.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    cell.textLabel.text = collection[indexPath.row][@"title"];
    cell.detailTextLabel.text = collection[indexPath.row][@"user"][@"username"];
    
    NSLog(@"IndexPath Row: %i", indexPath.row);
    if (indexPath.row < artworkArray.count) {
        cell.imageView.image = artworkArray[indexPath.row];
    }
    else{
        [artworkArray insertObject:[UIImage imageNamed:@"cloud.png"] atIndex:indexPath.row];
        cell.imageView.image = artworkArray[indexPath.row];
        
        NSURL *artworkUrl;
        if (collection[indexPath.row][@"artwork_url"] != [NSNull null]) {
            artworkUrl = [NSURL URLWithString:collection[indexPath.row][@"artwork_url"]];
            [self loadArtworkWithUrl:artworkUrl atIndexPath:indexPath];
        }
        else if (collection[indexPath.row][@"user"][@"avatar_url"] != [NSNull null])
        {
            artworkUrl = [NSURL URLWithString:collection[indexPath.row][@"user"][@"avatar_url"]];
            [self loadArtworkWithUrl:artworkUrl atIndexPath:indexPath];
        }
    }
    
  //  cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
  //  cell.textLabel.numberOfLines = 0;
    
    return cell;
}
/*
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize titleLabelSize = [cell.textLabel.text sizeWithFont:cell.textLabel.font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    CGSize detailLabelSize = [cell.detailTextLabel.text sizeWithFont:cell.detailTextLabel.font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    
    return titleLabelSize.height + detailLabelSize.height;
}*/

-(void)loadArtworkWithUrl:(NSURL*)artworkUrl atIndexPath:(NSIndexPath*)indexPath
{
    NSLog(@"artworkUrl: %@", artworkUrl);
    
    NSBlockOperation *getArtworkOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSData *artworkData = [NSData dataWithContentsOfURL:artworkUrl];
        UIImage *artwork = [UIImage imageWithData:artworkData];
        
        NSBlockOperation *showArtworkOperation = [NSBlockOperation blockOperationWithBlock:^{
            if (artwork != nil) {
                [artworkArray replaceObjectAtIndex:indexPath.row withObject:artwork];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
            }
        }];
        
        [[NSOperationQueue mainQueue] addOperation:showArtworkOperation];
    }];
    
    [operationQueue addOperation:getArtworkOperation];

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self playSound:streamUrl];

    //[self performSegueWithIdentifier:@"playSoundSegue" sender:self];
    
    if (playSoundViewController.currentIndex != indexPath.row) {
        playSoundViewController.newSoundSelected = YES;
        playSoundViewController.playlistArray = collection;
        playSoundViewController.currentIndex = indexPath.row;
    }
    else
    {
        playSoundViewController.newSoundSelected = NO;
    }
    
    [self presentViewController: playSoundViewController animated:YES completion:nil];
}

- (IBAction)goToNowPlaying:(id)sender {
    
    playSoundViewController.newSoundSelected = NO;
    [self presentViewController: playSoundViewController animated:YES completion:nil];
    
}

-(void)retainPlaySoundViewController
{
    playSoundViewController = (PlaySoundViewController*)self.presentedViewController;
    nowPlayingButton.hidden = NO;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = NO;
    [self.searchBar resignFirstResponder];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
