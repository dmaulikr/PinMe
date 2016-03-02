//
//  LoginViewController.m
//  Pinguide
//
//  Created by Kevin on 12/11/15.
//  Copyright © 2015 LMMSKZ. All rights reserved.
//

#import "LoginViewController.h"
#import "RootViewController.h"

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //if the user is already logged in, segue into the app
    if ([PFUser currentUser]) {
        self.user = [PFUser currentUser];
        [self performSegueWithIdentifier: @"logInSuccess" sender: nil];
    }
}

//called when the user taps the log in button
- (IBAction)login:(id)sender {
    [PFUser logInWithUsernameInBackground: self.usernameField.text password:self.passwordField.text block: ^(PFUser *user, NSError *error){
        //if it worked, segue into the app
        if (user) {
            self.user = user;
            [self performSegueWithIdentifier: @"logInSuccess" sender: sender];
        }
        //otherwise, display an alert telling the user that something went wrong
        else {
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle: @"Log In Failed"
                                        message: @"Check your username and password and try again"
                                        preferredStyle: UIAlertControllerStyleAlert];
            
            UIAlertAction *okButton = [UIAlertAction
                                       actionWithTitle: @"Ok"
                                       style: UIAlertActionStyleDefault
                                       handler: ^(UIAlertAction *action) {
                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                       }];
            [alert addAction: okButton];
            [self presentViewController: alert animated: YES completion: nil];
        }
    }];
}

//called when the user taps the sign in button
- (IBAction)signUp:(id)sender {
    [self performSegueWithIdentifier: @"signUp" sender: sender];
}

//pass the logged in user to the next view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"logInSuccess"]) {
        RootViewController *controller = (RootViewController *)segue.destinationViewController;
        controller.user = self.user;
    }
}

@end
