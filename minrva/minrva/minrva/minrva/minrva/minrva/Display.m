//
//  Display.m
//  minrva
//
//  Created by Jim Hahn on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Display.h"
#import <QuartzCore/QuartzCore.h>
#import "SBJson.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import <OHAttributedLabel/OHAttributedLabel.h>
#import <OHAttributedLabel/NSAttributedString+Attributes.h>

@implementation Display

@synthesize screenWidth;
@synthesize screenHeight;
@synthesize wRatio;
@synthesize hRatio;

@synthesize display_service;

@synthesize scroller;

@synthesize strTitle;
@synthesize strAuthor;

@synthesize strThumbnail;

@synthesize strLibrary;
@synthesize strPublisher;
@synthesize strPubyear;
@synthesize strFormat;

@synthesize strLocations;
@synthesize strStatuses;
@synthesize strCallNums;

@synthesize strSummary;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        self.title = NSLocalizedString(@"Home", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
    scroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, titleBar.frame.size.height, screenWidth, contentHeight)];
    [self.view addSubview:scroller];
    
    
    // Get root uri from properties.plist
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistXML
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:nil
                                          errorDescription:nil];
    self.display_service = [temp objectForKey:@"display_service"];
    
    // Initialize values
    self.strTitle = @"";
    self.strAuthor = @"";
    
    self.strLibrary = @"";
    self.strPublisher = @"";
    self.strPubyear = @"";
    self.strFormat = @"";
    
    self.strLocations = nil;
    self.strStatuses = nil;
    self.strCallNums = nil;
    
    self.strSummary = @"";
    self.strThumbnail = @"";

    // Build uri from unique id
    NSString *url = self.display_service;
    AppDelegate* appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    url = [url stringByAppendingString:appDel.bibId];

    // Load JSON into views
    responseData = [NSMutableData data];
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:url]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:60.0];
    connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];

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
    for (UIView *subview in [self.scroller subviews])
    {
         for (UIView *subview2 in [subview subviews])
             [subview2 removeFromSuperview];
        [subview removeFromSuperview];
    }
    
    // Remove dynamic layout elements from main view
    for (UIView *subview in [self.view subviews])
        [subview removeFromSuperview];

    
    // Device Specific Dimensions
    display_service = nil;
    
    // Views
    scroller = nil;
    
    // Data
    strTitle = nil;
    strAuthor = nil;
    
    strThumbnail = nil;
    
    strLibrary = nil;
    strPublisher = nil;
    strPubyear = nil;
    strFormat = nil;
    
    strLocations = nil;
    strStatuses = nil;
    strCallNums = nil;
    strSummary = nil;
    
    // JSON Feed
    responseData = nil;
    connection = nil;

	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
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

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // Alert user
    if([error code] == -1009)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Connection Failed"
                                                   message: @"No internet connection is detected."
                                                  delegate: self
                                         cancelButtonTitle:nil
                                         otherButtonTitles:@"OK",nil];
        [alert show];
        
        // Display default
        [self loadDynamicLayout];
    }
    
    // Log
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Get response string
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];  
    NSDictionary *descr = [responseString JSONValue];
    
    // Get data
    strTitle = [descr objectForKey:@"title"];
    strAuthor = [descr objectForKey:@"author"];
        
    strLibrary = [descr objectForKey:@"library"];
    strPublisher = [descr objectForKey:@"publisher"];
    strPubyear = [descr objectForKey:@"pubyear"];
    strFormat = [descr objectForKey:@"format"];
        
    strLocations = [descr objectForKey:@"locations"];
    strStatuses = [descr objectForKey:@"statuses"];
    strCallNums = [descr objectForKey:@"callnums"];
        
    strSummary = [descr objectForKey:@"summary"];
    strThumbnail = [descr objectForKey:@"thumbnail"];
    
    // Build Dynamic Layout
    [self loadDynamicLayout];
}

