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
    NSMutableData* responseData;
    NSURLConnection* theConnection;
    
    IBOutlet UITableView* tableView;
    
    NSString* loanabletech_service;
    NSString* jpg_service;

    NSMutableArray* bibIds;
    NSMutableArray* thumbnails;
    NSMutableArray* summaries;
}

@property (nonatomic,retain) UITableView* tableView;
@property (copy, nonatomic) NSString *loanabletech_service;
@property (copy, nonatomic) NSString *jpg_service;

@end
