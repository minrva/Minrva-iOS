//
//  WayFinder.h
//  minrva
//
//  Created by Jim Hahn on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WayFinder : UIViewController<UIGestureRecognizerDelegate>
{
    NSMutableData* responseData;
    NSURLConnection* theConnection;

    NSString* wayfinder_service;
    NSString* jpg_service;
    
    // Interface 
    IBOutlet UILabel* info;
    IBOutlet UIScrollView* scrollView; 
    IBOutlet UIImageView *imageView;
}

@property (nonatomic,retain) UILabel* info;
@property (nonatomic,retain) UIScrollView* scrollView;
@property (nonatomic,retain) UIImageView* imageView;
@property (copy, nonatomic) NSString *wayfinder_service;
@property (copy, nonatomic) NSString *jpg_service;

@end
