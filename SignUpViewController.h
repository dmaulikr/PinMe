//
//  SignUpViewController.h
//  Pinguide
//
//  Created by Kevin on 12/11/15.
//  Copyright © 2015 LMMSKZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UITextField *firstField;
@property (weak, nonatomic) IBOutlet UITextField *lastField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmField;

@end
