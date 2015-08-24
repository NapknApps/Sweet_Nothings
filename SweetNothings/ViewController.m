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

@property (nonatomic, strong) UIView *currentThoughtCard;
@property (nonatomic, strong) UITextView *currentThoughtCardTextView;
@property (nonatomic, strong) NSMutableArray *thoughts;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashButton;
@property (nonatomic) BOOL animating;

@end

@implementation ViewController

@synthesize currentThoughtCard = _currentThoughtCard;
@synthesize currentThoughtCardTextView = _currentThoughtCardTextView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationController.toolbar.clipsToBounds = YES;

    self.thoughts = [NSMutableArray array];
    
    Firebase *ref = [FirebaseHelper thoughtsFirebaseReference];
    [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {

        if (snapshot.value == [NSNull null]) {
            // The value is null
        }
        else {
            for (NSDictionary *dict in [snapshot.value allValues]) {
                [self.thoughts addObject:[dict valueForKey:@"title"]];
            }
            
            [self setUpBarItemsDefault];
        }
        
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    
    [self hideAllInitialElements];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![DefaultsHelper introShown]) {
        [self performSegueWithIdentifier:@"Intro" sender:self];
    }
    else if (![FirebaseHelper userIsLoggedIn]) {
        [self performSegueWithIdentifier:@"Account" sender:self];
    }
    else {
        [self showAllInitialElements];
        
        if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil]];
        }

    }
}

- (void)hideAllInitialElements
{
    self.trashButton.tintColor = [UIColor colorWithRed:197/255.0 green:119/255.0 blue:250/255.0 alpha:1.0];
    [self setUpBarItemsNone];
}

- (void)showAllInitialElements
{
    self.trashButton.tintColor = [UIColor whiteColor];
    [self setUpBarItemsDefault];
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
    
    Firebase *ref = [FirebaseHelper thoughtsFirebaseReference];
    [ref observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        if (snapshot.value == [NSNull null]) {
            // The value is null
        }
        else {
            for (NSDictionary *dict in [snapshot.value allValues]) {
                [self.thoughts addObject:[dict valueForKey:@"title"]];
            }
            
            [self setUpBarItemsDefault];
        }
        
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];

}

- (void)showThoughtCardWithText:(NSString *)text interactive:(BOOL)interactive
{
    self.animating = YES;

    if (self.currentThoughtCard) {
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.currentThoughtCard.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.currentThoughtCard removeFromSuperview];
            self.currentThoughtCard = nil;
            [self animateShowThoughtCardWithText:text interactive:interactive];
        }];
    }
    else {
        [self animateShowThoughtCardWithText:text interactive:interactive];
    }
}

- (void)animateShowThoughtCardWithText:(NSString *)text interactive:(BOOL)interactive
{
    self.currentThoughtCard = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 290)];
    self.currentThoughtCard.backgroundColor = [UIColor whiteColor];
    self.currentThoughtCard.layer.cornerRadius = self.currentThoughtCard.frame.size.width / 2;
    
    CGPoint center;
    
    if (self.view.frame.size.height > 500) {
        center = CGPointMake(self.view.center.x, (290 / 2) + 100);
    }
    else {
        center = CGPointMake(self.view.center.x, (290 / 2) + 20);
    }
    
    if (interactive) {
        self.currentThoughtCard.center = center;
    }
    else {
        self.currentThoughtCard.center = self.view.center;
        center = self.view.center;
    }
    
    self.currentThoughtCardTextView = [[UITextView alloc] initWithFrame:CGRectMake(45, 45, self.currentThoughtCard.frame.size.width - 90, self.currentThoughtCard.frame.size.height - 90)];
    self.currentThoughtCardTextView.textAlignment = NSTextAlignmentCenter;
    [self.currentThoughtCardTextView setFont:[UIFont fontWithName:@"Avenir" size:30]];
    [self.currentThoughtCardTextView setText:text];
    self.currentThoughtCardTextView.editable = interactive;
    self.currentThoughtCardTextView.backgroundColor = [UIColor clearColor];
    
    [self.currentThoughtCard addSubview:self.currentThoughtCardTextView];
    [self.view addSubview:self.currentThoughtCard];
    
    self.currentThoughtCard.alpha = 0.0;
    self.currentThoughtCard.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.25, 0.25);
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.currentThoughtCard.center = CGPointMake(center.x - 10, center.y);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            self.currentThoughtCard.center = CGPointMake(center.x + 10, center.y);
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                
                self.currentThoughtCard.center = CGPointMake(center.x, center.y);
                
            } completion:^(BOOL finished) { }];
        }];
    }];
    
    [UIView animateWithDuration:1.7 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.currentThoughtCard.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:^(BOOL finished) { }];
    
    [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.currentThoughtCard.alpha = 1.0;
    } completion:^(BOOL finished) {
        
        self.animating = NO;
        
        if (interactive) {
            [self.currentThoughtCardTextView becomeFirstResponder];
            [self setUpBarItemsSave];
        }
    }];
}

