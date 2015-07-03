//
//  ViewController.m
//  MyMusic
//
//  Created by sjjwind on 5/14/15.
//  Copyright (c) 2015 sjjwind. All rights reserved.
//

#import "LoginViewController.h"
#import "MusicManager.h"
#import "MainWindowController.h"
#import "LoginMananger.h"

@interface LoginViewController()

@property (nonatomic, weak) IBOutlet NSTextField *userNameField;
@property (nonatomic, weak) IBOutlet NSSecureTextField *passwordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)login:(id)sender {
    [[LoginMananger sharedManager] loginWithUsername:@"hello1" password:@"hello1" complete:^(BOOL success) {
        
    }];
}

@end
