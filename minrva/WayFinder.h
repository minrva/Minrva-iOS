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
    // Device Specific Dimensions
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat wRatio;
    CGFloat hRatio;

    // Settings
    NSString* wayfinder_service;
    NSString* jpg_service;
    
    // Views
    UIView* main;
    UIImageView *imageView;

    // Data
    NSMutableData* responseData;
    NSURLConnection* theConnection;
}

@property (nonatomic) CGFloat screenWidth;
@property (nonatomic) CGFloat screenHeight;
@property (nonatomic) CGFloat wRatio;
@property (nonatomic) CGFloat hRatio;

@property (nonatomic,retain) UIView* main;
@property (nonatomic,retain) UIImageView* imageView;

@property (copy, nonatomic) NSString *wayfinder_service;
@property (copy, nonatomic) NSString *jpg_service;

@end
