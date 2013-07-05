//
//  MessageHistoryTableViewController.h
//  RomoMessenger
//
//  Created by Irene on 3/7/13.
//  Copyright (c) 2013 University of Waterloo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageHistoryTableViewController : UITableViewController
{
    NSMutableArray *_messageHistoryArray;
}
//Precondtion: non empty string (non-nil) to be added as the latest message
//Postcondition: if return YES, then the message is added to the top of the list, showing up as the first entry in the tableView. If No, then sth goes wrong...
- (BOOL)addNewMessage:(NSString*)message;

@end
