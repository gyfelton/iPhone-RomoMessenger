//
//  MainViewController.h
//  RomoMessenger
//
//  Created by Yuanfeng on 2013-05-22.
//  Copyright (c) 2013 University of Waterloo. All rights reserved.
//

#import "SendSettingsViewController.h"
#import <UIKit/UIKit.h>

@interface SendViewController :
    UIViewController <SendSettingsViewControllerDelegate>
{
    IBOutlet UIView *_expressionKeyboard;
}

- (IBAction)showSettings:(id)sender;



- (IBAction)onExpressionClicked:(id)sender;


@end
