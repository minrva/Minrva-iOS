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
#import <QuartzCore/QuartzCore.h>

@implementation VuFind

@synthesize screenWidth;
@synthesize screenHeight;
@synthesize wRatio;
@synthesize hRatio;

@synthesize group;
@synthesize tableView;
@synthesize searchField;
@synthesize searchType;
@synthesize type;
@synthesize page;
@synthesize pagesLoading;

@synthesize vufind_service;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        self.title = NSLocalizedString(@"Search", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark Table

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
        UILabel* lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10 * wRatio, totalHeight, 310 * wRatio, 1)];
        lblTitle.font = [UIFont systemFontOfSize:12 * wRatio];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.lineBreakMode = UILineBreakModeWordWrap;
        lblTitle.numberOfLines = 0;
        lblTitle.text = [titles objectAtIndex:index];
        [lblTitle sizeToFit];
        totalHeight += lblTitle.frame.size.height;
        
        // Add padding
        totalHeight += 1 * hRatio;

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
        UILabel* lblSummary = [[UILabel alloc] initWithFrame:CGRectMake(85 * wRatio, totalHeight, 235 * wRatio, 1)];
        lblSummary.font = [UIFont systemFontOfSize:16 * wRatio];
        lblSummary.backgroundColor = [UIColor clearColor];
        lblSummary.lineBreakMode = UILineBreakModeWordWrap;
        lblSummary.numberOfLines = 0;
        lblSummary.text = [summaries objectAtIndex:index];
        [lblSummary sizeToFit];
        
        if(lblSummary.frame.size.height < 100 * hRatio)
        {
            CGRect summaryFrame = lblSummary.frame;
            CGFloat newY = totalHeight + 50 * hRatio - summaryFrame.size.height/2;
            summaryFrame.origin.y = newY;
            lblSummary.frame = summaryFrame;
        }
        
        // Decide which column is bigger
        if(100 * hRatio < lblSummary.frame.size.height)
            totalHeight += lblSummary.frame.size.height;
        else
            totalHeight += 100 * hRatio;
     
        // Add padding
        totalHeight += 10 * hRatio;
    }

    return totalHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell  = nil;
    UILabel* lblTitle = nil;
    UIView* div = nil;
    UIImageView* imageView = nil;
    UILabel* lblSummary = nil;
    
    // Get row type
    int rowType = indexPath.row % 2;

    // Create Views & SubViews if Cached Not Available
    cell  = [tv dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"Cell%d", rowType]];
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
            lblTitle = [[UILabel alloc] initWithFrame:CGRectZero];
            lblTitle.font = [UIFont systemFontOfSize:12 * wRatio];
            lblTitle.backgroundColor = [UIColor clearColor];
            lblTitle.lineBreakMode = UILineBreakModeWordWrap;
            lblTitle.numberOfLines = 0;
            lblTitle.tag = 1;
            [cell.contentView addSubview:lblTitle];
            
            
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
            
            // Add summary (2)
            lblSummary = [[UILabel alloc] initWithFrame:CGRectZero];
            lblSummary.font = [UIFont systemFontOfSize:16 * wRatio];
            lblSummary.backgroundColor = [UIColor clearColor];
            lblSummary.lineBreakMode = UILineBreakModeWordWrap;
            lblSummary.numberOfLines = 0;
            lblSummary.tag = 2;
            [cell.contentView addSubview:lblSummary];
        }
    }
    
    // Add Content and Position Views
    if(rowType == 0)
    {
        // Get index of data
        int index = indexPath.row/2;
        
        // Get label
        if (lblTitle == nil)
            lblTitle = (UILabel*)[cell viewWithTag:1];
        
        // Get div
        if (div == nil)
            div = (UIView*)[cell viewWithTag:2];
        
        // Start position calc.
        float totalHeight = 0;
        
        // Add title
        lblTitle.frame = CGRectMake(10 * wRatio, totalHeight, 310 * wRatio, 1);
        lblTitle.text = [titles objectAtIndex:index];
        [lblTitle sizeToFit];
        totalHeight += lblTitle.frame.size.height;
        
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
        if (lblSummary == nil)
            lblSummary = (UILabel*)[cell viewWithTag:2];
        
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
        lblSummary.frame = CGRectMake(imageWidth + padding, totalHeight, countWidth, 1);
        lblSummary.text = [summaries objectAtIndex:index];
        [lblSummary sizeToFit];
        
        
        if(lblSummary.frame.size.height < imageView.frame.size.height)
        {
            CGRect summaryFrame = lblSummary.frame;
            CGFloat newY = totalHeight + imageView.frame.size.height/2 - summaryFrame.size.height/2;
            summaryFrame.origin.y = newY;
            lblSummary.frame = summaryFrame;
        }
        [cell.contentView addSubview:lblSummary];
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

#pragma User Actions
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    NSArray *visibleRows = [self.tableView visibleCells];
    UITableViewCell *lastVisibleCell = [visibleRows lastObject];
    NSIndexPath *path = [self.tableView indexPathForCell:lastVisibleCell];
    NSInteger totalRows = [bibIds count];
   
    if((path.row >=  totalRows - 60) && totalRows != 0 && totalRows % 20 == 0)
    {
        [self addMore:NO];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
    if (textField == searchField)
    {
        // Close the keyboard
        [textField resignFirstResponder];
        
        // Add more data
        [self addMore:YES];
        
    }
    
    return NO;
}

-(void) RadioButtonGroup:(RadioButtonGroup*)RadioButtonGroup selectedIndex:(int) index;
{
    // Add more data
    [self addMore: YES];
}

-(void) startSelection
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
    UILabel* lbl = (UILabel*) [searchType viewWithTag:1];
    lbl.text = text;
    //[searchType setTitle:text forState:UIControlStateNormal];
    //[searchType setTitle:text forState:UIControlStateHighlighted];
    //[searchType setTitle:text forState:UIControlStateDisabled];
    //[searchType setTitle:text forState:UIControlStateSelected];
    
    // Release menu
    [self dismissModalViewControllerAnimated:YES];   
    
    // Add data
    [self addMore:YES];
}

