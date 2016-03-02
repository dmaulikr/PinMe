//
//  FriendViewController.h
//  Pinguide
//
//  Created by Kevin on 12/14/15.
//  Copyright © 2015 LMMSKZ. All rights reserved.
//

#import "FriendMapViewController.h"
#import "RootViewController.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FriendViewController : UIViewController <UITableViewDataSource, UITabBarDelegate>

@property (weak, nonatomic) PFUser *user;
@property (weak, nonatomic) PFUser *selectedFriend;
@property (copy, nonatomic) NSArray<PFObject *> *friendMaps;
@property (weak, nonatomic) PFObject *selectedMap;
@property (weak, nonatomic) NSString *from;
@property (weak, nonatomic) IBOutlet UILabel *friendLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
