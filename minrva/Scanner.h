//
//  Scanner.h
//  minrva
//
//  Created by Jim Hahn on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Scanner : UIViewController
// ADD: delegate protocol
< ZBarReaderDelegate >
{
    NSMutableData* responseData;
    NSURLConnection* theConnection;
    
    NSString* scanner_service;

}

- (IBAction) scanButtonTapped;

@property (copy, nonatomic) NSString *scanner_service;

@end
