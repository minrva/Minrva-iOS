//
//  LoanableTech.h
//  minrva
//
//  Created by Jim Hahn on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoanableTech : UIViewController <UITableViewDelegate, UITableViewDataSource>  
{
    // Device Specific Dimensions
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat wRatio;
    CGFloat hRatio;
    
    NSMutableData* responseData;
    NSURLConnection* theConnection;
    
    UITableView* tv;
    
    NSString* loanabletech_service;
    NSString* jpg_service;

    NSMutableArray* bibIds;
    NSMutableArray* names;

    NSMutableArray* thumbnails;
    NSMutableArray* counts;
}

@property (nonatomic) CGFloat screenWidth;
@property (nonatomic) CGFloat screenHeight;
@property (nonatomic) CGFloat wRatio;
@property (nonatomic) CGFloat hRatio;

@property (nonatomic,retain) UITableView* tv;
@property (copy, nonatomic) NSString *loanabletech_service;
@property (copy, nonatomic) NSString *jpg_service;

@end
