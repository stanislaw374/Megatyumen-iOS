/*
 * Copyright 2010 Andrey Yastrebov
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "VkontakteViewController.h"

@interface VkontakteViewController (Private)
- (NSString*)stringBetweenString:(NSString*)start 
                       andString:(NSString*)end 
                     innerString:(NSString*)str;
@end

@implementation VkontakteViewController (Private)

- (NSString*)stringBetweenString:(NSString*)start 
                       andString:(NSString*)end 
                     innerString:(NSString*)str 
{
    NSScanner* scanner = [NSScanner scannerWithString:str];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:nil];
    if ([scanner scanString:start intoString:nil]) 
    {
        NSString* result = nil;
        if ([scanner scanUpToString:end intoString:&result]) 
        {
            return result;
        }
    }
    return nil;
}

@end

@implementation VkontakteViewController

@synthesize delegate = _delegate;
@synthesize webView = _webView;

- (id)initWithAuthLink:(NSURL *)link
{
    self = [super initWithNibName:@"VkontakteViewController" bundle:[NSBundle mainBundle]];
    if (self) 
    {
        _authLink = [link retain];
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
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Отмена" 
                                                                              style:UIBarButtonItemStyleBordered 
                                                                             target:self 
                                                                             action:@selector(cancelButtonPressed:)] autorelease];
    
    _webView.delegate = self;
    [_webView loadRequest:[NSURLRequest requestWithURL:_authLink]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webView.delegate = nil;
    self.webView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)cancelButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(authorizationDidCanceled)])
    {
        [self.delegate authorizationDidCanceled];
    }
}

#pragma mark - WebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView 
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; 
    _hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:_hud];
	_hud.dimBackground = YES;
    _hud.delegate = self;
    [_hud show:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView 
{
    // Если есть токен сохраняем его
    if ([webView.request.URL.absoluteString rangeOfString:@"access_token"].location != NSNotFound) 
    {
        NSString *accessToken = [self stringBetweenString:@"access_token=" 
                                                andString:@"&" 
                                              innerString:[[[webView request] URL] absoluteString]];
        
        // Получаем id пользователя, пригодится нам позднее
        NSArray *userAr = [[[[webView request] URL] absoluteString] componentsSeparatedByString:@"&user_id="];
        NSString *user_id = [userAr lastObject];
        NSLog(@"User id: %@", user_id);
        
        NSString *expTime = [self stringBetweenString:@"expires_in=" 
                                            andString:@"&" 
                                          innerString:[[[webView request] URL] absoluteString]];
        NSDate *expirationDate = [NSDate distantFuture];
        if (expTime != nil) 
        {
            int expVal = [expTime intValue];
            if (expVal != 0) 
            {
                expirationDate = [NSDate dateWithTimeIntervalSinceNow:expVal];
            }
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(authorizationDidSucceedWithToke:userId:expDate:userEmail:)]) 
        {
            [_delegate authorizationDidSucceedWithToke:accessToken 
                                                userId:user_id 
                                               expDate:expirationDate
                                             userEmail:[_userEmail autorelease]];
        }
    } 
    else if ([webView.request.URL.absoluteString rangeOfString:@"error"].location != NSNotFound) 
    {
        NSLog(@"Error: %@", webView.request.URL.absoluteString);
        if (_delegate && [_delegate respondsToSelector:@selector(authorizationDidFailedWithError:)]) 
        {
            [_delegate authorizationDidFailedWithError:nil];
        }
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];  
    [_hud hide:YES];
    [_hud removeFromSuperview];
    [_hud release];
	_hud = nil;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error 
{
    
    NSLog(@"vkWebView Error: %@", [error localizedDescription]);
    if (_delegate && [_delegate respondsToSelector:@selector(authorizationDidFailedWithError:)]) 
    {
        [_delegate authorizationDidFailedWithError:error];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];  
    [_hud hide:YES];
    [_hud removeFromSuperview];
    [_hud release];
	_hud = nil;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType 
{    
    NSString *s = @"var filed = document.getElementsByClassName('filed'); "
    "var textField = filed[0];"
    "textField.value;";            
    NSString *email = [webView stringByEvaluatingJavaScriptFromString:s];
    if (([email length] != 0) && _userEmail == nil) 
    {
        _userEmail = [email retain];
    }
    
    NSURL *URL = [request URL];
    // Пользователь нажал Отмена в веб-форме
    if ([[URL absoluteString] isEqualToString:@"http://api.vk.com/blank.html#error=access_denied&error_reason=user_denied&error_description=User%20denied%20your%20request"]) 
    {
        if (_delegate && [_delegate respondsToSelector:@selector(authorizationDidCanceled)]) 
        {
            [_delegate authorizationDidCanceled];
        }
        return NO;
    }
	NSLog(@"Request: %@", [URL absoluteString]); 
	return YES;
}

@end
