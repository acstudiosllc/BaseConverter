//
//  BCAppDelegate.m
//  BaseConverter
//
//  Created by Christopher Loonam on 12/3/15.
//  Copyright (c) 2015 Christopher Loonam. All rights reserved.
//

#import "BCAppDelegate.h"
#import "BCConverterViewController.h"
#import "BCSettingsViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@implementation BCAppDelegate {
    SKProduct *removeAdsProduct;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"purchased"])
        [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"purchased"];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"baseDisplay"])
        [[NSUserDefaults standardUserDefaults] setObject:@"Both" forKey:@"baseDisplay"];
    
    UIColor *primaryColor = [UIColor colorWithRed:53.0/255.0 green:102.0/255.0 blue:153.0/255.0 alpha:1.0];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    BCConverterViewController *converterViewController = [[BCConverterViewController alloc] init];
    UINavigationController *converterNavigationController = [[UINavigationController alloc] initWithRootViewController:converterViewController];
    converterNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Converter" image:[UIImage systemImageNamed:@"number.square"] selectedImage:[UIImage systemImageNamed:@"number.square.fill"]];
    
    BCSettingsViewController *settingsViewController = [[BCSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    settingsNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage systemImageNamed:@"gearshape"] selectedImage:[UIImage systemImageNamed:@"gearshape.fill"]];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[converterNavigationController, settingsNavigationController];
    self.window.rootViewController = tabBarController;
    
    [self.window makeKeyAndVisible];
    
    NSArray *productIDs = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"InAppPurchases" ofType:@"plist"]];
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIDs]];
    productsRequest.delegate = self;
    [productsRequest start];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    UITabBarAppearance *tabBarAppearance = [[UITabBarAppearance alloc] init];
    [tabBarAppearance configureWithOpaqueBackground];
    tabBarAppearance.backgroundColor = [UIColor systemBackgroundColor];
    tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:10.0 weight:UIFontWeightHeavy]};
    tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:10.0 weight:UIFontWeightHeavy]};
    tabBarController.tabBar.standardAppearance = tabBarAppearance;
    tabBarController.tabBar.scrollEdgeAppearance = tabBarAppearance;
    tabBarController.tabBar.layer.shadowOffset = CGSizeMake(0, 0);
    tabBarController.tabBar.layer.shadowRadius = 2;
    tabBarController.tabBar.layer.shadowColor = [UIColor systemGray2Color].CGColor;
    tabBarController.tabBar.layer.shadowOpacity = 0.4;
    
    UINavigationBarAppearance *navigationBarAppearance = [[UINavigationBarAppearance alloc] init];
    [navigationBarAppearance configureWithDefaultBackground];
    navigationBarAppearance.backgroundColor = primaryColor;
    navigationBarAppearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};

    converterNavigationController.navigationBar.standardAppearance = navigationBarAppearance;
    converterNavigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance;
    settingsNavigationController.navigationBar.standardAppearance = navigationBarAppearance;
    settingsNavigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance;

//    self.window.tintColor = primaryColor;
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [[UITextField appearance] setTintColor:primaryColor];
    tabBarController.tabBar.tintColor = primaryColor;
    [[UISegmentedControl appearance] setTintColor:primaryColor];

    return YES;
}

- (BOOL)allFeaturesUnlocked {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"purchased"] boolValue];
}

- (void)restorePurchase
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)removeAds
{
    if (!removeAdsProduct)
        return;
    SKPayment *payment = [SKPayment paymentWithProduct:removeAdsProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if (response.products.count > 0)
        removeAdsProduct = response.products[0];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"purchased"];
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your purchase has been restored successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alertView show];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
//    for (SKPaymentTransaction *transaction in transactions)
//    {
//        if (transaction.transactionState == SKPaymentTransactionStatePurchased || transaction.transactionState == SKPaymentTransactionStateRestored || transaction.transactionState)
//        {
//            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"purchased"];
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your transaction has been processed successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alertView show];
//        }
//        else
//            NSLog(@"NOT BOUGHT");
//        if (transaction.transactionState != SKPaymentTransactionStatePurchasing)
//            [queue finishTransaction:transaction];
//    }
}

@end
