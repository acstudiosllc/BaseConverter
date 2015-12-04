//
//  BCAppDelegate.h
//  BaseConverter
//
//  Created by Christopher Loonam on 12/3/15.
//  Copyright (c) 2015 Christopher Loonam. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import <UIKit/UIKit.h>

@interface BCAppDelegate : NSObject <UIApplicationDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (strong, nonatomic) UIWindow *window;

- (BOOL)allFeaturesUnlocked;
- (void)restorePurchase;
- (void)removeAds;

@end

