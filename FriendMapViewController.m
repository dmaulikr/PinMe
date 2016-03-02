//
//  FriendMapViewController.m
//  Pinguide
//
//  Created by Kevin on 12/14/15.
//  Copyright © 2015 LMMSKZ. All rights reserved.
//

#import "FriendMapViewController.h"

@implementation FriendMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self startMap];
}

//called when the user taps on the return button
- (IBAction)goBack:(id)sender {
    [self performSegueWithIdentifier: @"friendMapReturn" sender: sender];
}

//change what the map shows based on all the pins
- (void)zoom {
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        
        //create a rectangle for the current pin
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        
        //if it's the first pin, set it as the rectangle
        if (MKMapRectIsNull(zoomRect))
            zoomRect = pointRect;
        //otherwise union all the rectangles together
        else
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    //set the map's view range to the entire rectangle
    [self.mapView setVisibleMapRect: zoomRect animated:YES];
}

//initialize the map view
- (void)startMap {
    
    //grab the data related to the current map from the "Map" object on Parse
    self.mapLabel.text = self.map[@"name"];
    NSArray *latitudes = self.map[@"latitudes"];
    NSArray *longitudes = self.map[@"longitudes"];
    NSArray *places = self.map[@"places"];
    NSArray *addresses = self.map[@"addresses" ];
    
    //add a pin for each data value in the arrays to the map
    for (int i = 0; i < [latitudes count]; i++) {
        //convert to a double
        double lat = [latitudes[i] doubleValue];
        double lon = [longitudes[i] doubleValue];
        
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        //set the pin's values accordingly
        point.coordinate = CLLocationCoordinate2DMake(lat, lon);
        point.title = [NSString stringWithFormat: @"%@", places[i]];
        point.subtitle = [NSString stringWithFormat: @"%@", addresses[i]];
        
        //add the pin to the map
        [self.mapView addAnnotation:point];
    }
    
    //show the map and change the view accordingly
    [self.mapView showAnnotations: self.mapView.annotations animated: YES];
    [self zoom];
}

//pass the current user and selected friend back to the friend view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"friendMapReturn"]) {
        FriendViewController *controller = (FriendViewController *)[segue destinationViewController];
        controller.user = self.user;
        controller.selectedFriend = self.selectedFriend;
    }
}


@end

