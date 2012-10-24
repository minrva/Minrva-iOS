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

@synthesize screenWidth;
@synthesize screenHeight;
@synthesize wRatio;
@synthesize hRatio;

@synthesize tv;
@synthesize loanabletech_service;
@synthesize jpg_service;

#pragma mark Table Stuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  bibIds.count * 2;
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float totalHeight = 0;

    // Get row type
    int rowType = indexPath.row % 2;
    
    // Add subviews
    if(rowType == 0)
    {
        // Get index of data
        int index = indexPath.row/2;
        
        // Add title (1)
        UILabel* lblName = [[UILabel alloc] initWithFrame:CGRectMake(10 * wRatio, totalHeight, 310 * wRatio, 1)];
        lblName.font = [UIFont systemFontOfSize:14 * wRatio];
        lblName.backgroundColor = [UIColor clearColor];
        lblName.lineBreakMode = UILineBreakModeWordWrap;
        lblName.numberOfLines = 0;
        lblName.text = [names objectAtIndex:index];
        [lblName sizeToFit];
        totalHeight += lblName.frame.size.height;
        
        // Add divider (2)
        totalHeight += 1 * hRatio;
    }
    else
    {
        // Get index of Data
        int index = (indexPath.row - 1)/2;
        
        // Add padding
        totalHeight += 5 * hRatio;

        // Add thumbnail (1)
        //totalHeight += 100;
        
        // Add title (2)
        UILabel* lblCount = [[UILabel alloc] initWithFrame:CGRectMake(85 * wRatio, totalHeight, 235 * wRatio, 1)];
        lblCount.font = [UIFont systemFontOfSize:16 * wRatio];
        lblCount.backgroundColor = [UIColor clearColor];
        lblCount.lineBreakMode = UILineBreakModeWordWrap;
        lblCount.numberOfLines = 0;
        lblCount.text = [counts objectAtIndex:index];
        [lblCount sizeToFit];
        
        if(lblCount.frame.size.height < 100 * hRatio)
        {
            CGRect countFrame = lblCount.frame;
            CGFloat newY = totalHeight + 50 * hRatio - countFrame.size.height/2;
            countFrame.origin.y = newY;
            lblCount.frame = countFrame;
        }
                
        // Decide which column is bigger
        if(100 * hRatio < lblCount.frame.size.height)
            totalHeight += lblCount.frame.size.height;
        else
            totalHeight += 100 * hRatio;
        
        // Add padding
        totalHeight += 10 * hRatio;
    }
    
    return totalHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    UILabel* lblName = nil;
    UIView* div = nil;
    UILabel* lblCount = nil;
    UIImageView* imageView = nil;
    
    // Get row type
    int rowType = indexPath.row % 2;
           
    // Create Views & SubViews if Cached Not Available
    cell  = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"Cell%d", rowType]];
    if(cell == nil)
    {
        // Make cell
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellSelectionStyleNone
                reuseIdentifier:[NSString stringWithFormat:@"Cell%d", rowType]];
        
        // Add subviews
        if(rowType == 0)
        {
            // Prevent title from being selected
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            // Add title (1)
            lblName = [[UILabel alloc] initWithFrame:CGRectZero];
            lblName.font = [UIFont systemFontOfSize:14 * wRatio];
            lblName.backgroundColor = [UIColor clearColor];
            lblName.lineBreakMode = UILineBreakModeWordWrap;
            lblName.numberOfLines = 0;
            lblName.tag = 1;
            [cell.contentView addSubview:lblName];

            // Add divider (2)
            div = [[UIView alloc] initWithFrame:CGRectZero];
            div.backgroundColor = [UIColor blackColor];
            div.tag = 2;
            [cell.contentView addSubview:div];
        }
        else
        {
            // Add thumbnail (1)
            imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.tag = 1;
            [cell.contentView addSubview:imageView];
      
            // Add title (2)
            lblCount = [[UILabel alloc] initWithFrame:CGRectZero];
            lblCount.font = [UIFont systemFontOfSize:16 * wRatio];
            lblCount.backgroundColor = [UIColor clearColor];
            lblCount.lineBreakMode = UILineBreakModeWordWrap;
            lblCount.numberOfLines = 0;
            lblCount.tag = 2;
            [cell.contentView addSubview:lblCount];
        }
    }
    
    // Add Content and Position Views
    if(rowType == 0)
    {
        // Get index of data
        int index = indexPath.row/2;
        
        // Get label
        if (lblName == nil)
            lblName = (UILabel*)[cell viewWithTag:1];
        
        // Get div
        if (div == nil)
            div = (UIView*)[cell viewWithTag:2];

        // Start position calc.
        float totalHeight = 0;
        
        // Add title
        lblName.frame = CGRectMake(10 * wRatio, totalHeight, 310 * wRatio, 1);
        lblName.text = [names objectAtIndex:index];
        [lblName sizeToFit];
        totalHeight += lblName.frame.size.height;
        
        // Add padding
        totalHeight += 1 * hRatio;
        
        // Add divider
        div.frame = CGRectMake(5 * wRatio, totalHeight, 310 * wRatio, 1 * hRatio);
    }
    else
    {
        // Get index of Data
        int index = (indexPath.row - 1)/2;
        
        // Get image
        if (imageView == nil)
            imageView = (UIImageView*)[cell viewWithTag:1];
        
        // Get count
        if (lblCount == nil)
            lblCount = (UILabel*)[cell viewWithTag:2];

        // Start position calc.
        float totalHeight = 0;
        
        // Add padding
        totalHeight += 5 * hRatio;
        
        // Add thumbnail
        imageView.frame = CGRectMake(5 * wRatio, totalHeight, 75 * wRatio, 100 * hRatio);
        [imageView  setImageWithURL:[NSURL URLWithString:[thumbnails objectAtIndex:index]]
                   placeholderImage:[UIImage imageNamed:@"stub"]
         ];
        
        // Calculate left offset
        float imageWidth = imageView.frame.origin.x + imageView.frame.size.width;
        float padding = 5 * wRatio;
        float countWidth = 320 * wRatio - imageWidth - padding;
        
        // Add title (name)
        lblCount.frame = CGRectMake(imageWidth + padding, totalHeight, countWidth, 1);
        lblCount.text = [counts objectAtIndex:index];
        [lblCount sizeToFit];
        
        
        if(lblCount.frame.size.height < imageView.frame.size.height)
        {
            CGRect countFrame = lblCount.frame;
            CGFloat newY = totalHeight + imageView.frame.size.height/2 - countFrame.size.height/2;
            countFrame.origin.y = newY;
            lblCount.frame = countFrame;
        }
        [cell.contentView addSubview:lblCount];
    }
    
    // Return cell
    return cell;
}

