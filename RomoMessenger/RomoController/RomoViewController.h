//
//  RomoViewController.h
//  RomoMessenger
//
//  Created by Yuanfeng on 2013-05-22.
//  Copyright (c) 2013 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RomoSettingsViewController.h"
@interface RomoViewController : UIViewController <RomoSettingsViewControllerDelegate>
- (IBAction)showSettings:(id)sender;

@end
