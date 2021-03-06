//
//  AddCommentView.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 29.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AddCommentView.h"
#import "Authorization.h"
#import "Alerts.h"
#import "New.h"

@interface AddCommentView() <NewDelegate>
@property (nonatomic, strong) MainMenu *mainMenu;
@property (nonatomic, strong) KeyboardListener *keyboardListener;
@end

@implementation AddCommentView
@synthesize tableView;
@synthesize currentNew = _currentNew;
@synthesize scrollView;
@synthesize textField = _textField;
@synthesize keyboardListener = _keyboardListener;
@synthesize mainMenu = _mainMenu;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Комментарий";
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
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addBackButton];
    [self.mainMenu addMainButton];
    [self.mainMenu addAuthorizeButton];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.keyboardListener = [[KeyboardListener alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.scrollView.contentSize = self.view.bounds.size;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.keyboardListener.scrollView = nil;
    self.keyboardListener.activeControl = nil;
}

- (void)viewDidUnload
{
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_PASS_AUTHORIZATION object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kNOTIFICATION_DID_ADD_COMMENT object:nil];
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

- (IBAction)onAddCommentButtonClick {    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSString *name = ((UITextField *)[[self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:1]).text;
    indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    NSString *text = ((UITextView *)[[self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:2]).text;

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Добавление комментария к новости
    self.currentNew.delegate = self;
    [self.currentNew addCommentWithName:name andText:text];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.keyboardListener.scrollView = self.scrollView;
    self.keyboardListener.activeControl = textField;
    return YES;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.returnKeyType == UIReturnKeyNext) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:textField.tag inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [[cell viewWithTag:textField.tag + 1] becomeFirstResponder];
    }
    else [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    textView.text = @"";
    textView.textColor = [UIColor blackColor];
    self.keyboardListener.scrollView = self.scrollView;
    self.keyboardListener.activeControl = textView;
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView {
    if (!textView.text.length) {
        textView.text = @"Текст комментария";
        textView.textColor = [UIColor lightGrayColor];
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self onAddCommentButtonClick];
        return NO;
    }
    return YES;
}

#pragma mark - UITableViewDataSource

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([Authorization sharedAuthorization].isAuthorized) ? 1 : 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"CommentCell";
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        CGSize cellSize = cell.bounds.size;
        if ([indexPath section] == 0) {
            UITextField *nameTextField;
            UITextView *commentTextView;
            if ([tableView_ numberOfRowsInSection:0] == 2) {
                switch (indexPath.row) {
                    case 0:
                        nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, 260, cellSize.height - 20)];
                        nameTextField.adjustsFontSizeToFitWidth = YES;
                        nameTextField.placeholder = @"Имя";
                        nameTextField.returnKeyType = UIReturnKeyNext;
                        nameTextField.backgroundColor = [UIColor whiteColor];
                        nameTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
                        nameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
                        nameTextField.textAlignment = UITextAlignmentLeft;
                        nameTextField.tag = indexPath.row +1;
                        nameTextField.delegate = self;
                        nameTextField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
                        [nameTextField setEnabled: YES];
                        [cell addSubview:nameTextField];
                        break;
                    case 1:
                        commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(15, 10, 260, 274 - 20)];
                        //NSLog(@"Размер текствью = %lf", cellSize.height);
                        commentTextView.textColor = [UIColor lightGrayColor];
                        commentTextView.font = [UIFont systemFontOfSize:14];
                        commentTextView.text = @"Текст комментария";
                        commentTextView.returnKeyType = UIReturnKeyDone;
                        commentTextView.delegate = self;
                        commentTextView.tag = indexPath.row +1;
                        commentTextView.font = [UIFont systemFontOfSize:16];
                        [cell addSubview:commentTextView];
                        break;
                }        
            }
            else {
                commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(15, 10, 240, 274)];
                commentTextView.textColor = [UIColor lightGrayColor];
                commentTextView.font = [UIFont systemFontOfSize:14];
                commentTextView.text = @"Текст комментария";
                commentTextView.returnKeyType = UIReturnKeyDone;
                commentTextView.delegate = self;
                commentTextView.tag = indexPath.row +1;
                commentTextView.font = [UIFont systemFontOfSize:16];
                [cell addSubview:commentTextView];
            }
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView_ heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && ![Authorization sharedAuthorization].isAuthorized) return 44;
    else return 274;
}

- (IBAction)onBgClick:(id)sender {
    [self.textField becomeFirstResponder];
    [self.textField resignFirstResponder];
}

#pragma mark - NewDelegate
- (void)newDidAddCommentWithMessage:(NSString *)message {
    self.currentNew.delegate = nil;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)newDidFailWithError:(NSString *)error {
    self.currentNew.delegate = nil;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:error message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
