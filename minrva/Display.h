//
//  Display.h
//  minrva
//
//  Created by Jim Hahn on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Display : UIViewController
{
    // Interface elements
    UILabel* lblTitle;
    UILabel* lblAuthor;
    
    UIView* div1;

    UIImageView* imageView;

    UILabel* lblLibrary;
    UILabel* lblPublisher;
    UILabel* lblPubyear;
    UILabel* lblFormat;

    UILabel* lblHoldings;
    UILabel* lblDescription;
    UILabel* lblSummary;

    IBOutlet UIScrollView* scroller;
    
    // JSON Data
    NSString* display_service;
    NSMutableData* responseData;
    NSURLConnection* theConnection;
}

@property (nonatomic,retain) UILabel* lblTitle;
@property (nonatomic,retain) UILabel* lblAuthor;
@property (nonatomic,retain) UIView* div1;

@property (nonatomic,retain) UIImageView* imageView;
@property (nonatomic,retain) UILabel* lblLibrary;
@property (nonatomic,retain) UILabel* lblPublisher;
@property (nonatomic,retain) UILabel* lblPubyear;
@property (nonatomic,retain) UILabel* lblFormat;
@property (nonatomic,retain) UILabel* lblHoldings;
@property (nonatomic,retain) UILabel* lblDescription;
@property (nonatomic,retain) UILabel* lblSummary;

@property (nonatomic,retain) UIScrollView* scroller;

@property (copy, nonatomic) NSString *display_service;

@end
