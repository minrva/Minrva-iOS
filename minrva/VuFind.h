//
//  VuFind.h
//  minrva
//
//  Created by Jim Hahn on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VuFind : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>  
{
    NSMutableData* responseData;
    NSURLConnection* theConnection;
    
    NSString* vufind_service;

    
    IBOutlet UITableView* tableView;
    IBOutlet UITextField* searchField;
    IBOutlet UISegmentedControl* selector;
    IBOutlet UIButton* searchType;
    
    NSMutableArray* bibIds;
    NSMutableArray* thumbnails;
    NSMutableArray* summaries;
    
    NSString* type;
    NSInteger page;
    NSInteger loadingMore;
}

-(IBAction)startSelection;
-(IBAction)changeSeg;
-(void)addMore;

@property (nonatomic,retain) UITableView* tableView;
@property (nonatomic,retain) UITextField* searchField;
@property (nonatomic,retain) UISegmentedControl* selector;
@property (nonatomic,retain) UIButton* searchType;
@property (nonatomic,retain) NSString* type;
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,assign) NSInteger loadingMore;
@property (copy, nonatomic) NSString *vufind_service;

@end