#pragma mark Search

-(void)addMore:(BOOL) clearTable
{
    // Purge current connection
    if(clearTable)
    {
        // Cancel current downloads
        [theConnection cancel];
        theConnection = nil;
        
        // Clear data
        [self clearData];
        
        // Reload table
        [tableView reloadData];
    }

    if(pagesLoading == 0)
    {
        // Loading 1st page, so ignore new requests from scroller
        pagesLoading = 1;
        
        // Get query
        NSString* theQuery = @"";
        theQuery = [self.searchField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        // Get domain
        NSString* theDomain = @"";
        if(group.cur_index == 0)
        { theDomain = [theDomain stringByAppendingString:@"uiu"]; }
        else if(group.cur_index == 1)
        { theDomain = [theDomain stringByAppendingString:@"all"]; }

        // Get search type
        NSString* theType = self.type;
            
        // Get page number
        self.page++;
        NSString* thePage = [NSString stringWithFormat:@"%d", self.page];
    
        // Get webservice uri
        NSString *uri = self.vufind_service;
    
        // Append parameters
        uri = [uri stringByAppendingString: @"?lookfor="];
        if([theQuery length] != 0)
            uri = [uri stringByAppendingString:theQuery];
    
        uri = [uri stringByAppendingString:@"&page="];
        if([thePage length] != 0)
            uri = [uri stringByAppendingString:thePage];
    
        uri = [uri stringByAppendingString:@"&domain="];
        if([theDomain length] != 0)
            uri = [uri stringByAppendingString:theDomain];
    
        uri = [uri stringByAppendingString:@"&type="];
        if([theType length] != 0)
            uri = [uri stringByAppendingString:theType];

        NSLog(uri);
        
        // Asynch begin
        responseData = [NSMutableData data];
        NSURLRequest *theRequest=[NSURLRequest     requestWithURL:[NSURL URLWithString:uri]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                   timeoutInterval:60.0];
    
        theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
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
    [self clearData];
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
            NSString* title = [model objectForKey:@"title"];
            NSString* thumbnail = [model objectForKey:@"thumbnail"];
            NSString* location = [model objectForKey:@"location"];
            NSString* author = [model objectForKey:@"author"];
            NSString* pubYear = [model objectForKey:@"pubYear"];
            NSString* format = [model objectForKey:@"format"];
        
            // Format data
            title = [title uppercaseString];

            NSString* summary = @"";
            
            if([location length] != 0)
            {
                summary = [summary stringByAppendingString:@"Location: "];
                summary = [summary stringByAppendingString:location];
                summary = [summary stringByAppendingString:@"\n"];
            }
            
            if([author length] != 0)
            {
                summary = [summary stringByAppendingString:@"Author: "];
                summary = [summary stringByAppendingString:author];
                summary = [summary stringByAppendingString:@"\n"];
            }
            
            if([pubYear length] != 0)
            {
                summary = [summary stringByAppendingString:@"Pub. Date: "];
                summary = [summary stringByAppendingString:pubYear];
                summary = [summary stringByAppendingString:@"\n"];
            }
            
            if([format length] != 0)
            {
                summary = [summary stringByAppendingString:@"Format: "];
                summary = [summary stringByAppendingString:format];
                summary = [summary stringByAppendingString:@"\n"];
            }
            
            NSLog(@"BibId: %@", bibId);

            // Add data to data adapters
            [bibIds addObject:bibId];
            [titles addObject:title];
            [thumbnails addObject:thumbnail];
            [summaries addObject:summary];
        }
    }

    
    if(pagesLoading == 1)
    {
        // Loading 2nd page, so ignore new requests from scroller
        pagesLoading = 2;
        
        // Get query
        NSString* theQuery = @"";
        theQuery = [self.searchField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        // Get domain
        NSString* theDomain = @"";
        if(group.cur_index == 0)
        { theDomain = [theDomain stringByAppendingString:@"uiu"]; }
        else if(group.cur_index == 1)
        { theDomain = [theDomain stringByAppendingString:@"all"]; }
        
        // Get search type
        NSString* theType = self.type;
        
        // Get page number
        self.page++;
        NSString* thePage = [NSString stringWithFormat:@"%d", self.page];
        
        // Get webservice uri
        NSString *uri = self.vufind_service;
        
        // Append parameters
        uri = [uri stringByAppendingString: @"?lookfor="];
        if([theQuery length] != 0)
            uri = [uri stringByAppendingString:theQuery];
        
        uri = [uri stringByAppendingString:@"&page="];
        if([thePage length] != 0)
            uri = [uri stringByAppendingString:thePage];
        
        uri = [uri stringByAppendingString:@"&domain="];
        if([theDomain length] != 0)
            uri = [uri stringByAppendingString:theDomain];
        
        uri = [uri stringByAppendingString:@"&type="];
        if([theType length] != 0)
            uri = [uri stringByAppendingString:theType];
        
        NSLog(uri);
        
        // Asynch begin
        responseData = [NSMutableData data];
        NSURLRequest *theRequest=[NSURLRequest     requestWithURL:[NSURL URLWithString:uri]
                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                  timeoutInterval:60.0];
        
        theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    }
    else
    {
        // Reload table
        [tableView reloadData];
    
        // No more to load
        pagesLoading = 0;
    }
}


#pragma mark - VIEW LIFECYCLE

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    UIView* main = [[UIView alloc] initWithFrame:CGRectMake(0, titleBar.frame.size.height, screenWidth, contentHeight)];
    main.backgroundColor = [UIColor clearColor];
    [self.view addSubview:main];
    
    // Start dynamic. layout calc.
    float medium_font_size = 16 * wRatio;
    float small_font_size = 14 * wRatio;

    float totalHeight = 0;

    // Add radio button group
	NSArray *options =[[NSArray alloc]initWithObjects:@"UGL", @"I-Share", nil];
	group =[[RadioButtonGroup alloc]initWithFrame:CGRectMake(0, totalHeight, screenWidth, 44 * hRatio)
                                                                andOptions:options
                                                                andColumns:2
                                                                andFontSize:medium_font_size ];
    group.groupDelegate = self;
	[main addSubview:group];
    totalHeight += group.frame.size.height;

    // Add padding
    totalHeight += 5 * wRatio;

    // Add search box
    searchField = [[UITextField alloc] initWithFrame:CGRectMake(5 * wRatio, totalHeight, 200 * wRatio, 35 * hRatio)];
    searchField.borderStyle = UITextBorderStyleRoundedRect;
    searchField.font = [UIFont systemFontOfSize:medium_font_size];
    searchField.placeholder = @"Search";
    searchField.autocorrectionType = UITextAutocorrectionTypeNo;
    searchField.keyboardType = UIKeyboardTypeDefault;
    searchField.returnKeyType = UIReturnKeyDone;
    searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    searchField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    searchField.delegate = self;
    [main addSubview:searchField];
    
    // Add button
    float btnX = searchField.frame.origin.x + searchField.frame.size.width + 5 * wRatio;
    float btnWidth = screenWidth - btnX - 5 * wRatio;

    searchType = [UIButton buttonWithType:UIButtonTypeCustom];
    searchType.frame = CGRectMake(btnX, totalHeight, btnWidth, 35 * hRatio);
    searchType.layer.cornerRadius = 6 * wRatio;
    searchType.layer.borderColor = [UIColor colorWithRed:0.643 green:0.502 blue:0.243 alpha:1].CGColor;
    searchType.layer.borderWidth = 1.5 * wRatio;
    searchType.layer.masksToBounds = YES;
    [searchType setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    
    float btnLblX = 5 * wRatio;
    float btnLblY = 8 * hRatio;
    float btnLblWidth = (searchType.frame.size.width - 10 * hRatio) * 0.70;
    float btnLblHeight = searchType.frame.size.height - 16 * hRatio;
    UILabel* btnLbl = [ [UILabel alloc] initWithFrame:CGRectMake(btnLblX, btnLblY, btnLblWidth, btnLblHeight) ];
    btnLbl.tag = 1;
    btnLbl.text = @"Keyword";
    btnLbl.backgroundColor = [UIColor clearColor];
    btnLbl.font = [UIFont systemFontOfSize:small_font_size];
    [searchType addSubview:btnLbl];

    float btnDivX = btnLbl.frame.origin.y + btnLbl.frame.size.width;
    float btnDivY = 0;
    float btnDivWidth = 1 * wRatio;
    float btnDivHeight = searchType.frame.size.height;
    UIImageView* btnDiv = [ [UIImageView alloc] initWithFrame:CGRectMake(btnDivX, btnDivY, btnDivWidth, btnDivHeight) ];
    btnDiv.tag = 2;
    [btnDiv setImage:[UIImage imageNamed:@"div"]];
    [searchType addSubview:btnDiv];

    float btnArrWidth = searchType.frame.size.width - (btnDiv.frame.origin.x + btnDiv.frame.size.width) - 1.5 * wRatio;
    float btnArrHeight = searchType.frame.size.height;
    float btnArrDim = 0;
    
   
    if(btnArrWidth > btnArrHeight)
        btnArrDim = btnArrHeight;
    else
        btnArrDim = btnArrWidth;
    
    float btnArrX = btnDiv.frame.origin.x + btnDiv.frame.size.width + (btnArrWidth - btnArrDim)/2.0;
    float btnArrY = (btnArrHeight - btnArrDim)/2.0;

    UIImageView* btnArr = [ [UIImageView alloc] initWithFrame:CGRectMake(btnArrX, btnArrY, btnArrDim, btnArrDim) ];
    btnArr.tag = 3;
    [btnArr setImage:[UIImage imageNamed:@"spinner"]];
    btnArr.backgroundColor = [UIColor clearColor];
    [searchType addSubview:btnArr];
    
    [searchType addTarget:self action:@selector(startSelection) forControlEvents:UIControlEventTouchUpInside];
    
    [main addSubview:searchType];

    // Add button height
    totalHeight += searchType.frame.size.height;

    // Add padding
    totalHeight += 5 * wRatio;
    
    // Add table view
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, totalHeight, screenWidth, contentHeight - totalHeight)];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    [main addSubview:tableView];
    
    // Get root uri from properties.plist
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"plist"];
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistXML
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:nil
                                          errorDescription:nil];
    self.vufind_service = [temp objectForKey:@"vufind_service"];

    // Init data
    [self clearData];
}

- (void) clearData
{
    page = 0;
    pagesLoading = 0;
    bibIds = [NSMutableArray array];
    titles = [NSMutableArray array];
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
    //if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    //    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    //} else {
     //   return YES;
    //}
    
    return NO;
}

@end
