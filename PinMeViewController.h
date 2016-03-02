//
//  PinMeViewController.h
//  Pinguide
//
//  Created by Kevin on 12/8/15.
//  Copyright © 2015 LMMSKZ. All rights reserved.
//

#import "PinMeViewController.h"
#import "RootViewController.h"
#include <stdlib.h>
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
@import MapKit;
@import GoogleMaps;

@interface PinMeViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *publicSwitch;
@property (weak, nonatomic) PFUser *user;
@property (weak, nonatomic) PFObject *map;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *mapLabel;
@property (weak, nonatomic) IBOutlet UIButton *pinButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;


@end

