//
//  SearchFriendsViewController.h
//  Pinguide
//
//  Created by Kevin on 12/8/15.
//  Copyright © 2015 LMMSKZ. All rights reserved.
//

#import "RootViewController.h"
#import "FriendViewController.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SearchFriendsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) PFUser *user;
@property (weak, nonatomic) RootViewController *root;
@property (copy, nonatomic) NSArray<NSString *> *names;
@property (copy, nonatomic) NSArray<PFUser *> *foundFriends;
@property (weak, nonatomic) PFUser *selectedFriend;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end