- (IBAction)recallSelected:(id)sender
{
    if (!self.animating) {
        if (self.thoughts.count > 0) {
            NSUInteger randomIndex = arc4random() % [self.thoughts count];
            [self showThoughtCardWithText:[self.thoughts objectAtIndex:randomIndex] interactive:NO];
        }
    }
}

- (IBAction)addSelected:(id)sender
{
    if (!self.animating) {
        [self setUpBarItemsNone];
        [self showThoughtCardWithText:@"" interactive:YES];
    }
}

- (IBAction)trashSelected:(id)sender
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Delete All Data"
                                          message:@"Ready to restart? This will delete all your saved ideas."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *restartAction = [UIAlertAction
                                    actionWithTitle:@"Delete"
                                    style:UIAlertActionStyleDestructive
                                    handler:^(UIAlertAction *action)
                                    {
                                        Firebase *ref = [FirebaseHelper thoughtsFirebaseReference];
                                        [ref setValue:nil];
                                        [self.thoughts removeAllObjects];

                                        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                                            self.currentThoughtCard.alpha = 0.0;
                                        } completion:^(BOOL finished) {
                                            [self.currentThoughtCard removeFromSuperview];
                                            self.currentThoughtCard = nil;
                                            [self setUpBarItemsDefault];
                                        }];

                                    }];
    
    [alertController addAction:restartAction];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Not Now"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
    
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];

}

- (IBAction)saveSelected:(id)sender
{
    if (!self.animating) {
        
        if (self.currentThoughtCardTextView.text.length > 0) {
            
            [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.currentThoughtCard.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self.currentThoughtCard removeFromSuperview];
                self.currentThoughtCard = nil;
                
                NSDictionary *thought = @{
                                          @"title": self.currentThoughtCardTextView.text
                                          };
                Firebase *thoughtRef = [[FirebaseHelper thoughtsFirebaseReference] childByAutoId];
                [thoughtRef setValue:thought];
                
                [self.thoughts addObject:self.currentThoughtCardTextView.text];
                
                [self setUpBarItemsDefault];
                
                
                [self updateNotifications];
                
            }];
        }
    }
}

- (void)updateNotifications
{
    NSArray *scheduledLocalNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for (UILocalNotification *notification in scheduledLocalNotifications) {
        int secondsSinceOldNotification = [notification.fireDate timeIntervalSinceDate:[NSDate date]];
        if (secondsSinceOldNotification <= 0) {
            // Its already fired... leave it be, dont cancel it.
        }
        else {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }

    NSMutableArray *shuffledArray = [NSMutableArray arrayWithArray:self.thoughts];
    
    NSUInteger count = [shuffledArray count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        int nElements = count - i;
        int n = (arc4random() % nElements) + i;
        [shuffledArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }

    for (int i = 0; i < shuffledArray.count; i++) {
        
        NSString *thought = [shuffledArray objectAtIndex:i];
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [[NSDate date] dateByAddingTimeInterval:(60 * 60 * 24) * i];
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.alertBody = thought;
        [self scheduleNotificationIfInFuture:notification];
    }
    
}

- (void)scheduleNotificationIfInFuture:(UILocalNotification *)notification
{
    if ([[NSDate date] compare:notification.fireDate] == NSOrderedAscending) {
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        NSLog(@"%@", notification);
        NSLog(@"%@", notification.alertBody);
    }
}


- (void)cancelSelected:(id)sender
{
    if (!self.animating) {
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.currentThoughtCard.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.currentThoughtCard removeFromSuperview];
            self.currentThoughtCard = nil;
            [self setUpBarItemsDefault];
        }];
    }
}

- (void)setUpBarItemsDefault
{
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSelected:)];
    addButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = addButton;

    if (self.thoughts.count > 0) {
        UIBarButtonItem *recallButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(recallSelected:)];
        recallButton.tintColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem = recallButton;
    }
    else {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    self.trashButton.tintColor = [UIColor whiteColor];

}

- (void)setUpBarItemsNone
{
    self.trashButton.tintColor = [UIColor colorWithRed:197/255.0 green:119/255.0 blue:250/255.0 alpha:1.0];
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)setUpBarItemsSave
{
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveSelected:)];
    saveButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSelected:)];
    cancelButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.trashButton.tintColor = [UIColor colorWithRed:197/255.0 green:119/255.0 blue:250/255.0 alpha:1.0];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
