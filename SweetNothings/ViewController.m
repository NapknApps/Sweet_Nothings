//
//  ViewController.m
//  SweetNothings
//
//  Created by Zach Whelchel on 8/18/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import "ViewController.h"
#import "FirebaseHelper.h"
#import "DefaultsHelper.h"
#import "AccountViewController.h"

@interface ViewController () <AccountViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self hideAllInitialElements];
    
    if (![DefaultsHelper introShown]) {
        [self performSegueWithIdentifier:@"Intro" sender:self];
    }
    else if (![FirebaseHelper userIsLoggedIn]) {
        [self performSegueWithIdentifier:@"Account" sender:self];
    }
    else {
        [self showAllInitialElements];
    }
}

- (void)hideAllInitialElements
{
    
}

- (void)showAllInitialElements
{
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Account"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        AccountViewController *accountViewController = (AccountViewController *)navigationController.viewControllers.firstObject;
        accountViewController.delegate = self;
    }
}

- (void)accountViewControllerDidLogin:(AccountViewController *)accountViewController
{
    NSLog(@"Did log in");
}

- (IBAction)recallSelected:(id)sender
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.cornerRadius = view.frame.size.width / 2;
    view.center = self.view.center;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 40, view.frame.size.width - 80, view.frame.size.height - 80)];
    label.numberOfLines = 4;
    label.textAlignment = NSTextAlignmentCenter;
    [label setFont:[UIFont fontWithName:@"Avenir" size:32]];
    [label setText:@"Those sushi roles from the corner store."];
    
    [view addSubview:label];
    [self.view addSubview:view];
    
    view.alpha = 0.0;
    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.25, 0.25);

    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        view.center = CGPointMake(self.view.center.x - 10, self.view.center.y);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            view.center = CGPointMake(self.view.center.x + 10, self.view.center.y);
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                
                view.center = CGPointMake(self.view.center.x, self.view.center.y);
                
            } completion:^(BOOL finished) { }];
        }];
    }];
    
    [UIView animateWithDuration:1.7 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:^(BOOL finished) { }];
    
    [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.alpha = 1.0;
    } completion:^(BOOL finished) { }];
}

- (IBAction)addSelected:(id)sender
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
