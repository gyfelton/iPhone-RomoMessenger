//
//  MainViewController.h
//  RomoMessenger
//
//  Created by Yuanfeng on 2013-05-22.
//  Copyright (c) 2013 University of Waterloo. All rights reserved.
//

#import "SendSettingsViewController.h"

@interface SendViewController : UIViewController <SendSettingsViewControllerDelegate>

- (IBAction)showSettings:(id)sender;

@end
