//
//  PinMeViewController.m
//  Pinguide
//
//  Created by Kevin on 12/8/15.
//  Copyright © 2015 LMMSKZ. All rights reserved.
//

#import "PinMeViewController.h"

@interface PinMeViewController ()

@end

@implementation PinMeViewController {
    MKUserLocation *currentLocation; //user's current location
    NSMutableArray *annotations; //array of pins
    BOOL editing; //whether or not the user is in pin mode
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startMap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//return to list of maps
- (IBAction)goBack:(id)sender {
    [self performSegueWithIdentifier: @"selfMapReturn" sender: sender];
}

//initializes the map
- (void)startMap {
    //initialize the location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    
    //don't show the user location at first
    [self.mapView setShowsUserLocation: NO];
    
    //set the map label to the map's name
    self.mapLabel.text = self.map[@"name"];
    
    //turn the switch on if the map is public, off if not
    [self.publicSwitch setOn: [self.map[@"public"] boolValue]];
    
    //not in pinning mode at first
    editing = NO;
    
    //show that the button is disabled
    self.pinButton.backgroundColor = [UIColor darkGrayColor];
    
    //initialize the list of pins
    annotations = [[NSMutableArray alloc]init];
    
    //grab the list of pin data from the map, which is saved on parse
    NSArray *latitudes = self.map[@"latitudes"];
    NSArray *longitudes = self.map[@"longitudes"];
    NSArray *places = self.map[@"places"];
    NSArray *addresses = self.map[@"addresses" ];

    //go through the list of pin data, add the data to the list of annotations
    for (int i = 0; i < [latitudes count]; i++) {
        double lat = [latitudes[i] doubleValue];
        double lon = [longitudes[i] doubleValue];
        
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = CLLocationCoordinate2DMake(lat, lon);
        point.title = [NSString stringWithFormat: @"%@", places[i]];
        point.subtitle = [NSString stringWithFormat: @"%@", addresses[i]];
        [self.mapView addAnnotation:point];
        
        [annotations addObject: point];
    }
    
    //display the pins
    [self.mapView showAnnotations: annotations animated:YES];
    
    [self zoom: nil];
}

//called whenever the user's location is changed
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    //update current location for other functions to use
    currentLocation = userLocation;
    
    [self zoom: userLocation];
}

//change what the map shows based on user's location and all the pins
- (void)zoom: (MKUserLocation *)userLocation {
    MKMapRect zoomRect;
    MKMapPoint annotationPoint;
    MKMapRect pointRect;
    if (userLocation) { //if a userLocation was provided, include it in the map's view range
        annotationPoint = MKMapPointForCoordinate(userLocation.coordinate);
        zoomRect = MKMapRectMake(annotationPoint.x - 600, annotationPoint.y - 600, 1200, 1200);
    }
    else
        zoomRect = MKMapRectNull;
    
    //for every pin, add a rectangle
    for (id <MKAnnotation> annotation in annotations) {
        annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        
        //create a rectangle for the current pin
        pointRect = MKMapRectMake(annotationPoint.x - 600, annotationPoint.y - 600, 1200, 1200);
        
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

//called when the user taps the pin button
- (IBAction)pin:(id)sender {
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    
    //Google Places API to get the GMSPlaces near the current location
    GMSPlacesClient *client = [GMSPlacesClient sharedClient];
    [client currentPlaceWithCallback:^(GMSPlaceLikelihoodList * _Nullable likelihoodList, NSError * _Nullable error) {
        //set the new pin's title to the most likely place's name
        point.title = [likelihoodList.likelihoods[0] place].name;

        //set the new pin's coordinates to the most likely place's coordinates
        point.coordinate = [likelihoodList.likelihoods[0] place].coordinate;
        
        //Google Places API to get the address of the current place
        GMSGeocoder *coder = [GMSGeocoder geocoder];
        [coder reverseGeocodeCoordinate: [likelihoodList.likelihoods[0] place].coordinate completionHandler:
         ^(GMSReverseGeocodeResponse *results, NSError *error) {
             
             //set the new pin's subtitle as the address
             point.subtitle = [NSString stringWithFormat: @"%@ %@", results.firstResult.lines[0], results.firstResult.lines[1]];
             
             //add the pin to the map and array
             [self.mapView addAnnotation:point];
             [annotations addObject: point];
             
             //add this pin to the Map object on Parse
             [self.map addObject: [NSNumber numberWithDouble: point.coordinate.latitude] forKey: @"latitudes"];
             [self.map addObject: [NSNumber numberWithDouble: point.coordinate.longitude] forKey: @"longitudes"];
             [self.map addObject: point.title forKey: @"places"];
             [self.map addObject: point.subtitle forKey: @"addresses"];
             [self.map save];
             
             //show the new pin
             [self.mapView showAnnotations: annotations animated:YES];
         }];
    }];
}

//called when the user hits the Start Pinning button
- (IBAction)edit:(id)sender {
    //if the user isn't editing yet
    if (!editing) {
        //enable the pin button and change the color to show that it's enabled
        self.pinButton.enabled = YES;
        self.pinButton.backgroundColor = [UIColor colorWithRed:0.76 green:0.01 blue:0.00 alpha:1.0];
        
        //change the edit button's text to "Done"
        [self.editButton setTitle: @"Done" forState: UIControlStateNormal];
        
        editing = YES;
        
        //start updating location with the location manager
        [self.locationManager startUpdatingLocation];
        
        //show the user's location on the map
        [self.mapView setShowsUserLocation: YES];
    }
    //if the user is currently editing
    else {
        //disble the button and change the color to show that it's disabled
        self.pinButton.enabled = NO;
        self.pinButton.backgroundColor = [UIColor darkGrayColor];
        
        //change the edit button's text
        [self.editButton setTitle: @"Start Pinning" forState: UIControlStateNormal];
        
        editing = NO;
        
        //stop updating location with the user's location
        [self.locationManager stopUpdatingLocation];
        
        //stop showing the user's location
        [self.mapView setShowsUserLocation: NO];
    }
    
    //show all the pins
    [self zoom: nil];
}

//called when the user taps on the switch
- (IBAction)pub:(id)sender {
    //update the "public" field on the "Map" object on Parse
    self.map[@"public"] = [NSNumber numberWithBool: self.publicSwitch.isOn];
    [self.map save];
}

//pass the user along when we segue back to the list of maps
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"selfMapReturn"]) {
        RootViewController *controller = (RootViewController *)[segue destinationViewController];
        controller.user = self.user;
    }
}


@end
