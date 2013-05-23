//
//  MainViewController.m
//  RomoMessenger
//
//  Created by Yuanfeng on 2013-05-22.
//  Copyright (c) 2013 University of Waterloo. All rights reserved.
//

#import "SendViewController.h"

@interface SendViewController ()

@end

@implementation SendViewController

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

#pragma mark - Flipside View

- (void)sendSettingsViewControllerDidFinish:(SendSettingsViewController *)controller
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)showSettings:(id)sender
{    
    SendSettingsViewController *controller = [[SendSettingsViewController alloc] initWithNibName:nil bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
}

@end
