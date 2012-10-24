//
//  Scanner.m
//  minrva
//
//  Created by Jim Hahn on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Scanner.h"
#import "SBJson.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

@implementation Scanner

@synthesize screenWidth;
@synthesize screenHeight;
@synthesize wRatio;
@synthesize hRatio;

@synthesize scanner_service;

@synthesize scroller;
@synthesize lblScan;

- (void) scanButtonTapped
{
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                    to: 1];
    
    // present and release the controller
    [self presentModalViewController: reader
                            animated: YES];
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // Get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results) // EXAMPLE: just grab the first barcode
        break;
    
    // Parse the barcode (get int part)
    NSCharacterSet* nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString* barcode = [symbol.data stringByTrimmingCharactersInSet:nonDigits];
    
    // Dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissModalViewControllerAnimated: YES];

    // Make uri
    responseData = [NSMutableData data];    
    NSString *uri = self.scanner_service;
    uri = [uri stringByAppendingString:barcode];

    // Request data
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:uri]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:60.0];
    theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
   [scroller setContentOffset:CGPointMake(0, lblScan.frame.origin.y) animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [scroller setContentOffset:CGPointZero animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Close the keyboard
    [textField resignFirstResponder];
    

    // Get the results
    NSString* barcode = textField.text;
    
    // Make uri
    responseData = [NSMutableData data];
    NSString *uri = self.scanner_service;
    uri = [uri stringByAppendingString:barcode];
    
    // Request data
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:uri]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:60.0];
    theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    return NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Scan", @"Third");
        self.tabBarItem.image = [UIImage imageNamed:@"third"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
  

    // Do any additional setup after loading the view from its nib.
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
    scroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, titleBar.frame.size.height, screenWidth, contentHeight)];
    [self.view addSubview:scroller];
    
    // Start dynamic. layout calc.
    float large_font_size = 18 * wRatio;    // Large font
    float medium_font_size = 16 * wRatio;   // Medium font
    float small_font_size = 14 * wRatio;    // Small font

    float totalHeight = 0;
    
    // Add locate label
    UILabel* lblLocate = [[UILabel alloc] initWithFrame:CGRectMake(10 * wRatio, totalHeight, screenWidth - 15 * wRatio, 1)];
    lblLocate.font = [UIFont systemFontOfSize:large_font_size];
    lblLocate.backgroundColor = [UIColor clearColor];
    lblLocate.lineBreakMode = UILineBreakModeWordWrap;
    lblLocate.numberOfLines = 0;
    lblLocate.text = @"1) Locate Library Barcode";
    [lblLocate sizeToFit];
    [scroller addSubview:lblLocate];
    totalHeight += lblLocate.frame.size.height;
    
    // Add padding
    totalHeight += 10 * hRatio;
    
    // Add divider
    UIView* divider1 = [[UIView alloc] initWithFrame:CGRectMake(5 * wRatio, totalHeight, screenWidth - 10 * wRatio, 2 * hRatio)];
    divider1.backgroundColor = [UIColor blackColor];
    [scroller addSubview:divider1];
    totalHeight += divider1.frame.size.height;
    
    // Add padding
    totalHeight += 25 * hRatio;
    
    // Add image example
    UIImageView* imgExample = [[UIImageView alloc] initWithFrame:CGRectMake(5 * wRatio, totalHeight, screenWidth - 10 * wRatio, 164 * hRatio)];
    [imgExample  setImage:[UIImage imageNamed:@"scanner_example.jpg"]];
    [scroller addSubview:imgExample];
    totalHeight += imgExample.frame.size.height;
    
    // Add padding
    totalHeight += 25 * hRatio;
    
    // Change input based on camera
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    bool autoFocusEnabled = false;
    if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
        autoFocusEnabled = true;
    
    // Change "scan" message
    NSString* strScan = @"2) Scan the Book";
    if(!autoFocusEnabled)
     strScan = @"2) Enter the Barcode";
    
    // Add scan label
    lblScan = [[UILabel alloc] initWithFrame:CGRectMake(10 * wRatio, totalHeight, screenWidth - 15 * wRatio, 1)];
    lblScan.font = [UIFont systemFontOfSize:large_font_size];
    lblScan.backgroundColor = [UIColor clearColor];
    lblScan.lineBreakMode = UILineBreakModeWordWrap;
    lblScan.numberOfLines = 0;
    lblScan.text = strScan;
    [lblScan sizeToFit];
    [scroller addSubview:lblScan];
    totalHeight += lblScan.frame.size.height;
    
    // Add padding
    totalHeight += 10 * hRatio;
    
    // Add divider
    UIView* divider2 = [[UIView alloc] initWithFrame:CGRectMake(5 * wRatio, totalHeight, screenWidth - 10 * wRatio, 2 * hRatio)];
    divider2.backgroundColor = [UIColor blackColor];
    [scroller addSubview:divider2];
    totalHeight += divider2.frame.size.height;
    
    // Add padding
    totalHeight += 15 * hRatio;
    
    
    //  look at all the video devices and get the first one that's on the front
    if ( autoFocusEnabled )
    {
        // Add button
        NSString* btnTitle = @"Start Scanning";
        CGSize strSize = [btnTitle sizeWithFont:[UIFont systemFontOfSize:small_font_size]];
        float btnWidth = 10 * wRatio + strSize.width;
        float btnHeight = 16 * hRatio + strSize.height;
        UIButton* btnScan = [UIButton buttonWithType:UIButtonTypeCustom];
        btnScan.frame = CGRectMake((screenWidth - btnWidth)/2, totalHeight, btnWidth, btnHeight);
        btnScan.layer.cornerRadius = 6 * wRatio;
        btnScan.layer.borderColor = [UIColor colorWithRed:0.643 green:0.502 blue:0.243 alpha:1].CGColor;
        btnScan.layer.borderWidth = 1.5 * wRatio;
        btnScan.layer.masksToBounds = YES;
        btnScan.titleLabel.font = [UIFont systemFontOfSize:small_font_size];
        [btnScan setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnScan setTitle:btnTitle forState:UIControlStateNormal];
        [btnScan setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
        
        [btnScan addTarget:self action:@selector(scanButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        [scroller addSubview:btnScan];
        totalHeight += btnScan.frame.size.height;
    }
    else
    {
        // Add a text field
        UITextField* searchField = [[UITextField alloc] initWithFrame:CGRectMake(5 * wRatio, totalHeight, screenWidth - 10 * wRatio, 35 * hRatio)];
        searchField.borderStyle = UITextBorderStyleRoundedRect;
        searchField.font = [UIFont systemFontOfSize:medium_font_size];
        searchField.placeholder = @"Input Barcode";
        searchField.autocorrectionType = UITextAutocorrectionTypeNo;
        searchField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        searchField.returnKeyType = UIReturnKeyDone;
        searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
        searchField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        searchField.delegate = self;
        [scroller addSubview:searchField];
        totalHeight += searchField.frame.size.height;
        
        totalHeight += lblScan.frame.origin.y;
    }
         
    // Resize scroller
    scroller.contentSize = CGSizeMake(screenWidth, totalHeight);
    [scroller setScrollEnabled:YES];
    
    // Get root uri from properties.plist
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistXML
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:nil
                                          errorDescription:nil];
    self.scanner_service = [temp objectForKey:@"scanner_service"];

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
    scanner_service = nil;
    scroller = nil;
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
    //}
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

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // Get response string
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];  
    
    // Get JSON array
    NSArray *bibIds = [responseString JSONValue];
    
    // Convert JSON array into bibliogrphaic string
    NSString* strBibId = @"";
    for (NSDictionary *bibId in bibIds) 
    {
        // Get raw data
        strBibId = [bibId objectForKey:@"bib"];
        NSLog(@"BibId: %@", bibId);
    }
    
    // Save results and switch tabs
    AppDelegate* appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDel.bibId = strBibId;
    appDel.tabBarController.selectedIndex = 0;
}
@end
