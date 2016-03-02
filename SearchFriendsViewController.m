//
// SearchFriendsViewController.m
//  Pinguide
//
//  Created by Kevin on 12/8/15.
//  Copyright © 2015 LMMSKZ. All rights reserved.
//

#import "SearchFriendsViewController.h"
#import <Parse/Parse.h>

@implementation SearchFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //update the root and user fields
    self.root = (RootViewController *)[self parentViewController];
    self.user = [self.root getUser];
}

//the number of rows is just the number of names found
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.names count];
}

//called when the UITableView is populating the table
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             
                             simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier: simpleTableIdentifier];
    }
    
    //default text color is white
    cell.textLabel.textColor = [UIColor whiteColor];
    
    //retrieve the name for this row
    cell.textLabel.text = self.names[indexPath.row];
    
    //use the relation to query for all the friends of the current user
    PFRelation *relation = [self.user relationForKey: @"friends"];
    [[relation query] findObjectsInBackgroundWithBlock: ^(NSArray *objects, NSError *error) {
        if (!error) {
            //if the current user is friends with the found user, have the name in red
            if ([objects containsObject: self.foundFriends[indexPath.row]]) {
                cell.textLabel.textColor = [UIColor colorWithRed:0.76 green:0.01 blue:0.00 alpha:1.0];;
            }
        }
    }];
    
    cell.backgroundColor = [UIColor darkGrayColor];
    
    return cell;
}


//when the user clicks on a name
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //query for all the friends of the current user
    PFRelation *relation = [self.user relationForKey: @"friends"];
    [[relation query] findObjectsInBackgroundWithBlock: ^(NSArray *objects, NSError *error) {
        if (!error) {
            //if the current user is friends with the person they tapped on, show the friend's list of maps
            if ([objects containsObject: self.foundFriends[indexPath.row]]) {
                self.selectedFriend = self.foundFriends[indexPath.row];
                [self performSegueWithIdentifier: @"tappedFriendFromSearch" sender: nil];
            }
            //if the current user isn't friends with the person they tapped on, ask if they want to add friends with an alert notification
            else {
                UIAlertController *alert = [UIAlertController
                                            alertControllerWithTitle: @"Add Friend?"
                                            message: NULL
                                            preferredStyle: UIAlertControllerStyleAlert];
                
                //when the user clicks on confirm, add the tapped user to the current user's friend list
                UIAlertAction *confirmButton = [UIAlertAction
                                                actionWithTitle: @"Confirm"
                                                style: UIAlertActionStyleDefault
                                                handler: ^(UIAlertAction *action) {
                                                    PFRelation *relation = [self.user relationForKey: @"friends"];
                                                    [relation addObject: self.foundFriends[indexPath.row]];
                                                    [self.user saveInBackgroundWithBlock: ^(BOOL succeeded, NSError *error) {
                                                        [self.tableView reloadData];
                                                        [alert dismissViewControllerAnimated:YES completion: nil];
                                                    }];
                                                }];
                //just dismiss the alert if they hit cancel
                UIAlertAction *cancelButton = [UIAlertAction
                                               actionWithTitle: @"Cancel"
                                               style: UIAlertActionStyleDefault
                                               handler: ^(UIAlertAction *action) {
                                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                               }];
                [alert addAction: cancelButton];
                [alert addAction: confirmButton];
                [alert.view setNeedsLayout];
                [self presentViewController: alert animated: YES completion: nil];
            }
        }
    }];

}

//called whenever the user types something into the search bar
- (IBAction)searchFriends:(id)sender {
    //if the user enters nothing, clear the array
    if ([self.nameField.text isEqualToString: @""]) {
        self.names = [NSArray array];
        self.foundFriends = [NSArray array];
        [self.tableView reloadData];
    }
    else {
        //display "Loading..." while searching for friends
        self.names = [NSArray arrayWithObjects: @"Loading...", nil];
        [self.tableView reloadData];
        
        //array of all the names the user enters
        NSArray *input = [self.nameField.text componentsSeparatedByString: @" "];
        
        PFQuery *query = [PFUser query];
        
        //iterate through user's input, adding a subquery for each token
        for (int i = 0; i < [input count]; i++) {
            NSArray<PFQuery *> *subs = [NSArray array];
            
            //if the user's first name, last name, or username begins with any of the tokens the current user typed in
            subs = [subs arrayByAddingObject: [PFQuery queryWithClassName:@"_User" predicate: [NSPredicate predicateWithFormat: @"firstName BEGINSWITH[cd] %@", input[i]]]];
            subs = [subs arrayByAddingObject: [PFQuery queryWithClassName:@"_User" predicate: [NSPredicate predicateWithFormat: @"lastName BEGINSWITH[cd] %@", input[i]]]];
            subs = [subs arrayByAddingObject: [PFQuery queryWithClassName:@"_User" predicate: [NSPredicate predicateWithFormat: @"username BEGINSWITH[cd] %@", input[i]]]];
            
            query = [PFQuery orQueryWithSubqueries: subs];
        }
        
        //fetch the users from Parse, the users are stored in an array
        [query findObjectsInBackgroundWithBlock: ^(NSArray *objects, NSError *error) {
            if (!error) {
                //if there are no matchds, display it
                if ([objects count] == 0) {
                    self.names = [NSArray arrayWithObjects: @"No Matches", nil];
                }
                //otherwise, go through all the found friends and add them to the two local arrays
                else {
                    NSArray *foundNames = [NSMutableArray array];
                    NSArray *foundFriends = [NSMutableArray array];
                    for (int i = 0; i < [objects count]; i++) {
                        //don't add the current user to the list
                        if (![[self.user username] isEqualToString: [objects[i] username]]) {
                            NSString *name = [NSString stringWithFormat: @"%@ %@ (%@)",
                                              [self convertToString: objects[i][@"firstName"]],
                                              [self convertToString: objects[i][@"lastName"]],
                                              [self convertToString: objects[i][@"username"]]];
                            foundNames = [foundNames arrayByAddingObject: name];
                            foundFriends = [foundFriends arrayByAddingObject: objects[i]];
                        }
                    }
                    self.names = foundNames;
                    self.foundFriends = foundFriends;
                }
                [self.tableView reloadData];
            }
        }];
    }
}

- (NSString *)convertToString: (id)object {
    return [NSString stringWithFormat: @"%@", object];
}

//pass the user and selected friend to the next view
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"tappedFriendFromSearch"]) {
        FriendViewController *controller = (FriendViewController *)[segue destinationViewController];
        controller.user = self.user;
        controller.selectedFriend = self.selectedFriend;
        controller.from = @"search";
    }
}

@end
