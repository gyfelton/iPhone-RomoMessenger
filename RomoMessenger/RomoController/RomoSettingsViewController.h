//
//  RomoSettingsViewController.h
//  RomoMessenger
//
//  Created by Yuanfeng on 2013-05-22.
//  Copyright (c) 2013 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RomoSettingsViewController;

@protocol RomoSettingsViewControllerDelegate
- (void)romoSettingsViewControllerDidFinish:(RomoSettingsViewController *)controller;
@end

@interface RomoSettingsViewController : UIViewController

@property (weak, nonatomic) id <RomoSettingsViewControllerDelegate> delegate;

- (IBAction)onSwitchToControllerClicked:(id)sender;
- (IBAction)onDoneClicked:(id)sender;

@end
