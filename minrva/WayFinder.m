//
//  WayFinder.m
//  minrva
//
//  Created by Jim Hahn on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WayFinder.h"
#import "SBJson.h"
#import "UILabel+dynamicSizeMe.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"

@implementation WayFinder
@synthesize info;
@synthesize scrollView;
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
    
    self.imageView.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
    [self.imageView addGestureRecognizer:panRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchDetected:)];
    [self.imageView addGestureRecognizer:pinchRecognizer];
    
    panRecognizer.delegate = self;
    pinchRecognizer.delegate = self;
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
    self.wayfinder_service = [temp objectForKey:@"wayfinder_service"];
    self.jpg_service = [temp objectForKey:@"jpg_service"];
    
    
    // Format the description box
    self.info.layer.cornerRadius = 5;
    self.info.layer.borderColor = [UIColor grayColor].CGColor;
    self.info.layer.borderWidth = 1;
    self.info.layer.masksToBounds = YES;
    
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

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // Get response string
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    // Get JSON array
    NSArray *models = [responseString JSONValue];
    
    //    private String bibId;//
    //	private String title;
    //	private String thumbnail;
    //	private String author;
    //	private String pubYear;
    //	private String location;
    //	private String format;
    // Convert JSON array into summaries
    NSMutableArray* xs = [NSMutableArray array];
    NSMutableArray* ys = [NSMutableArray array];
    NSMutableArray* summaries = [NSMutableArray array];
    
    for (NSDictionary *model in models)
    {
        // Get raw data
        NSString* title = [model objectForKey:@"title"];
        NSString* shelf_id = [model objectForKey:@"shelf_id"];
        NSString* call_num = [model objectForKey:@"call_num"];
        
        NSString* x = [model objectForKey:@"x"];
        NSString* y = [model objectForKey:@"y"];
        
        // Format data
        NSString* summary = @"";
        summary = [summary stringByAppendingString:@"Title: "];
        summary = [summary stringByAppendingString:title];
        summary = [summary stringByAppendingString:@"\n"];
        
        summary = [summary stringByAppendingString:@"Shelf No.: "];
        summary = [summary stringByAppendingString:shelf_id];
        summary = [summary stringByAppendingString:@"\n"];
        
        summary = [summary stringByAppendingString:@"Call No.: "];
        summary = [summary stringByAppendingString:call_num];
        summary = [summary stringByAppendingString:@"\n"];
        
        // Add data to data adapters
        [xs addObject:x];
        [ys addObject:y];
        [summaries addObject:summary];
    }
    
    // Download map, draw circle, and set image view
    NSString* uri = @"";
    uri = [uri stringByAppendingString:self.jpg_service];
    uri = [uri stringByAppendingString:@"Wayfinder/please.jpg"];
    NSLog(uri);
    
    UIImage* img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:uri]]];
    img = [self modify: img: [[xs objectAtIndex:0] floatValue]: [[ys objectAtIndex:0] floatValue]];
    [self.imageView setImage:img];
    
    
    // Here we use the new provided setImageWithURL: method to load the web image
    // [self.imageView setImageWithURL:[NSURL URLWithString:@"http://sif.grainger.uiuc.edu:8080/MinrvaServices/Jpg/Wayfinder/please.jpg"]
    //               placeholderImage:[UIImage imageNamed:@"first"]];
    
    
    // Change summary
    self.info.text = [summaries objectAtIndex:0];
    [self.info resizeToFit];
}




@end