-(void)loadDynamicLayout
{
    float large_font_size = 18 * wRatio;                   
    float medium_font_size = 16 * wRatio;                   
    float small_font_size = 14 * wRatio;                  

    // Dynamic calculations
    float totalHeight = 0;
    
    // Add title
    UILabel* lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(5 * wRatio, totalHeight, screenWidth - (2 * 5) * wRatio, 1)];
    lblTitle.font = [UIFont systemFontOfSize:large_font_size];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.lineBreakMode = UILineBreakModeWordWrap;
    lblTitle.numberOfLines = 0;
    if([strTitle length] != 0)
        lblTitle.text = strTitle;
    else
        lblTitle.text = @"No Title Found";
    [lblTitle sizeToFit];
    [scroller addSubview:lblTitle];
    totalHeight += lblTitle.frame.size.height;
    
    // Add author
    if([strAuthor length] != 0)
    {
        UILabel* lblAuthor = [[UILabel alloc] initWithFrame:CGRectMake(5 * wRatio, totalHeight, screenWidth - (2 * 5) * wRatio, 1)];
        lblAuthor.font = [UIFont systemFontOfSize:small_font_size];
        lblAuthor.backgroundColor = [UIColor clearColor];
        lblAuthor.lineBreakMode = UILineBreakModeWordWrap;
        lblAuthor.numberOfLines = 0;
        lblAuthor.text = [@"by " stringByAppendingString: strAuthor];
        [lblAuthor sizeToFit];
        [scroller addSubview:lblAuthor];
        totalHeight += lblAuthor.frame.size.height;
    }
    
    // Add margin
    totalHeight += 10 * hRatio;
    
    // Add divider
    UIView* divider = [[UIView alloc] initWithFrame:CGRectMake(5 * wRatio, totalHeight, screenWidth - (2 * 5) * wRatio, 1 * hRatio)];
    divider.backgroundColor = [UIColor blackColor];
    [scroller addSubview:divider];
    totalHeight += divider.frame.size.height;
    
    // Add margin
    totalHeight += 10 * hRatio;
    
    // Add image
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5 * wRatio, totalHeight, 120 * wRatio, 160 * hRatio)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView  setImageWithURL:[NSURL URLWithString:strThumbnail]
               placeholderImage:[UIImage imageNamed:@"stub"]
     ];
    [scroller addSubview:imageView];
    
    // Add library, publisher, pubyear, and format
    float left_padding = imageView.frame.origin.x + imageView.frame.size.width + 10 * wRatio;
    float infoHeight = totalHeight;
    float infoWidth = screenWidth - left_padding - 5 * wRatio;
    
    // Add library
    if([strLibrary length] != 0)
    {
        // Create custom attributed string
        NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:[@"Library: " stringByAppendingString:strLibrary]];
        [attrStr setFont:[UIFont systemFontOfSize:small_font_size]];
        [attrStr setFont:[UIFont boldSystemFontOfSize:small_font_size] range:NSMakeRange(0,8)];
        
        // Create subclassed label
        OHAttributedLabel* lblLibrary = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(left_padding, infoHeight, infoWidth, 1)];
        lblLibrary.backgroundColor = [UIColor clearColor];
        lblLibrary.lineBreakMode = UILineBreakModeWordWrap;
        lblLibrary.numberOfLines = 0;
        lblLibrary.attributedText = attrStr;
        [lblLibrary sizeToFit];
        
        // Add view
        [scroller addSubview:lblLibrary];
        
        // Update height
        infoHeight += lblLibrary.frame.size.height;
        
        // Add padding
        infoHeight += 5 * hRatio;
    }
    
    if([strPublisher length] != 0)
    {
        // Create custom attributed string
        NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:[@"Publisher: " stringByAppendingString:strPublisher]];
        [attrStr setFont:[UIFont systemFontOfSize:small_font_size]];
        [attrStr setFont:[UIFont boldSystemFontOfSize:small_font_size] range:NSMakeRange(0,10)];
        
        // Create subclassed label
        OHAttributedLabel* lblPublisher = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(left_padding, infoHeight, infoWidth, 1)];
        lblPublisher.font = [UIFont systemFontOfSize:small_font_size];
        lblPublisher.backgroundColor = [UIColor clearColor];
        lblPublisher.lineBreakMode = UILineBreakModeWordWrap;
        lblPublisher.numberOfLines = 0;
        lblPublisher.attributedText = attrStr;
        [lblPublisher sizeToFit];
        
        // Add view
        [scroller addSubview:lblPublisher];
        
        // Update height
        infoHeight += lblPublisher.frame.size.height;
        
        // Add padding
        infoHeight += 5 * hRatio;
    }

    if([strPubyear length] != 0)
    {
        // Create custom attributed string
        NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:[@"Publication Date: " stringByAppendingString:strPubyear]];
        [attrStr setFont:[UIFont systemFontOfSize:small_font_size]];
        [attrStr setFont:[UIFont boldSystemFontOfSize:small_font_size] range:NSMakeRange(0,17)];
        
        // Create subclassed label
        OHAttributedLabel* lblPubyear = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(left_padding, infoHeight, infoWidth, 1)];
        lblPubyear.backgroundColor = [UIColor clearColor];
        lblPubyear.lineBreakMode = UILineBreakModeWordWrap;
        lblPubyear.numberOfLines = 0;
        lblPubyear.attributedText = attrStr;
        [lblPubyear sizeToFit];
        
        // Add view
        [scroller addSubview:lblPubyear];
        
        // Update height
        infoHeight += lblPubyear.frame.size.height;
        
        // Add padding
        infoHeight += 5 * hRatio;
    }
    
    if([strFormat length] != 0)
    {
        // Create custom attributed string
        NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:[@"Format: " stringByAppendingString:strFormat]];
        [attrStr setFont:[UIFont systemFontOfSize:small_font_size]];
        [attrStr setFont:[UIFont boldSystemFontOfSize:small_font_size] range:NSMakeRange(0,7)];
        
        // Create subclassed label
        OHAttributedLabel* lblFormat = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(left_padding, infoHeight, infoWidth, 1)];
        lblFormat.backgroundColor = [UIColor clearColor];
        lblFormat.lineBreakMode = UILineBreakModeWordWrap;
        lblFormat.numberOfLines = 0;
        lblFormat.attributedText = attrStr;
        [lblFormat sizeToFit];
        
        // Add view
        [scroller addSubview:lblFormat];
        
        // Update height
        infoHeight += lblFormat.frame.size.height;
    }
    
    // Calculate which column is longer...
    if(imageView.frame.size.height + totalHeight < infoHeight)
        totalHeight = infoHeight;
    else
        totalHeight += imageView.frame.size.height;
    
    // Add padding
    totalHeight += 10 * hRatio;
    
    // Add holdings information
    int i;
    int count = [strLocations count];
    for (i = 0; i < count; i++)
    {
        // Get data
        NSString* strLocation = [strLocations objectAtIndex:i];
        NSString* strStatus = [strStatuses objectAtIndex:i];
        NSString* strCallNum = [strCallNums objectAtIndex:i];
        
        // Add divider
        UIView* div = [[UIView alloc] initWithFrame:CGRectMake(5 * wRatio, totalHeight, screenWidth - (5 * 2) * wRatio, 1 * hRatio)];
        div.backgroundColor = [UIColor blackColor];
        [scroller addSubview:div];
        totalHeight += div.frame.size.height;
        
        // Add padding
        totalHeight += 5 * hRatio;
        
        // Add Location
        if([strLocation length] != 0)
        {
            // Create custom attributed string
            NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:[@"Location: " stringByAppendingString:strLocation]];
            [attrStr setFont:[UIFont systemFontOfSize:small_font_size]];
            [attrStr setFont:[UIFont boldSystemFontOfSize:small_font_size] range:NSMakeRange(0,9)];

            // Create subclassed label
            OHAttributedLabel* lblLocation = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(5 * wRatio, totalHeight, screenWidth - (5 * 2) * wRatio, 1)];
            lblLocation.backgroundColor = [UIColor clearColor];
            lblLocation.lineBreakMode = UILineBreakModeWordWrap;
            lblLocation.numberOfLines = 0;
            lblLocation.attributedText = attrStr;
            [lblLocation sizeToFit];
                      
            // Add view
            [scroller addSubview:lblLocation];
            
            // Update height
            totalHeight += lblLocation.frame.size.height;
            
            // Add padding
            totalHeight += 5 * hRatio;
        }
        
        // Add Status
        if([strStatus length] != 0)
        {
            // Create custom attributed string
            NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:[@"Status: " stringByAppendingString:strStatus]];
            [attrStr setFont:[UIFont systemFontOfSize:small_font_size]];
            [attrStr setFont:[UIFont boldSystemFontOfSize:small_font_size] range:NSMakeRange(0,7)];
            
            // Create subclassed label
            OHAttributedLabel* lblStatus = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(5 * wRatio, totalHeight, screenWidth - (5 * 2) * wRatio, 1)];
            lblStatus.backgroundColor = [UIColor clearColor];
            lblStatus.lineBreakMode = UILineBreakModeWordWrap;
            lblStatus.numberOfLines = 0;
            lblStatus.attributedText = attrStr;
            [lblStatus sizeToFit];

            // Add view
            [scroller addSubview:lblStatus];
            
            // Update height
            totalHeight += lblStatus.frame.size.height;
            
            // Add padding
            totalHeight += 5 * hRatio;
        }
        
        // Add call number
        if([strCallNum length] != 0)
        {
            // Create custom attributed string
            NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:[@"Call No.: " stringByAppendingString:strCallNum]];
            [attrStr setFont:[UIFont systemFontOfSize:small_font_size]];
            [attrStr setFont:[UIFont boldSystemFontOfSize:small_font_size] range:NSMakeRange(0,9)];
            
            // Create subclassed label
            OHAttributedLabel* lblCallNum = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(5 * wRatio, totalHeight,  screenWidth - (5 * 2) * wRatio, 1)];
            lblCallNum.backgroundColor = [UIColor clearColor];
            lblCallNum.lineBreakMode = UILineBreakModeWordWrap;
            lblCallNum.numberOfLines = 0;
            lblCallNum.attributedText = attrStr;
            [lblCallNum sizeToFit];
            
            // Add view
            [scroller addSubview:lblCallNum];
            
            // Update height
            totalHeight += lblCallNum.frame.size.height;
            
            // Add padding
            totalHeight += 5 * hRatio;
        }
    }
    
    // Add summary
    if([strSummary length] != 0)
    {
        // Add padding
        totalHeight += 15 * hRatio;
        
        // Add "Descripition" label
        UILabel* lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(10 * wRatio, totalHeight, screenWidth - 15 * wRatio, 1)];
        lblDescription.font = [UIFont systemFontOfSize:medium_font_size];
        lblDescription.backgroundColor = [UIColor clearColor];
        lblDescription.lineBreakMode = UILineBreakModeWordWrap;
        lblDescription.numberOfLines = 0;
        lblDescription.text = @"Description";
        [lblDescription sizeToFit];
        [scroller addSubview:lblDescription];
        totalHeight += lblDescription.frame.size.height;
        
        // Add padding
        totalHeight += 5 * hRatio;
        
        // Add summary
        UILabel* lblSummary = [[UILabel alloc] initWithFrame:CGRectMake(10 * wRatio, totalHeight + 5 * hRatio, screenWidth - 20 * wRatio, 1)];
        lblSummary.font = [UIFont systemFontOfSize:medium_font_size];
        lblSummary.backgroundColor = [UIColor clearColor];
        lblSummary.lineBreakMode = UILineBreakModeWordWrap;
        lblSummary.numberOfLines = 0;
        lblSummary.text = strSummary;
        [lblSummary sizeToFit];
        
        // Add shape behind summary
        UIView* box = [[UILabel alloc] initWithFrame:CGRectMake(5 * wRatio, totalHeight, screenWidth - 10 * wRatio, lblSummary.frame.size.height + 10 * hRatio)];
        box.layer.cornerRadius = 5;
        box.layer.borderColor = [UIColor grayColor].CGColor;
        box.layer.borderWidth = 1;
        box.layer.masksToBounds = YES;
        
        [scroller addSubview:box];
        [scroller addSubview:lblSummary];
        
        totalHeight += box.frame.size.height;
    }

    // Resize scroller
    scroller.contentSize = CGSizeMake(screenWidth, totalHeight);
    [scroller setScrollEnabled:YES];
   // scroller.backgroundColor = [UIColor whiteColor];
}

@end
