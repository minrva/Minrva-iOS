//
//  WayFinder.m
//  minrva
//
//  Created by Jim Hahn on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VuFind.h"
#import "SBJson.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "Options.h"

@implementation VuFind
@synthesize tableView;
@synthesize searchField;
@synthesize selector;
@synthesize searchType;
@synthesize type;
@synthesize page;
@synthesize loadingMore;
@synthesize vufind_service;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Search", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


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


#pragma User Actions
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    NSArray *visibleRows = [self.tableView visibleCells];
    UITableViewCell *lastVisibleCell = [visibleRows lastObject];
    NSIndexPath *path = [self.tableView indexPathForCell:lastVisibleCell];
    NSInteger totalRows = [bibIds count];
   
    if((path.row >=  totalRows - 60) && totalRows != 0 && totalRows % 20 == 0)
    {
        [self addMore];
    }
    
    /*
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    // NSLog(@"offset: %f", offset.y);
    // NSLog(@"content.height: %f", size.height);
    // NSLog(@"bounds.height: %f", bounds.size.height);
    // NSLog(@"inset.top: %f", inset.top);
    // NSLog(@"inset.bottom: %f", inset.bottom);
    // NSLog(@"pos: %f of %f", y, h);
    
    float reload_distance = 10;
    if(y > h + reload_distance)
    {
        [self addMore];
    }
     */
}



-(IBAction)changeSeg
{
    // Clear data
    while(loadingMore > 0){}
    [self clearData];
    [tableView reloadData];
    
    // Reset page to 0
    page = 0;

    // Add more data
    [self addMore];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
    if (textField == searchField) 
    {
        // Close the keyboard
        [textField resignFirstResponder];
        
        // Clear data
        while(loadingMore > 0){}
        [self clearData];
        [tableView reloadData];

        // Reset page to 0
        page = 0;
        
        // Add more data
        [self addMore];
        
    }
    return NO;
}

-(IBAction)startSelection
{
    NSLog(@"Start SELECTION");
    
    Options* optionsController = [[Options alloc] initWithNibName:@"Options" bundle:nil];
    optionsController.optionsDelegate = self;
    [self presentModalViewController:optionsController animated: YES];   
}

-(void) Options:(Options*)Options didFinishWithSelection:(NSInteger) index 
{
    // Get button display text
    NSMutableArray* options = [NSMutableArray array];
    [options addObject:@"Keyword"];
    [options addObject:@"Title"];
    [options addObject:@"Author"];
    [options addObject:@"Subject"];
    [options addObject:@"ISBN/ISSN"];
    NSString* text = [options objectAtIndex:index];
    
    // Get button value
    NSMutableArray* vals = [NSMutableArray array];
    [vals addObject:@"all"];
    [vals addObject:@"title"];
    [vals addObject:@"author"];
    [vals addObject:@"subject"];
    [vals addObject:@"isn"];
    self.type = [vals objectAtIndex:index];

    // Set button display text
    [searchType setTitle:text forState:UIControlStateNormal];   
    [searchType setTitle:text forState:UIControlStateHighlighted];
    [searchType setTitle:text forState:UIControlStateDisabled];
    [searchType setTitle:text forState:UIControlStateSelected];
    
    // Release menu
    [self dismissModalViewControllerAnimated:YES];   
    
    // Clear data
    while(loadingMore > 0){}
    [self clearData];
    [tableView reloadData];
    
    // Reset page to 0
    page = 0;
    
    // Add data
    [self addMore];
}

#pragma mark Search

-(void)addMore
{
    // Get search term
    NSString* lookfor = searchField.text;

    if(!loadingMore && [lookfor length] > 0)
    {
        loadingMore = 2;

        // Get domain
        NSString* domain = @"";
        if(selector.selectedSegmentIndex == 0)
        {
            domain = [domain stringByAppendingString:@"uiu"];
        }
        else if(selector.selectedSegmentIndex == 1)
        {
            domain = [domain stringByAppendingString:@"all"];
        }

       
        // Get search type
        NSString* theType = self.type;

        for(int i = 0; i < 2; i++)
        {
            // Increment page number
            self.page++;
            
            // Get page number
            NSInteger thePage = self.page;
    
            NSString *uri = self.vufind_service;
            uri = [uri stringByAppendingString: @"?lookfor="];
            uri = [uri stringByAppendingString:lookfor];
            uri = [uri stringByAppendingString:@"&page="];
            uri = [uri stringByAppendingString:[NSString stringWithFormat:@"%d", thePage]];
            uri = [uri stringByAppendingString:@"&domain="];
            uri = [uri stringByAppendingString:domain];
            uri = [uri stringByAppendingString:@"&type="];
            uri = [uri stringByAppendingString:theType];

            NSLog(uri);
        
            // Grab the data
            responseData = [NSMutableData data];    
            NSURLRequest *theRequest=[NSURLRequest  requestWithURL:[NSURL URLWithString:uri]
                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                           timeoutInterval:60.0];
    
            theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        }
    }
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

- (UIView *)tableView:(UITableView *)tv viewForFooterInSection:(NSInteger)section {
    if ([self numberOfSectionsInTableView:tv] == (section+1))
    {
        return [UIView new];
    }       
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // Get response string
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];  
    
    // Get JSON array
    NSArray *models = [responseString JSONValue];
    
    
    // Fill text views
    for (NSDictionary *model in models)
    {
        // Get raw data
        NSString* bibId = [model objectForKey:@"bibId"];

        if([bibId length] != 0)
        {
            NSString* thumbnail = [model objectForKey:@"thumbnail"];
        
            NSString* location = [model objectForKey:@"location"];
            NSString* author = [model objectForKey:@"author"];
            NSString* pubYear = [model objectForKey:@"pubYear"];
            NSString* format = [model objectForKey:@"format"];
        
            // Format data
            NSString* summary = @"";
            summary = [summary stringByAppendingString:@"Location: "];
            summary = [summary stringByAppendingString:@"\n"];
            summary = [summary stringByAppendingString:location];
            summary = [summary stringByAppendingString:@"\n"];
        
            summary = [summary stringByAppendingString:@"Author: "];
            summary = [summary stringByAppendingString:@"\n"];
            summary = [summary stringByAppendingString:author];
            summary = [summary stringByAppendingString:@"\n"];
        
            summary = [summary stringByAppendingString:@"Pub. Date: "];
            summary = [summary stringByAppendingString:@"\n"];
            summary = [summary stringByAppendingString:pubYear];
            summary = [summary stringByAppendingString:@"\n"];
        
            summary = [summary stringByAppendingString:@"Format: "];
            summary = [summary stringByAppendingString:@"\n"];
            summary = [summary stringByAppendingString:format];
            summary = [summary stringByAppendingString:@"\n"];

            NSLog(@"BibId: %@", bibId);

            // Add data to data adapters
            [bibIds addObject:bibId];
            [thumbnails addObject:thumbnail];
            [summaries addObject:summary];
        }
    }
    
    loadingMore--;
    
    [tableView reloadData];
}


#pragma mark - View lifecycle

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
    self.vufind_service = [temp objectForKey:@"vufind_service"];

    
    type = @"all";
    page = 0;
    loadingMore = 0;
    
    [self clearData];

    NSLog(@"tableView = %@", tableView);
}

- (void) clearData
{
    bibIds = [NSMutableArray array];
    thumbnails = [NSMutableArray array];
    summaries = [NSMutableArray array];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
