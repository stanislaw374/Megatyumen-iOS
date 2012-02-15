//
//  DemoScreenView.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 18.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DemoScreenView.h"
#import "MainView.h"

@interface DemoScreenView()
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) UIViewController *mainView;
- (IBAction)onOKButtonClick;
@end;

@implementation DemoScreenView
@synthesize navController = _navController;
@synthesize mainView = _mainView;

#pragma mark - Lazy instantiation

- (UINavigationController *)navController {
    if (!_navController) {
        _navController = [[UINavigationController alloc] initWithRootViewController:self.mainView];
        _navController.navigationBar.tintColor = [UIColor colorWithRed:216.0/255 green:6.0/255 blue:27.0/255 alpha:1];
    }
    return _navController;
}

- (UIViewController *)mainView {
    if (!_mainView) {
        _mainView = [[MainView alloc] init];
    }
    return _mainView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Демо-экран";
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setNavController:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onOKButtonClick {
    [self presentModalViewController:self.navController animated:YES];
}

@end
