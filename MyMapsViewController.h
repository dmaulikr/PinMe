//
//  MyMapsViewController.h
//  Pinguide
//
//  Created by Kevin on 12/13/15.
//  Copyright © 2015 LMMSKZ. All rights reserved.
//

#import "RootViewController.h"
#import "PinMeViewController.h"
#import "LoginViewController.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface MyMapsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) PFUser *user;
@property (weak, nonatomic) RootViewController *root;
@property (copy, nonatomic) NSArray *myMaps;
@property (weak, nonatomic) PFObject *selectedMap;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabBarMaps;

@end
