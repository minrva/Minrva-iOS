//
//  Options.h
//  Minrva
//
//  Created by Jim Hahn on 9/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OptionViewControllerDelegate;

@interface Options : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    // Device Specific Dimensions
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat wRatio;
    CGFloat hRatio;

    UITableView* tv;
    NSMutableArray* options;
    
    __unsafe_unretained id<OptionViewControllerDelegate> optionsDelegate;
}

@property (nonatomic, unsafe_unretained) id optionsDelegate;  
@property (nonatomic,retain) UITableView* tv;
@end

@protocol OptionViewControllerDelegate <NSObject>
-(void) Options:(Options*)Options didFinishWithSelection:(NSInteger) index;
@end
