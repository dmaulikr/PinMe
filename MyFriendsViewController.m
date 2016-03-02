//
//  MyFriendsViewController.m
//  Pinguide
//
//  Created by Kevin on 12/13/15.
//  Copyright © 2015 LMMSKZ. All rights reserved.
//

#import "MyFriendsViewController.h"

@implementation MyFriendsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidLoad];
    self.root = (RootViewController *)[self parentViewController];
    self.user = [self.root getUser];
    
    //fetch all of the current user's friends
    PFRelation *relation = [self.user relationForKey: @"friends"];
    [[relation query] findObjectsInBackgroundWithBlock: ^(NSArray *objects, NSError *error) {
        if (!error) {
            //update the local array
            self.friends = objects;
            [self.tableView reloadData];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.friends count];
}

//each cell is just each friend's name
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
    
    cell.textLabel.text = [NSString stringWithFormat: @"%@ %@", self.friends[indexPath.row][@"firstName"], self.friends[indexPath.row][@"lastName"]];
    cell.backgroundColor = [UIColor darkGrayColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

//when the current user taps on a friend name, segue to a view that displays that friend's maps
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedFriend = self.friends[indexPath.row];
    [self performSegueWithIdentifier: @"tappedFriend" sender: nil];
}

- (NSString *)convertToString: (id)object {
    return [NSString stringWithFormat: @"%@", object];
}

//pass the necessary data to the next view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"tappedFriend"]) {
        FriendViewController *controller = (FriendViewController *)[segue destinationViewController];
        controller.user = self.user;
        controller.selectedFriend = self.selectedFriend;
        controller.from = @"list";
    }
}


@end
