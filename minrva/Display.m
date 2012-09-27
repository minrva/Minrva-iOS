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
#import "UILabel+dynamicSizeMe.h"


@implementation Display

@synthesize lblTitle;
@synthesize lblAuthor;
@synthesize imageView;

@synthesize lblLibrary;
@synthesize lblPublisher;
@synthesize lblPubyear;
@synthesize lblFormat;

@synthesize lblHoldings;
@synthesize lblDescription;
@synthesize lblSummary;

@synthesize scroller;
@synthesize display_service;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Home", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    
    
    
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{

    [super viewDidLoad];
        
    //[scrollView setScrollEnabled:YES];
    //[scrollView setContentSize:CGSizeMake(320, 650)];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
  
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    // Get root uri from properties.plist
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistXML
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:nil
                                          errorDescription:nil];
    self.display_service = [temp objectForKey:@"display_service"];

    // Build uri
    NSString *url = self.display_service;
    AppDelegate* appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];    
    url = [url stringByAppendingString:appDel.bibId];

    NSLog(url);
    
    // Get some JSON
    responseData = [NSMutableData data];
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
    // Interface elements
    for (UIView *subview in [self.scroller subviews])
        [subview removeFromSuperview];


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
    
    // Get JSON object
    NSDictionary *descr = [responseString JSONValue];
    
    // Get data
    NSString* strTitle = [descr objectForKey:@"title"];
    NSString* strAuthor = [descr objectForKey:@"author"];

    NSString* strLibrary = [descr objectForKey:@"library"];
    NSString* strPublisher = [descr objectForKey:@"publisher"];
    NSString* strPubyear = [descr objectForKey:@"pubyear"];
    NSString* strFormat = [descr objectForKey:@"format"];
    
    NSString* strSummary = [descr objectForKey:@"summary"];
    NSString* strThumbnail = [descr objectForKey:@"thumbnail"];

    float totalHeight = 0;
    
    // Add title and author
    if([strTitle length] != 0)
    {
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(7, totalHeight, 306, 32)];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.text = strTitle;
        [lblTitle resizeToFit];
        [scroller addSubview:lblTitle];
        totalHeight += lblTitle.frame.size.height;
    }

    if([strAuthor length] != 0)
    {
        lblAuthor = [[UILabel alloc] initWithFrame:CGRectMake(7, totalHeight, 306, 32)];
        lblAuthor.backgroundColor = [UIColor clearColor];
        lblAuthor.text = strAuthor;
        [lblAuthor resizeToFit];
        [scroller addSubview:lblAuthor];
        totalHeight += lblAuthor.frame.size.height;
    }

    // Add divider
    div1 = [[UIView alloc] initWithFrame:CGRectMake(6, totalHeight, 307, 1)];
    div1.backgroundColor = [UIColor blackColor];
    [scroller addSubview:div1];
    totalHeight += div1.frame.size.height;

    // Add image
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, totalHeight, 120, 160)];
    [imageView setImageWithURL:[NSURL URLWithString:strThumbnail]
                      placeholderImage:[UIImage imageNamed:@"first"]];
    [scroller addSubview:imageView];

    // Add library, publisher, pubyear, and format
    float infoHeight = totalHeight;
    
    if([strLibrary length] != 0)
    {
        lblLibrary = [[UILabel alloc] initWithFrame:CGRectMake(135, infoHeight, 179, 32)];
        lblLibrary.backgroundColor = [UIColor clearColor];
        lblLibrary.text = strLibrary;
        [lblLibrary resizeToFit];
        [scroller addSubview:lblLibrary];
        infoHeight += lblLibrary.frame.size.height;
    }

    if([strPublisher length] != 0)
    {
        lblPublisher = [[UILabel alloc] initWithFrame:CGRectMake(135, infoHeight, 179, 32)];
        lblPublisher.backgroundColor = [UIColor clearColor];
        lblPublisher.text = strPublisher;
        [lblPublisher resizeToFit];
        [scroller addSubview:lblPublisher];
        infoHeight += lblPublisher.frame.size.height;
    }

    if([strPubyear length] != 0)
    {
        lblPubyear = [[UILabel alloc] initWithFrame:CGRectMake(135, infoHeight, 179, 32)];
        lblPubyear.backgroundColor = [UIColor clearColor];
        lblPubyear.text = strPubyear;
        [lblPubyear resizeToFit];
        [scroller addSubview:lblPubyear];
        infoHeight += lblPubyear.frame.size.height;
    }

    if([strFormat length] != 0)
    {
        lblFormat = [[UILabel alloc] initWithFrame:CGRectMake(135, infoHeight, 179, 32)];
        lblFormat.backgroundColor = [UIColor clearColor];
        lblFormat.text = strFormat;
        [lblFormat resizeToFit];
        [scroller addSubview:lblFormat];
        infoHeight += lblFormat.frame.size.height;
    }

    NSLog([NSString stringWithFormat:@"%f",infoHeight]);
    NSLog([NSString stringWithFormat:@"%f",(totalHeight + imageView.frame.size.height)]);
    
    // Adjust height
    if(imageView.frame.size.height + totalHeight < infoHeight)
        totalHeight = infoHeight;
    else
        totalHeight += imageView.frame.size.height;
            
    // Add description title and summary
    if([strSummary length] != 0)
    {
        // Add descripition label
        lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(7, totalHeight, 87, 32)];
        lblDescription.backgroundColor = [UIColor clearColor];
        lblDescription.text = @"Description";
        [lblDescription resizeToFit];
        [scroller addSubview:lblDescription];
        totalHeight += lblDescription.frame.size.height;

        // Add summary
        lblSummary = [[UILabel alloc] initWithFrame:CGRectMake(7, totalHeight, 280, 32)];
        lblSummary.backgroundColor = [UIColor whiteColor];
        lblSummary.text = strSummary;
        [lblSummary resizeToFit];
        
        lblSummary.layer.cornerRadius = 5;
        lblSummary.layer.borderColor = [UIColor grayColor].CGColor;
        lblSummary.layer.borderWidth = 1;
        lblSummary.layer.masksToBounds = YES;

        [scroller addSubview:lblSummary];
        totalHeight += lblSummary.frame.size.height;
    }

    scroller.contentSize = CGSizeMake(scroller.frame.size.width, scroller.frame.origin.y +totalHeight);
    
    [scroller setScrollEnabled:YES];
}

@end
