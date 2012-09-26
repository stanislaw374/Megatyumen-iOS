//
//  AuthorizationView.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 18.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AuthorizationView.h"
#import "RegistrationView.h"
#import "RemindPasswordView.h"
#import "MainView.h"
#import "Config.h"
#import "Alerts.h"
#import "Authorization.h"
#import "MainMenu.h"
#import "User.h"

@interface AuthorizationView() <UserDelegate>
@property (nonatomic, strong) MainMenu *mainMenu;
@property (strong, nonatomic) KeyboardListener *keyboardListener;
@property (strong, nonatomic) RegistrationView *registrationView;
@property (strong, nonatomic) RemindPasswordView *remindPasswordView;
@property (strong, nonatomic) MBProgressHUD *hud;
- (void)authorize;
//- (void)didAuthorize:(NSNotification *)notification;
@end

@implementation AuthorizationView
@synthesize rememberMeSwitcher = _rememberMeSwitcher;
@synthesize scrollView = _scrollView;
@synthesize textField = _textField;
@synthesize tableView = _tableView;
@synthesize forgotPasswordButton = _forgotPasswordButton;
@synthesize registerButton = _registerButton;
@synthesize keyboardListener = _keyboardListener;
@synthesize registrationView = _registrationView;
@synthesize remindPasswordView = _remindPasswordView;
@synthesize hud = _hud;
@synthesize mainMenu = _mainMenu;

#pragma mark - Lazy Initialization

//- (RegistrationView *)registrationView {
//    if (!_registrationView) {
//        _registrationView = [[RegistrationView alloc] init];
//    }
//    return _registrationView;
//}
//
//- (RemindPasswordView *)remindPasswordView {
//    if (!_remindPasswordView) {
//        _remindPasswordView = [[RemindPasswordView alloc] init];
//    }
//    return _remindPasswordView;
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Авторизация";
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
    //self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Назад" style:UIBarButtonItemStylePlain target:self action:nil];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.keyboardListener = [[KeyboardListener alloc] init];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAuthorize:) name:kNOTIFICATION_DID_AUTHORIZE object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAuthorize:) name:kNOTIFICATION_DID_PASS_REGISTRATION object:nil];
    
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addBackButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.scrollView.contentSize = self.view.bounds.size;
    //NSLog(@"content size = %@", NSStringFromCGSize(self.scrollView.contentSize));
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.keyboardListener.scrollView = nil;
    self.keyboardListener.activeControl = nil;
}

