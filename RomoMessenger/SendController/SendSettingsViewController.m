//
//  FlipsideViewController.m
//  RomoMessenger
//
//  Created by Yuanfeng on 2013-05-22.
//  Copyright (c) 2013 University of Waterloo. All rights reserved.
//

#import "SendSettingsViewController.h"
#import "AppDelegate.h"

@interface SendSettingsViewController ()

@end

@implementation SendSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate sendSettingsViewControllerDidFinish:self];
}

- (IBAction)onSwitchToRomoClicked:(id)sender {
    [self.delegate sendSettingsViewControllerDidFinish:self];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate switchToRomoViewController];
}

@end
