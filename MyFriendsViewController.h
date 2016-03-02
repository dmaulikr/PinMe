//
//  MyFriendsViewController.h
//  Pinguide
//
//  Created by Kevin on 12/13/15.
//  Copyright © 2015 LMMSKZ. All rights reserved.
//

#import "RootViewController.h"
#import "FriendViewController.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface MyFriendsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (copy, nonatomic) NSArray<PFUser *> *friends;
@property (weak, nonatomic) RootViewController *root;
@property (weak, nonatomic) PFUser *user;
@property (weak, nonatomic) PFUser *selectedFriend;

@end
