//
//  VuFind.h
//  minrva
//
//  Created by Jim Hahn on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioButtonGroup.h"

@interface VuFind : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    // Device Specific Dimensions
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat wRatio;
    CGFloat hRatio;
    
    // Settings
    NSString* vufind_service;
    NSString* domain;
    NSString* lookfor;
    NSString* type;
    NSInteger page;
    NSInteger pagesLoading;

    // Views
    RadioButtonGroup* group;
    UITextField* searchField;
    UIButton* searchType;
    UITableView* tableView;

    // Data
    NSMutableArray* bibIds;
    NSMutableArray* titles;
    NSMutableArray* thumbnails;
    NSMutableArray* summaries;
    
    NSMutableData* responseData;
    NSURLConnection* theConnection;
}

-(void) startSelection;
-(void)addMore:(BOOL)clearTable;

@property (nonatomic) CGFloat screenWidth;
@property (nonatomic) CGFloat screenHeight;
@property (nonatomic) CGFloat wRatio;
@property (nonatomic) CGFloat hRatio;

@property (copy, nonatomic) NSString *vufind_service;
@property (nonatomic,retain) NSString* type;
@property (nonatomic,assign) NSInteger page;
@property (atomic,assign) NSInteger pagesLoading;

@property (nonatomic,retain) RadioButtonGroup* group;
@property (nonatomic,retain) UITextField* searchField;
@property (nonatomic,retain) UIButton* searchType;
@property (nonatomic,retain) UITableView* tableView;
@end
