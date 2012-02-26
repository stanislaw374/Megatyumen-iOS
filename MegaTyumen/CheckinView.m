//
//  CheckinView.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 13.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CheckinView.h"
#import "Alerts.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

static int kBorderWidth = 4;

@interface CheckinView()
@property (nonatomic) int attitude;
@property (nonatomic, strong) MainMenu *mainMenu;
@property (strong, nonatomic) MBProgressHUD *hud;
- (void)initUI;
- (void)didCheckin:(NSNotification *)notification;
@end

@implementation CheckinView
@synthesize feedBackTextView;
@synthesize attitude = _attitude;
@synthesize currentItem = _currentItem;
@synthesize hud = _hud;
@synthesize btnPositive = _btnPositive;
@synthesize btnNeutral = _btnNeutral;
@synthesize btnNegative = _btnNegative;
@synthesize btnCheckin = _btnCheckin;
@synthesize btnAddFeedback = _btnAddFeedback;
@synthesize isFeedbackMode = _isFeedbackMode;
@synthesize mainMenu = _mainMenu;

- (void)setIsFeedbackMode:(BOOL)isFeedbackMode {
    _isFeedbackMode = isFeedbackMode;
    
    if (!self.isFeedbackMode) {
        self.btnAddFeedback.hidden = YES;
        self.btnCheckin.hidden = NO;
        self.title = @"Отметиться";
    }
    else {
        self.btnCheckin.hidden = YES;
        self.btnAddFeedback.hidden = NO;
        self.title = @"Добавить отзыв";
    }
}

- (void)didCheckin:(NSNotification *)notification {    
    [self.hud hide:YES];
    
    int result = [[notification.userInfo objectForKey:@"result"] intValue];
    
    if (result) {
        NSString *text = !self.isFeedbackMode ? @"Вы успешно отметились" : @"Ваш отзыв добавлен";
        [Alerts showAlertViewWithTitle:@"" message:text];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didCheckinSuccessfully" object:nil];

        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        NSString *error = [notification.userInfo objectForKey:@"error"];
        [Alerts showAlertViewWithTitle:@"Ошибка" message:error];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Отметиться";
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
    self.mainMenu = [[MainMenu alloc] initWithViewController:self];
    [self.mainMenu addBackButton];
    [self.mainMenu addMainButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCheckin:) name:@"didCheckin" object:nil];
    
    CALayer *layer = self.feedBackTextView.layer;
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:10];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initUI];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didCheckin" object:nil];
    [self setFeedBackTextView:nil];
    [self setBtnPositive:nil];
    [self setBtnNeutral:nil];
    [self setBtnNegative:nil];
    [self setBtnCheckin:nil];
    [self setBtnAddFeedback:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)onPositiveButtonClick {
    self.attitude = 1;
    
    self.btnNeutral.layer.borderColor = [[UIColor clearColor] CGColor];    
    self.btnNegative.layer.borderColor = [[UIColor clearColor] CGColor];
    
    CALayer * layer = [self.btnPositive layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:10];
    [layer setBorderWidth:kBorderWidth];
    [layer setBorderColor:[[UIColor whiteColor] CGColor]];
}

- (IBAction)onNeutralButtonClick {
    self.attitude = 0;
    
    self.btnPositive.layer.borderColor = [[UIColor clearColor] CGColor];    
    self.btnNegative.layer.borderColor = [[UIColor clearColor] CGColor];
    
    CALayer * layer = [self.btnNeutral layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:10];
    [layer setBorderWidth:kBorderWidth];
    [layer setBorderColor:[[UIColor whiteColor] CGColor]];
}

- (IBAction)onNegativeButtonClick {
    self.attitude = -1;
    
    self.btnNeutral.layer.borderColor = [[UIColor clearColor] CGColor];    
    self.btnPositive.layer.borderColor = [[UIColor clearColor] CGColor];
    
    CALayer * layer = [self.btnNegative layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:10];
    [layer setBorderWidth:kBorderWidth];
    [layer setBorderColor:[[UIColor whiteColor] CGColor]];
}

- (IBAction)onCheckinButtonClick {
    NSString *feedbackText = self.feedBackTextView.text;
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *dict = [self.currentItem checkinWithFeedBack:feedbackText andAttitude:self.attitude];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.hud hide:YES];
            BOOL result = [[dict objectForKey:KEY_RESPONSE] boolValue];
            if (result) {
                NSString *text = !self.isFeedbackMode ? @"Вы успешно отметились" : @"Ваш отзыв добавлен";
                [Alerts showAlertViewWithTitle:@"" message:text]; 
                [self.navigationController popViewControllerAnimated:YES];
            }
            else {
                NSString *error = [dict objectForKey:KEY_ERROR];
                [Alerts showAlertViewWithTitle:@"Ошибка" message:error];
            }
        });
    });
}

- (IBAction)onAddFeedbackButtonClick {
    [self onCheckinButtonClick];
}

- (IBAction)onBgClick:(id)sender {
    [self.feedBackTextView becomeFirstResponder];
    [self.feedBackTextView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)onMainButtonClick {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)onBackButtonClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initUI {
    self.feedBackTextView.text = @"";
    [self onNeutralButtonClick];
}

@end
