//
//  WayFinder.m
//  minrva
//
//  Created by Jim Hahn on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WayFinder.h"
#import "SBJson.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"

@implementation WayFinder

@synthesize screenWidth;
@synthesize screenHeight;
@synthesize wRatio;
@synthesize hRatio;

@synthesize main;
@synthesize imageView;

@synthesize wayfinder_service;
@synthesize jpg_service;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Locate", @"Fourth");
        self.tabBarItem.image = [UIImage imageNamed:@"fourth"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - Gesture recognition

- (void)panDetected:(UIPanGestureRecognizer *)panRecognizer
{
    CGPoint translation = [panRecognizer translationInView:self.view];
    CGPoint imageViewPosition = self.imageView.center;
    imageViewPosition.x += translation.x;
    imageViewPosition.y += translation.y;
    
    self.imageView.center = imageViewPosition;
    [panRecognizer setTranslation:CGPointZero inView:self.view];
}

- (void)pinchDetected:(UIPinchGestureRecognizer *)pinchRecognizer
{
    CGFloat scale = pinchRecognizer.scale;
    self.imageView.transform = CGAffineTransformScale(self.imageView.transform, scale, scale);
    pinchRecognizer.scale = 1.0;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - View lifecycle

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
    main = [[UIView alloc] initWithFrame:CGRectMake(0, titleBar.frame.size.height, screenWidth, contentHeight)];
    main.backgroundColor = [UIColor clearColor];
    [self.view addSubview:main];
    
    // Get root uri from properties.plist
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistXML
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:nil
                                          errorDescription:nil];
    self.wayfinder_service = [temp objectForKey:@"wayfinder_service"];
    self.jpg_service = [temp objectForKey:@"jpg_service"];
 
    // Request JSON
    responseData = [NSMutableData data];
    NSString *url = self.wayfinder_service;
    AppDelegate* appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    url = [url stringByAppendingString:appDel.bibId];
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
    for (UIView *subview in [self.main subviews])
    {
        for (UIView *subview2 in [subview subviews])
            [subview2 removeFromSuperview];
        [subview removeFromSuperview];
    }
    
    // Remove dynamic layout elements from main view
    for (UIView *subview in [self.view subviews])
        [subview removeFromSuperview];

    wayfinder_service = nil;
    jpg_service = nil;
    main = nil;
    imageView = nil;
    responseData = nil;
    theConnection = nil;

	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    //    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    //} else {
    //    return YES;
   // }
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

-(UIImage*)modify: (UIImage*)source:(CGFloat) xCoor: (CGFloat) yCoor
{
    // Create canvas
    CGImageRef sourceRef = source.CGImage;
    size_t width = CGImageGetWidth(sourceRef);
    size_t height = CGImageGetHeight(sourceRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel    = 4;
    size_t bytesPerRow      = (width * bitsPerComponent * bytesPerPixel + 7) / 8;
    size_t dataSize         = bytesPerRow * height;
    
    unsigned char *data = malloc(dataSize);
    memset(data, 0, dataSize);
    
    
    CGContextRef context = CGBitmapContextCreate(data, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), sourceRef);
    
    
    // Draw a circle (filled)
    CGContextSetRGBFillColor(context, 1.00, 0.00, 0.00, 1.0);
    CGRect rectangle = CGRectMake(xCoor - 5, height - yCoor - 5, 10, 10);
    CGContextFillEllipseInRect(context, rectangle);
    
    // Save to image
    CGColorSpaceRelease(colorSpace);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGContextRelease(context);
    free(data);
    
    return result;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{    
    // Get response string
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    // Get JSON object
    NSArray *descrs = [responseString JSONValue];
    NSDictionary *descr = nil;
    if([descrs count] != 0)
        descr = [descrs objectAtIndex:0];
    
    // Get data
    NSString* strTitle = @"";
    NSString* strShelfId = @"";
    NSString* strCallNum =  @"";
    NSString* strX = @""; 
    NSString* strY =  @"";
    if(descr != nil)
    {
        strTitle = [descr objectForKey:@"title"];
        strShelfId = [descr objectForKey:@"shelf_id"];
        strCallNum =  [descr objectForKey:@"call_num"];
        strX = [descr objectForKey:@"x"];
        strY =  [descr objectForKey:@"y"];
    }
    
    // Start dynamic. layout calc.
    float medium_font_size = 16 * wRatio;
    float totalHeight = 0;
        
    // Start summary calc
    float summaryHeight = totalHeight;
    
    // Add top padding
    summaryHeight += 5 * hRatio;
    
    // Add Title
    OHAttributedLabel* lblTitle = nil;
    if([strTitle length] != 0)
    {
        // Create custom attributed string
        NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:[@"Title: " stringByAppendingString:strTitle]];
        [attrStr setFont:[UIFont systemFontOfSize:medium_font_size]];
        [attrStr setFont:[UIFont boldSystemFontOfSize:medium_font_size] range:NSMakeRange(0,6)];
        
        // Create subclassed label
        lblTitle = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(10 * wRatio, summaryHeight, 300 * wRatio, 1)];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.lineBreakMode = UILineBreakModeWordWrap;
        lblTitle.numberOfLines = 0;
        lblTitle.attributedText = attrStr;
        [lblTitle sizeToFit];
        
        // Update height
        summaryHeight += lblTitle.frame.size.height;
    }

    // Add Title
    OHAttributedLabel* lblShelfId = nil;
    if([strShelfId length] != 0)
    {
        // Create custom attributed string
        NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:[@"Shelf No.: " stringByAppendingString:strShelfId]];
        [attrStr setFont:[UIFont systemFontOfSize:medium_font_size]];
        [attrStr setFont:[UIFont boldSystemFontOfSize:medium_font_size] range:NSMakeRange(0,10)];
        
        // Create subclassed label
        lblShelfId = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(10 * wRatio, summaryHeight, 300 * wRatio, 1)];
        lblShelfId.backgroundColor = [UIColor clearColor];
        lblShelfId.lineBreakMode = UILineBreakModeWordWrap;
        lblShelfId.numberOfLines = 0;
        lblShelfId.attributedText = attrStr;
        [lblShelfId sizeToFit];
        
        // Update height
        summaryHeight += lblShelfId.frame.size.height;
    }
    
    // Add call number
    OHAttributedLabel* lblCallNum = nil;
    if([strCallNum length] != 0)
    {
        // Create custom attributed string
        NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:[@"Call No.: " stringByAppendingString:strCallNum]];
        [attrStr setFont:[UIFont systemFontOfSize:medium_font_size]];
        [attrStr setFont:[UIFont boldSystemFontOfSize:medium_font_size] range:NSMakeRange(0,9)];
        
        // Create subclassed label
        lblCallNum = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(10 * wRatio, summaryHeight, 300 * wRatio, 1)];
        lblCallNum.backgroundColor = [UIColor clearColor];
        lblCallNum.lineBreakMode = UILineBreakModeWordWrap;
        lblCallNum.numberOfLines = 0;
        lblCallNum.attributedText = attrStr;
        [lblCallNum sizeToFit];
        
        // Update height
        summaryHeight += lblCallNum.frame.size.height;
    }
    
    // Add bottom padding
    summaryHeight += 5 * hRatio;
    
    // Add bubble
    UIView* box = nil;
    if([strTitle length] != 0)
    {
        box = [[UILabel alloc] initWithFrame:CGRectMake(5 * wRatio, totalHeight, 310 * wRatio, summaryHeight)];
        box.layer.cornerRadius = 5;
        box.layer.borderColor = [UIColor grayColor].CGColor;
        box.layer.borderWidth = 1;
        box.layer.masksToBounds = YES;
    }
    
    totalHeight += box.frame.size.height;
    
    // Insert the views onto the layout
    if(box != nil)
        [main addSubview:box];
    if(lblTitle != nil)
        [main addSubview:lblTitle];
    if(lblShelfId != nil)
        [main addSubview:lblShelfId];
    if(lblCallNum != nil)
        [main addSubview:lblCallNum];
    
    // Add padding
    totalHeight += 5 * hRatio;
    
    if([strX length] != 0 && [strY length] != 0 )
    {
        // Build uri
        NSString* uri = @"";
        uri = [uri stringByAppendingString:self.jpg_service];
        uri = [uri stringByAppendingString:@"Wayfinder/please.jpg"];
        
        // Download and modify image
        UIImage* img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:uri]]];
        img = [self modify: img: [strX floatValue]: [strY floatValue]];
        
        // Add image to imageView
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5 * wRatio, main.frame.origin.y + totalHeight, 310 * wRatio, 310 * hRatio)];
        [self.imageView setImage:img];
        self.imageView.userInteractionEnabled = YES;
        [self.view insertSubview:imageView atIndex:1];
        
        // Add delegates
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
        [self.main addGestureRecognizer:panRecognizer];
        
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchDetected:)];
        [self.main addGestureRecognizer:pinchRecognizer];
        
        panRecognizer.delegate = self;
        pinchRecognizer.delegate = self;

    }
    else
    {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Map"
                                                       message: @"Sorry, map unavailable."
                                                      delegate: self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"OK",nil];
        [alert show];
    }
}




@end
