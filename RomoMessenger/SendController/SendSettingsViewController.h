//
//  FlipsideViewController.h
//  RomoMessenger
//
//  Created by Yuanfeng on 2013-05-22.
//  Copyright (c) 2013 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SendSettingsViewController;

@protocol SendSettingsViewControllerDelegate
- (void)sendSettingsViewControllerDidFinish:(SendSettingsViewController *)controller;
@end

@interface SendSettingsViewController : UIViewController

@property (weak, nonatomic) id <SendSettingsViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;
- (IBAction)onSwitchToRomoClicked:(id)sender;

@end
