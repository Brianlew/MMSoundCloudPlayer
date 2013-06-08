//
//  ViewController.m
//  MMSoundCloudPlayer
//
//  Created by Brian Lewis on 6/7/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
{
    NSString *clientId;
    
    AVPlayer *musicPlayer;
    NSArray *collection;
}

-(void)playSound:(NSURL *)streamUrl;
@end

@implementation ViewController

@synthesize searchBar, tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    clientId = @"448b448032053786dd3c33df2f96b1ad";
    
    searchBar.delegate = self;
    tableView.delegate = self;
    tableView.dataSource = self;
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Search button was clicked: %@", self.searchBar.text);
    [self.searchBar resignFirstResponder];
    NSString *searchText = self.searchBar.text;
    NSString *encodedSearchText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Encoded Search Text: %@", encodedSearchText);
    NSString *urlString = [NSString stringWithFormat:@"https://api.soundcloud.com/search/sounds.json?client_id=%@&q=%@", clientId, encodedSearchText];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        collection = [responseDictionary objectForKey:@"collection"];
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
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *streamUrlString = [NSString stringWithFormat:@"%@?client_id=%@", collection[indexPath.row][@"stream_url"], clientId];
    NSLog(@"streamUrlString: %@", streamUrlString);
    NSURL *streamUrl = [NSURL URLWithString:streamUrlString];
    [self playSound:streamUrl];
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