- (void)viewDidUnload
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_AUTHORIZE object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_PASS_REGISTRATION object:nil];
    [self setTableView:nil];
    [self setForgotPasswordButton:nil];
    [self setRegisterButton:nil];
    [self setScrollView:nil];
    [self setTextField:nil];
    [self setRememberMeSwitcher:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onEnterButtonClick {
    [self authorize];
}

- (void)authorize {
    // Получение логина и пароля 
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSString *email = ((UITextField *)[[self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:1]).text;
    indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    NSString *password = ((UITextField *)[[self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:1]).text;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [User sharedUser].delegate = self;
    [User sharedUser].email = email;
    [User sharedUser].password = password;
    if (self.rememberMeSwitcher.on) 
        [User sharedUser].isSave = YES;
    else
        [User sharedUser].isSave = NO;
    [[User sharedUser] login];
    
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSDictionary *dict = [[Authorization sharedAuthorization] authorizeWithLogin:login andPassword:password];
//        BOOL result = [[dict objectForKey:KEY_RESPONSE] boolValue];
//        if (result) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.hud hide:YES];
//                [[NSUserDefaults standardUserDefaults] setObject:login forKey:KEY_LOGIN];
//                [[NSUserDefaults standardUserDefaults] setObject:password forKey:KEY_PASSWORD];
//                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_IS_AUTHORIZED];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//                [Alerts showAlertViewWithTitle:@"" message:@"Вы успешно авторизовались. Теперь вы можете добавлять комментарии, отмечаться, добавлять отзывы."];
//                [self.navigationController popViewControllerAnimated:YES];
//            });
//        }
//        else {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.hud hide:YES];
//                [Alerts showAlertViewWithTitle:@"Ошибка" message:[dict objectForKey:KEY_ERROR]];
//            });
//        }
//    });
}

//-(void)didAuthorize:(NSNotification *)notification {
//    Authorization *authorization = notification.object;
//    //int result = [[notification.userInfo objectForKey:@"result"] intValue];
//    //if (result) 
//    if (authorization.isAuthorized) {
//        [Alerts showAlertViewWithTitle:@"" message:@"Вы успешно авторизовались. Теперь вы можете добавлять комментарии, отмечаться, добавлять отзывы."];
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isAuthorized"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//    else {
//        [Alerts showAlertViewWithTitle:@"Ошибка" message:authorization.error];
//    }
//    
//    [self.hud hide:YES];
//}

- (IBAction)onForgotPasswordButtonClick {
    RemindPasswordView *view = [[RemindPasswordView alloc] init];
    [self.navigationController pushViewController:view animated:YES];
}

- (IBAction)onRegisterButtonClick {
    //self.registrationView.authorizationView = self;
    RegistrationView *view = [[RegistrationView alloc] init];
    [self.navigationController pushViewController:view animated:YES];
}

- (IBAction)dismissKeyboard:(id)sender {
    [sender resignFirstResponder];
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    self.keyboardListener.scrollView = self.scrollView;
    self.keyboardListener.activeControl = self.tableView;
    //NSLog(@"%@", NSStringFromSelector(_cmd));
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    self.keyboardListener.scrollView = nil;
    self.keyboardListener.activeControl = nil;
    //NSLog(@"%@", NSStringFromSelector(_cmd));
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.returnKeyType == UIReturnKeyNext) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [[cell viewWithTag:1] becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
        [self authorize];
    }
    return YES;
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"AuthorizationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        CGSize cellSize = cell.bounds.size;
        if ([indexPath section] == 0) {
            UITextField *playerTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, 240, cellSize.height - 20)];
            playerTextField.adjustsFontSizeToFitWidth = YES;
            if ([indexPath row] == 0) {
                playerTextField.placeholder = @"Логин (e-mail)";
                playerTextField.keyboardType = UIKeyboardTypeDefault;
                playerTextField.returnKeyType = UIReturnKeyNext;
//                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isAuthorized"]) {
//                    NSString *login = [[NSUserDefaults standardUserDefaults] objectForKey:@"login"];
//                    playerTextField.text = login;
//                }
                playerTextField.text = [User sharedUser].email;
            }
            else {
                playerTextField.placeholder = @"Пароль";
                playerTextField.keyboardType = UIKeyboardTypeDefault;
                playerTextField.returnKeyType = UIReturnKeyDone;
                playerTextField.secureTextEntry = YES;
//                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isAuthorized"]) {
//                    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
//                    playerTextField.text = password;
//                }
                playerTextField.text = [User sharedUser].password;
            }       
            playerTextField.backgroundColor = [UIColor whiteColor];
            playerTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
            playerTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
            playerTextField.textAlignment = UITextAlignmentLeft;
            playerTextField.tag = 1;
            playerTextField.delegate = self;
            playerTextField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
            [playerTextField setEnabled: YES];
            
            [cell addSubview:playerTextField];
        }
    }
    return cell;
}

- (IBAction)onBgClick:(id)sender {
    [self.textField becomeFirstResponder];
    [self.textField resignFirstResponder];
}

#pragma mark - UserDelegate
- (void)userLoginDidFailWithError:(NSString *)error {
    [User sharedUser].delegate = nil;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)userDidLoginWithMesssage:(NSString *)message {
    [User sharedUser].delegate = nil;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    [self.navigationController popViewControllerAnimated:YES];
    [self.mainMenu addLogoutButton];

    
}

@end
