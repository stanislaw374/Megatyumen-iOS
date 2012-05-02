//
//  RemindPasswordView.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 18.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RemindPasswordView.h"
#import "Alerts.h"
#import "Authorization.h"
#import "KeyboardListener.h"
#import "MainMenu.h"
#import "Config.h"
#import "User.h"

@interface RemindPasswordView() <UserDelegate>
@property (nonatomic, strong) MainMenu *mainMenu;
@property (strong, nonatomic) KeyboardListener *keyboardListener;
@property (strong, nonatomic) MBProgressHUD *hud;
//- (void)dismissKeyboard:(id)sender;
- (void)restorePassword;
//- (void)didRestorePassword:(NSNotification *)notification;
@end

@implementation RemindPasswordView
@synthesize scrollView;
@synthesize textField = _textField;
@synthesize tableView;
@synthesize keyboardListener = _keyboardListener;
@synthesize hud = _hud;
@synthesize mainMenu = _mainMenu;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Забыли пароль?";
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    self.keyboardListener.scrollView = self.scrollView;
    self.keyboardListener.activeControl = self.tableView;
}

//-(void)textFieldDidEndEditing:(UITextField *)textField {
//    self.keyboardListener.scrollView = nil;
//    self.keyboardListener.activeControl = nil;
//}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self restorePassword];
    return YES;
}

//-(void)dismissKeyboard:(id)sender {
//    [sender resignFirstResponder];
//}

- (void)restorePassword {
    // Получение e-mail
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSString *email = ((UITextField *)[[self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:1]).text;
    
    [User sharedUser].email = email;
    [User sharedUser].delegate = self;
    [[User sharedUser] restorePassword];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSDictionary *dict = [[Authorization sharedAuthorization] restorePasswordWithEmail:email];
//        BOOL response = [[dict objectForKey:KEY_RESPONSE] boolValue];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.hud hide:YES];
//            if (response) {
//                [Alerts showAlertViewWithTitle:@"" message:@"Новый пароль был выслан на ваш e-mail"];
//                [self.navigationController popViewControllerAnimated:YES];
//            }
//            else {
//                [Alerts showAlertViewWithTitle:@"Ошибка" message:[dict objectForKey:KEY_ERROR]];
//            }
//        });
//    });
}

//- (void)didRestorePassword:(NSNotification *)notification {
//    Authorization *authorization = notification.object;
//    //int result = [[notification.userInfo objectForKey:@"result"] intValue];
////    if (authorization.result) {        
////        [Alerts showAlertViewWithTitle:@"" message:@"Новый пароль был выслан на ваш e-mail"];
////        [self.navigationController popViewControllerAnimated:YES];
////    }
////    else {
////        //NSString *error = [notification.userInfo objectForKey:@"error"];
////        [Alerts showAlertViewWithTitle:@"Ошибка" message:authorization.error];
////    }
//    
//    [self.hud hide:YES];
//}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.backgroundColor = [UIColor clearColor];
    self.keyboardListener = [[KeyboardListener alloc] init];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRestorePassword:) name:kNOTIFICATION_DID_RESTORE_PASSWORD object:nil];
    
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addBackButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.scrollView.contentSize = self.view.bounds.size;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.keyboardListener.activeControl = nil;
    self.keyboardListener.scrollView = nil;
}

- (void)viewDidUnload
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_RESTORE_PASSWORD object:nil];
    [self setTableView:nil];
    [self setScrollView:nil];
    [self setTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onRestorePasswordButtonClick {
    [self restorePassword];
}

- (IBAction)onBgClick:(id)sender {
    [self.textField becomeFirstResponder];
    [self.textField resignFirstResponder];
}

#pragma mark UITableViewDataSource

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"RestorePasswordCell";
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        CGSize cellSize = cell.bounds.size;
        if ([indexPath section] == 0) {
            UITextField *playerTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, 240, cellSize.height - 20)];
            playerTextField.adjustsFontSizeToFitWidth = YES;
            //playerTextField.textColor = [UIColor colorWithRed:216.0/255 green:187.0/255 blue:142.0/255 alpha:1];
            playerTextField.keyboardType = UIKeyboardTypeDefault;
            playerTextField.returnKeyType = UIReturnKeyDone;
            playerTextField.placeholder = @"Ваш e-mail";
            playerTextField.backgroundColor = [UIColor whiteColor];
            playerTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
            playerTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
            playerTextField.textAlignment = UITextAlignmentLeft;
            playerTextField.tag = 1;
            //[playerTextField addTarget:self action:@selector(dismissKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
            playerTextField.delegate = self;
            
            playerTextField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
            [playerTextField setEnabled: YES];
            
            [cell addSubview:playerTextField];
        }
    }
    return cell;    
}

#pragma mark - UserDelegate
- (void)userRestorePasswordDidFailWithError:(NSString *)error {
    [User sharedUser].delegate = nil;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)userDidRestorePasswordWithMessage:(NSString *)message {
    [User sharedUser].delegate = nil;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
