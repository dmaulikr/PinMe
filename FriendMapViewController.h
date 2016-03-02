//
//  FriendMapViewController.h
//  Pinguide
//
//  Created by Kevin on 12/14/15.
//  Copyright © 2015 LMMSKZ. All rights reserved.
//

#import "FriendViewController.h"
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
@import MapKit;

@interface FriendMapViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) PFUser *user;
@property (weak, nonatomic) PFUser *selectedFriend;
@property (weak, nonatomic) PFObject *map;
@property (weak, nonatomic) IBOutlet UILabel *mapLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end