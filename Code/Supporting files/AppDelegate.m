//
//  AppDelegate.m
//  MegaTyumen
//
//  Created by Yazhenskikh Stanislaw on 17.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "DemoScreenView.h"
#import "MainView.h"
#import "SCAppUtils.h"
#import "Config.h"

@interface AppDelegate()
@property (strong, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) UINavigationController *navController;
- (void)reachabilityChanged:(NSNotification *)notification;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize navController = _navController;
@synthesize facebook = _facebook;
//@synthesize reachability = _reachability;

// Проверка на первый запуск приложения
- (BOOL)isFirstTimeLaunch {
    NSString *wasLaunched = KEY_WAS_LAUNCHED;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:wasLaunched]) { 
        //[userDefaults setBool:YES forKey:wasLaunched];
        //[userDefaults synchronize];
        return YES;
    }
    else return NO;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.  
    
    if ([self isFirstTimeLaunch]) {
        DemoScreenView *demoScreenView = [[DemoScreenView alloc] init];
        self.viewController = demoScreenView;
    }
    else 
    {
        self.viewController = [[MainView alloc] init];
    }
        
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    
    [SCAppUtils customizeNavigationController:self.navController];
    
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if ([self isFirstTimeLaunch]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:KEY_WAS_LAUNCHED];
        [userDefaults synchronize];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

// Pre 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self.facebook handleOpenURL:url]; 
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id) annotation {
    return [self.facebook handleOpenURL:url]; 
}

@end
