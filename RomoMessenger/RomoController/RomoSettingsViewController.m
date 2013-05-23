//
//  RomoSettingsViewController.m
//  RomoMessenger
//
//  Created by Yuanfeng on 2013-05-22.
//  Copyright (c) 2013 University of Waterloo. All rights reserved.
//

#import "RomoSettingsViewController.h"

#import "AppDelegate.h"

@interface RomoSettingsViewController ()

@end

@implementation RomoSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSwitchToControllerClicked:(id)sender {
    [self.delegate romoSettingsViewControllerDidFinish:self];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate switchToSendViewController];
}

- (IBAction)onDoneClicked:(id)sender {
    [self.delegate romoSettingsViewControllerDidFinish:self];
}
@end
