//
//  FriendViewController.m
//  Pinguide
//
//  Created by Kevin on 12/14/15.
//  Copyright © 2015 LMMSKZ. All rights reserved.
//

#import "FriendViewController.h"

@implementation FriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set the name to the friend's name
    self.friendLabel.text = [[[self convertToString: self.selectedFriend[@"firstName"]]
                               stringByAppendingString: @" "]
                               stringByAppendingString: [self convertToString: self.selectedFriend[@"lastName"]]];
    
    //grab all the maps that the friend has
    PFRelation *relation = [self.selectedFriend relationForKey: @"maps"];
    PFQuery *query = [relation query];
    //only give the maps that the friend set as public
    [query whereKey: @"public" equalTo: [NSNumber numberWithBool: YES]];
    
    //fetch the data from Parse
    [query findObjectsInBackgroundWithBlock: ^(NSArray *maps, NSError *error) {
        if (!error){
            //update the local array
            self.friendMaps = maps;
            [self.tableView reloadData];
        }
        else
            NSLog(@"map load failed");
    }];
}

//each cell is just the friend's maps' names
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             
                             simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier: simpleTableIdentifier];
    }
    
    cell.textLabel.text = self.friendMaps[indexPath.row][@"name"];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor darkGrayColor];
    
    return cell;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friendMaps count];
}

//when the current user taps on a map, segue to the map view controller
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedMap = self.friendMaps[indexPath.row];
    [self performSegueWithIdentifier: @"friendMapPressed" sender: nil];
}

- (NSString *)convertToString: (id)object {
    return [NSString stringWithFormat: @"%@", object];
}

//called when the user taps on the return button
- (IBAction)goBack:(id)sender {
    [self performSegueWithIdentifier: @"friendReturn" sender: sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //if seguing to the map controller, pass the necessary data

    if ([segue.identifier isEqualToString: @"friendMapPressed"]) {
        FriendMapViewController *controller = (FriendMapViewController *)[segue destinationViewController];
        controller.user = self.user;
        controller.selectedFriend = self.selectedFriend;
        controller.map = self.selectedMap;
    }
    //oftherwise, segue back to the tab bar controller and set the selected tab accordingly
    else if ([self.from isEqualToString: @"search"]) {
        RootViewController *controller = (RootViewController *)[segue destinationViewController];
        controller.user = self.user;
        [controller setSelectedIndex: 1];
    }
    else {
        RootViewController *controller = (RootViewController *)[segue destinationViewController];
        controller.user = self.user;
        [controller setSelectedIndex: 2];
    }
}

@end
