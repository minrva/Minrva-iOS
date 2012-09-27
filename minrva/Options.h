//
//  Options.h
//  Minrva
//
//  Created by Jim Hahn on 9/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OptionViewControllerDelegate;

@interface Options : UITableViewController
{
    IBOutlet UITableView* tableView;
    NSMutableArray* options;
    
    __unsafe_unretained id<OptionViewControllerDelegate> optionsDelegate;
}

@property (nonatomic, unsafe_unretained) id optionsDelegate;  
@property (nonatomic,retain) UITableView* tableView;
@end

@protocol OptionViewControllerDelegate <NSObject>
-(void) Options:(Options*)Options didFinishWithSelection:(NSInteger) index;
@end
