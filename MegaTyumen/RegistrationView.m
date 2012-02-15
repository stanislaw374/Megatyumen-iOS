//
//  RegistrationView.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 18.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RegistrationView.h"
#import "UserAgreementView.h"
#import "Alerts.h"
#import "Authorization.h"
#import "MainMenu.h"

@interface RegistrationView()
@property (nonatomic, strong) MainMenu *mainMenu;
@property (strong, nonatomic) KeyboardListener *keyboardListener;
@property (strong, nonatomic) UserAgreementView *userAgreementView;
@property (strong, nonatomic) MBProgressHUD *hud;
- (void)register_;
- (void)didRegister:(NSNotification *)notification;
//- (void)didPassRegistration
@end

@implementation RegistrationView
@synthesize tableView;
@synthesize keyboardListener = _keyboardListener;
@synthesize scrollView = _scrollView;
@synthesize userAgreementView = _userAgreementView;
@synthesize hud = _hud;
@synthesize mainMenu = _mainMenu;
//@synthesize authorizationView = _authorizationView;

#pragma mark - Lazy Initialization

- (UserAgreementView *)userAgreementView {
    if (!_userAgreementView) {
        _userAgreementView = [[UserAgreementView alloc] init];
    }
    return _userAgreementView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Регистрация";
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
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Назад" style:UIBarButtonItemStylePlain target:self action:nil];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.keyboardListener = [[KeyboardListener alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRegister:) name:kNOTIFICATION_DID_REGISTER object:nil];
    
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addBackButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.scrollView.contentSize = self.view.bounds.size;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.keyboardListener.scrollView = nil;
    self.keyboardListener.activeControl = nil;
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_REGISTER object:nil];
    [self setTableView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)register_ {
    // Получение логина, пароля, псевдонима
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSString *login = ((UITextField *)[[self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:1]).text;
    indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    NSString *password = ((UITextField *)[[self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:2]).text;
    indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    NSString *passwordAgain = ((UITextField *)[[self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:3]).text;
    indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    NSString *name = ((UITextField *)[[self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:4]).text;
    
    if (![password isEqualToString:passwordAgain]) {
        [Alerts showAlertViewWithTitle:@"Ошибка" message:@"Подтверждение пароля введено неверно"];
        return;
    }
    
    if ([login rangeOfString:@"@"].location == NSNotFound || [login rangeOfString:@"."].location == NSNotFound) {
        [Alerts showAlertViewWithTitle:@"Ошибка" message:@"E-mail введен неверно"];
        return;
    }
    
    [[Authorization sharedAuthorization] registerWithLogin:login Password:password andName:name];
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)didRegister:(NSNotification *)notification {
    Authorization *authorization = notification.object;
    if (authorization.result) {
        [Alerts showAlertViewWithTitle:@"" message:@"Вы успешно зарегистрировались"];
        //[self.navigationController popViewControllerAnimated:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isAuthorized"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        //NSString *error = [notification.userInfo objectForKey:@"error"];
        [Alerts showAlertViewWithTitle:@"Ошибка" message:authorization.error];
    }
    
    [self.hud hide:YES];
}

- (IBAction)dismissKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)onRegisterButtonClick {
    [self register_];
}

- (IBAction)onReadUserAgreementButtonClick {
    [self.navigationController pushViewController:self.userAgreementView animated:YES];
}

#pragma mark UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    self.keyboardListener.scrollView = self.scrollView;
    self.keyboardListener.activeControl = self.tableView;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    self.keyboardListener.scrollView = nil;
    self.keyboardListener.activeControl = nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.returnKeyType == UIReturnKeyNext) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:textField.tag inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [[cell viewWithTag:textField.tag + 1] becomeFirstResponder];
    }
    else { 
        [textField resignFirstResponder];
        [self register_];
    }
    return YES;
}

#pragma mark - UITableViewDataSource

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

-(UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"RegistrationCell";
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        CGSize cellSize = cell.bounds.size;
        if ([indexPath section] == 0) {
            UITextField *playerTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, 240, cellSize.height - 20)];
            playerTextField.adjustsFontSizeToFitWidth = YES;
            
            playerTextField.keyboardType = UIKeyboardTypeDefault;
            playerTextField.returnKeyType = UIReturnKeyDone;
            
            switch (indexPath.row) {
                case 0:
                    playerTextField.placeholder = @"Логин (e-mail)";
                    playerTextField.returnKeyType = UIReturnKeyNext;
                    break;
                case 1:
                    playerTextField.placeholder = @"Пароль";
                    playerTextField.secureTextEntry = YES;
                    playerTextField.returnKeyType = UIReturnKeyNext;
                    break;
                case 2:
                    playerTextField.placeholder = @"Пароль ещё раз";
                    playerTextField.secureTextEntry = YES;
                    playerTextField.returnKeyType = UIReturnKeyNext;
                    break;
                case 3:
                    playerTextField.placeholder = @"Имя";
                    break;
            }
            
            playerTextField.backgroundColor = [UIColor whiteColor];
            playerTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
            playerTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
            playerTextField.textAlignment = UITextAlignmentLeft;
            playerTextField.tag = indexPath.row +1;
          
            playerTextField.delegate = self;
            
            playerTextField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
            [playerTextField setEnabled: YES];
            
            [cell addSubview:playerTextField];
        }
    }
    return cell;

}

@end
