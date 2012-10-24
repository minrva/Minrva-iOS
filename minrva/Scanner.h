//
//  Scanner.h
//  minrva
//
//  Created by Jim Hahn on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Scanner : UIViewController< ZBarReaderDelegate, UITextFieldDelegate >
{
    // Device Specific Dimensions
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat wRatio;
    CGFloat hRatio;

    // Settings
    NSString* scanner_service;

    // Views
    UIScrollView* scroller;
    UILabel* lblScan;

    NSMutableData* responseData;
    NSURLConnection* theConnection;
}

- (void) scanButtonTapped;


@property (nonatomic) CGFloat screenWidth;
@property (nonatomic) CGFloat screenHeight;
@property (nonatomic) CGFloat wRatio;
@property (nonatomic) CGFloat hRatio;

@property (copy, nonatomic) NSString *scanner_service;

@property (retain, nonatomic) UIScrollView* scroller;
@property (retain, nonatomic) UILabel* lblScan;

@end
