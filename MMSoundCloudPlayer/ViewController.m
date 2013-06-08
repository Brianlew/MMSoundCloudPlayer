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

@interface ViewController ()
{
    NSString *clientId;
    
    NSOperationQueue *operationQueue;
    
    AVPlayer *musicPlayer;
    NSArray *collection;
    NSMutableArray *artworkArray;
    
}

-(void)loadArtworkWithUrl:(NSURL*)artworkUrl atIndexPath:(NSIndexPath*)indexPath;
-(void)playSound:(NSURL *)streamUrl;
@end

@implementation ViewController

@synthesize searchBar, tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    clientId = @"448b448032053786dd3c33df2f96b1ad";
    
    operationQueue = [[NSOperationQueue alloc] init];
    
    searchBar.delegate = self;
    tableView.delegate = self;
    tableView.dataSource = self;
    
 //   searchBar.text = @"Disney";
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Search button was clicked: %@", self.searchBar.text);
    [self.searchBar resignFirstResponder];
    [artworkArray removeAllObjects];
    
    NSString *searchText = self.searchBar.text;
    NSString *encodedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Encoded Search Text: %@", encodedSearchText);
    NSString *urlString = [NSString stringWithFormat:@"https://api.soundcloud.com/search/sounds.json?client_id=%@&q=%@", clientId, encodedSearchText];
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

     //   NSLog(@"IndexPath Row: %i", indexPath.row);
      //  NSLog(@"artworkurl: %@", collection[indexPath.row][@"artwork_url"]);
        
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
    
    return cell;
}

-(void)loadArtworkWithUrl:(NSURL*)artworkUrl atIndexPath:(NSIndexPath*)indexPath
{
    NSLog(@"artworkUrl: %@", artworkUrl);
    
    NSBlockOperation *getArtworkOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSData *artworkData = [NSData dataWithContentsOfURL:artworkUrl];
        UIImage *artwork = [UIImage imageWithData:artworkData];
        
        NSBlockOperation *showArtworkOperation = [NSBlockOperation blockOperationWithBlock:^{
            [artworkArray replaceObjectAtIndex:indexPath.row withObject:artwork];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
        }];
        
        [[NSOperationQueue mainQueue] addOperation:showArtworkOperation];
    }];
    
    [operationQueue addOperation:getArtworkOperation];

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self playSound:streamUrl];

    [self performSegueWithIdentifier:@"playSoundSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [tableView indexPathForSelectedRow];
    NSString *streamUrlString = [NSString stringWithFormat:@"%@?client_id=%@", collection[indexPath.row][@"stream_url"], clientId];
    NSLog(@"streamUrlString: %@", streamUrlString);
    NSURL *streamUrl = [NSURL URLWithString:streamUrlString];
    
    NSInteger durationInMilliseconds = [collection[indexPath.row][@"duration"] integerValue];

    ((PlaySoundViewController*)segue.destinationViewController).streamUrl = streamUrl;
    ((PlaySoundViewController*)segue.destinationViewController).durationInMilliseconds = durationInMilliseconds;
}

-(void)playSound:(NSURL *)streamUrl
{
    NSError *error;
    musicPlayer = [AVPlayer playerWithURL:streamUrl];
    
    if (musicPlayer==nil) {
        NSLog(@"Error: %@", error.description);
    }
    else
    {
        [musicPlayer play];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
