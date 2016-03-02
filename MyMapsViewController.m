//
//  MyMapsViewController.m
//  Pinguide
//
//  Created by Kevin on 12/13/15.
//  Copyright © 2015 LMMSKZ. All rights reserved.
//

#import "MyMapsViewController.h"

@implementation MyMapsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.root = (RootViewController *)[self parentViewController];
    self.user = [self.root getUser];
}

//update the list of maps each time the view appears
- (void)viewWillAppear:(BOOL)animated {
    //fetch the list of the current user's maps from Parse
    PFRelation *relation = [self.user relationForKey: @"maps"];
    [[relation query] findObjectsInBackgroundWithBlock: ^(NSArray *maps, NSError *error) {
        if (!error){
            self.myMaps = maps;
            [self.tableView reloadData];
        }
        else
            NSLog(@"map load failed");
    }];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.myMaps count];
}

//each cell is just each map's name
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             
                             SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:SimpleTableIdentifier];
    }
    
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.text = self.myMaps[indexPath.row][@"name"];
    if (self.myMaps[indexPath.row][@"public"] == [NSNumber numberWithBool: YES]) {
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    cell.backgroundColor = [UIColor darkGrayColor];

    return cell;
}

//if the user tapped on a map, segue to the map view controller
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedMap = self.myMaps[indexPath.row];
    [self performSegueWithIdentifier: @"selfMapPressed" sender: nil];
}

//called when the user taps on the new map button
- (IBAction)newMap:(id)sender {
    //creates a new alert with a text field, ok button, and cancel button
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle: @"New Map"
                                message: NULL
                                preferredStyle: UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler: ^(UITextField *textField) {
       textField.placeholder = @"Map Name";
    }];
    
    //when the user taps on the ok button, it adds a new map with the name they entered and saves it on Parse
    UIAlertAction *okButton = [UIAlertAction
                               actionWithTitle: @"Ok"
                               style: UIAlertActionStyleDefault
                               handler: ^(UIAlertAction *action) {
                                   PFObject *map = [PFObject objectWithClassName: @"Map"];
                                   map[@"name"] = alert.textFields.firstObject.text;
                                   map[@"public"] = [NSNumber numberWithBool: NO];
                                   [map save];
                                   
                                   PFRelation *relation = [self.user relationForKey: @"maps"];
                                   [relation addObject: map];
                                   [self.user saveInBackgroundWithBlock: ^(BOOL succeeded, NSError *error) {
                                       if (succeeded) {                                           
                                           self.myMaps = [self.myMaps arrayByAddingObject: map];
                                           
                                           [self.tableView reloadData];
                                           [alert dismissViewControllerAnimated:YES completion: nil];
                                       }
                                       else [alert dismissViewControllerAnimated:YES completion:nil];
                                   }];
                               }];
    //just dismisses the alert when the user taps on the cancel button
    UIAlertAction *cancelButton = [UIAlertAction
                               actionWithTitle: @"Cancel"
                               style: UIAlertActionStyleDefault
                               handler: ^(UIAlertAction *action) {
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                               }];
    [alert addAction: cancelButton];
    [alert addAction: okButton];
    [alert.view setNeedsLayout];
    //display the alert and update the table
    [self presentViewController: alert animated: YES completion: nil];
    [self.tableView reloadData];
}

//called when the user taps on the log out button
- (IBAction)logOut:(id)sender {
    //logs the user out and goes to the log in view controller
    [PFUser logOut];
    [self performSegueWithIdentifier: @"loggedOut" sender: sender];
    
}

//pass the necessary data when seguing to the map view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"selfMapPressed"]) {
        PinMeViewController *controller = (PinMeViewController *)[segue destinationViewController];
        controller.user = self.user;
        controller.map = self.selectedMap;
    }
}

@end