- (void)tableView: (UITableView *)tableView 
didSelectRowAtIndexPath: (NSIndexPath *)indexPath 
{
    if(indexPath.row%2 == 1)
    {
        NSInteger bibIdIndex = (indexPath.row - 1)/2;
        NSString* bibId = [bibIds objectAtIndex:bibIdIndex];
    
        //NSLog(bibId);
        AppDelegate* appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        appDel.bibId = bibId;
        appDel.tabBarController.selectedIndex = 0;
    }
}

#pragma mark - Request JSON

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    // Alert user
    if([error code] == -1009)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Connection Failed"
                                                       message: @"No internet connection is detected."
                                                      delegate: self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"OK",nil];
        [alert show];
    }
    
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
    names = [NSMutableArray array];
    thumbnails = [NSMutableArray array];
    counts = [NSMutableArray array];

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
        name = [name uppercaseString];
        count = [count stringByAppendingString:@" available"];
        
        NSString* thumbnail_uri = @"";
        thumbnail_uri = [thumbnail_uri stringByAppendingString:self.jpg_service];
        thumbnail_uri = [thumbnail_uri stringByAppendingString:@"TechLoan/"];
        thumbnail_uri = [thumbnail_uri stringByAppendingString:thumbnail];
        
        // Add data to data adapters
        [bibIds addObject:bibId];
        [names addObject:name];
        [thumbnails addObject:thumbnail_uri];
        [counts addObject:count];
    }
    
    [tv reloadData];
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
    // Get device specific dimensions
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    wRatio = screenWidth/320;
    hRatio = screenHeight/480;
    
    // Create Main Layout (background image, title bar, scrollable list)
    UIImageView* bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    [bgImage  setImage:[UIImage imageNamed:@"background"]];
    [self.view addSubview:bgImage];
    
    UIImageView* titleBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 48 * hRatio)];
    [titleBar  setImage:[UIImage imageNamed:@"header"]];
    [self.view addSubview:titleBar];
    
    float titleWidth = 68 * wRatio;
    float titleX = titleBar.frame.size.width/2 - titleWidth/2;
    UIImageView* title = [[UIImageView alloc] initWithFrame:CGRectMake(titleX, 0, titleWidth, titleBar.frame.size.height)];
    [title setImage:[UIImage imageNamed:@"title"]];
    [self.view addSubview:title];
    
    float contentHeight = screenHeight - titleBar.frame.size.height - self.tabBarController.tabBar.frame.size.height;
    tv = [[UITableView alloc] initWithFrame:CGRectMake(0, titleBar.frame.size.height, screenWidth, contentHeight)];
    tv.separatorStyle = UITableViewCellSeparatorStyleNone;
    tv.backgroundColor = [UIColor clearColor];
    tv.delegate = self;
    tv.dataSource = self;
    [self.view addSubview:tv];
    
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
    // Remove dynamic layout elements from scroll view
    for (UIView *subview in [self.tv subviews])
    {
        for (UIView *subview2 in [subview subviews])
            [subview2 removeFromSuperview];
        [subview removeFromSuperview];
    }
    
    // Remove dynamic layout elements from main view
    for (UIView *subview in [self.view subviews])
        [subview removeFromSuperview];
    
    responseData = nil;
    theConnection = nil;
    
    tv = nil;
    
    loanabletech_service = nil;
    jpg_service = nil;
    
    bibIds = nil;
    names = nil;
    
    thumbnails = nil;
    counts = nil;
    
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    //    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    //} else {
    //    return YES;
    //}
    return NO;
}

@end


