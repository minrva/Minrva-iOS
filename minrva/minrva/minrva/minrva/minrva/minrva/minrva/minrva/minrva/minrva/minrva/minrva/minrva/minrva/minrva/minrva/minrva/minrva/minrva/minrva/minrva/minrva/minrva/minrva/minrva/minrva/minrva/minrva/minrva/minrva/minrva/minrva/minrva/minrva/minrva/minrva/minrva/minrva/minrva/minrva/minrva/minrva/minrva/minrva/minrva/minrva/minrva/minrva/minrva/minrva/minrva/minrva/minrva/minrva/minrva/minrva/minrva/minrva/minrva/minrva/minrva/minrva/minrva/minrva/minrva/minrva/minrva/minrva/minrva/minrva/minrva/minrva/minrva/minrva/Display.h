//
//  Display.h
//  minrva
//
//  Created by Jim Hahn on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface Display : UIViewController
{
    // Device Specific Dimensions
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat wRatio;
    CGFloat hRatio;
    
    // Settings
    NSString* display_service;
    
    // Views
    UIScrollView* scroller;
    
    // Data
    NSString* strTitle;
    NSString* strAuthor;
    
    NSString* strThumbnail;

    NSString* strLibrary;
    NSString* strPublisher;
    NSString* strPubyear;
    NSString* strFormat;
    
    NSArray* strLocations;
    NSArray* strStatuses;
    NSArray* strCallNums;
    
    NSString* strSummary;
        
    // JSON Feed
    NSMutableData* responseData;
    NSURLConnection* connection;
}


@property (nonatomic) CGFloat screenWidth;
@property (nonatomic) CGFloat screenHeight;
@property (nonatomic) CGFloat wRatio;
@property (nonatomic) CGFloat hRatio;

@property (copy, nonatomic) NSString* display_service;

@property (retain, nonatomic) UIScrollView* scroller;

@property (copy, nonatomic) NSString* strTitle;
@property (copy, nonatomic) NSString* strAuthor;

@property (copy, nonatomic) NSString* strThumbnail;

@property (copy, nonatomic) NSString* strLibrary;
@property (copy, nonatomic) NSString* strPublisher;
@property (copy, nonatomic) NSString* strPubyear;
@property (copy, nonatomic) NSString* strFormat;

@property (copy, nonatomic) NSArray* strLocations;
@property (copy, nonatomic) NSArray* strStatuses;
@property (copy, nonatomic) NSArray* strCallNums;

@property (copy, nonatomic) NSString* strSummary;

-(void)loadDynamicLayout;

@end
