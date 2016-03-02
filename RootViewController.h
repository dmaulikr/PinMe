//
//  RootViewController.h
//  Pinguide
//
//  Created by Kevin on 12/12/15.
//  Copyright © 2015 LMMSKZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface RootViewController : UITabBarController

@property (strong, atomic) PFUser *user;

- (PFUser *)getUser;

@end
