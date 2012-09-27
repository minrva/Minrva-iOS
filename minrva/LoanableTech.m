//
//  LoanableTech.m
//  minrva
//
//  Created by Jim Hahn on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoanableTech.h"
#import "SBJson.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"

@implementation LoanableTech
@synthesize tableView;
@synthesize loanabletech_service;

#pragma mark Table Stuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  bibIds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Create a cell
    UITableViewCell *cell = [[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:@"cell"];
    
    // Here we use the new provided setImageWithURL: method to load the web image
    [cell.imageView setImageWithURL:[NSURL URLWithString:[thumbnails objectAtIndex:indexPath.row]]
                   placeholderImage:[UIImage imageNamed:@"first"]];
    
    // Fill it with content
    cell.textLabel.text = [summaries objectAtIndex:indexPath.row];
    
    // Return cell 
    return cell;
}

- (void)tableView: (UITableView *)tableView 
didSelectRowAtIndexPath: (NSIndexPath *)indexPath 
{
    NSString* bibId = [bibIds objectAtIndex:indexPath.row];
    //NSLog(bibId);
    AppDelegate* appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDel.bibId = bibId;
    appDel.tabBarController.selectedIndex = 0;
}

#pragma mark - Request JSON

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get root uri from properties.plist
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistXML
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:nil
                                          errorDescription:nil];
    self.loanabletech_service = [temp objectForKey:@"loanabletech_service"];
    self.jpg_service = [temp objectForKey:@"jpg_service"];

    
    
    responseData = [NSMutableData data];    
    
    NSString *url = self.loanabletech_service;
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:url]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:60.0];
    theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"tableView = %@", tableView);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"Connection didReceiveResponse: %@ - %@", response, [response MIMEType]);
    [responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	[NSException raise:@"unexpected" format:@"Should not get here"];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"Connection didReceiveData of length: %u", data.length);
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // Get response string
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];  
    
    // Get JSON array
    NSArray *techs = [responseString JSONValue];
    
    // Convert JSON array into summaries
    bibIds = [NSMutableArray array];
    thumbnails = [NSMutableArray array];
    summaries = [NSMutableArray array];

    for (NSDictionary *tech in techs) 
    {
        // Get raw data
        NSString* bibId = [tech objectForKey:@"bibId"];
        NSString* thumbnail = [tech objectForKey:@"thumbnail"];
        NSString* name = [tech objectForKey:@"name"];
        NSString* count = [tech objectForKey:@"count"];
        //  NSString* rank = [tech objectForKey:@"rank"];
        
        
        NSLog(@"BibId: %@", bibId);
        
        // Format data
        NSString* summary = @"";
        summary = [summary stringByAppendingString:name];
        summary = [summary stringByAppendingString:@": "];
        summary = [summary stringByAppendingString:count];
        
        NSString* thumbnail_uri = @"";
        thumbnail_uri = [thumbnail_uri stringByAppendingString:self.jpg_service];
        thumbnail_uri = [thumbnail_uri stringByAppendingString:@"TechLoan/"];
        thumbnail_uri = [thumbnail_uri stringByAppendingString:thumbnail];
        
        // Add data to data adapters
        [bibIds addObject:bibId];
        [thumbnails addObject:thumbnail_uri];
        [summaries addObject:summary];
    }
    
    [tableView reloadData];
}



#pragma mark - Init Stuff

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Tech", @"Fifth");
        self.tabBarItem.image = [UIImage imageNamed:@"fifth"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end


