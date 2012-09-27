//
//  AppDelegate.m
//  minrva
//
//  Created by Jim Hahn on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TouchImageViewController.h"

@implementation TouchImageViewController

-(void) touchBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view]; // Create a point for where they touch
    
    image.center = location;
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchBegan:touches withEvent:event];
}

@end