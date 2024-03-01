//
//  BCConverterViewController.m
//  BaseConverter
//
//  Created by Christopher Loonam on 12/3/15.
//  Copyright (c) 2015 Christopher Loonam. All rights reserved.
//

#import <GoogleMobileAds/GoogleMobileAds.h>
#import "BCConverterViewController.h"
#import "BCBaseConverter.h"
#import "BCAppDelegate.h"

@interface BCConverterViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) BCBaseConverter *baseConverter;
@property (strong, nonatomic) NSArray *tableViewItems;
@property (strong, nonatomic) GADBannerView *bannerView;
@property (strong, nonatomic) NSLayoutConstraint *tableBottomConstraint;

@end

@implementation BCConverterViewController

- (BCAppDelegate *)appDelegate {
    return (BCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (instancetype)init {
    if (self = [super init]) {
        self.baseConverter = [[BCBaseConverter alloc] init];
        if (!(self.tableViewItems = [[NSUserDefaults standardUserDefaults] objectForKey:@"baseArray"]))
            self.tableViewItems = @[@(10), @(16), @(8), @(2)];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.view addSubview:self.tableView];
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor].active = YES;
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor].active = YES;
        self.tableBottomConstraint = [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor];
        self.tableBottomConstraint.active = YES;

        self.bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeBanner];
#ifdef DEBUG
        self.bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
#else
        self.bannerView.adUnitID = @"ca-app-pub-5932737181681054/3532241197";
#endif
        self.bannerView.rootViewController = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:@"baseDisplayChanged" object:nil];
        
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
        self.bannerView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.navigationItem) {
        self.navigationItem.title = @"Converter";
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBase)];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
        
    if ([[self appDelegate] allFeaturesUnlocked]) {
        [self.bannerView removeFromSuperview];
        self.tableBottomConstraint.active = YES;
    } else {
        BOOL showInterstitial = (arc4random() % 10) < 2;
        
        [self.view addSubview:self.bannerView];
        
        self.tableBottomConstraint.active = NO;
        self.bannerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.bannerView.topAnchor constraintEqualToAnchor:self.tableView.bottomAnchor].active = YES;
        [self.bannerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
        [self.bannerView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
        
        if (showInterstitial) {
            GADRequest *request = [GADRequest request];
            NSString *adUnitId =
#ifdef DEBUG
            @"ca-app-pub-3940256099942544/4411468910";
#else
            @"ca-app-pub-5932737181681054/9195631416";
#endif
            [GADInterstitialAd loadWithAdUnitID:adUnitId
                                        request:request
                              completionHandler:^(GADInterstitialAd *ad, NSError *error) {
              if (error) {
                NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
                return;
              }
              [ad presentFromRootViewController:self];
            }];
        }
    }
    
    [self.bannerView loadRequest:[GADRequest request]];
}

- (BOOL)shouldPresentInterstitialAd {
    if (![self appDelegate].allFeaturesUnlocked)
        return YES;
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cell:(BCBaseCell *)cell textDidChange:(NSString *)text {
    [self.baseConverter setValue:text inBase:cell.base];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"BCBaseCell";
    BCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[BCBaseCell alloc] init];
        cell.converter = self.baseConverter;
        [self.baseConverter addObserver:cell forKeyPath:@"value" options:kNilOptions context:nil];
    }
    
    cell.base = [self.tableViewItems[indexPath.row] integerValue];
    
    NSString *baseDisplay = [[NSUserDefaults standardUserDefaults] objectForKey:@"baseDisplay"];
    if ([baseDisplay isEqualToString:@"Both"]) {
        cell.baseLabel.text = [NSString stringWithFormat:@"Base %d (%@)", (int)cell.base, [self.baseConverter nameForBase:cell.base]];
    } else if ([baseDisplay isEqualToString:@"Number"]) {
        cell.baseLabel.text = [NSString stringWithFormat:@"Base %d", (int)cell.base];
    } else {
        cell.baseLabel.text = [NSString stringWithFormat:@"%@", [self.baseConverter nameForBase:cell.base]];
    }
    
    if (cell.base <= 10) {
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
    } else {
        cell.textField.keyboardType = UIKeyboardTypeDefault;
    }
    
    cell.textField.text = [self.baseConverter getValueForBase:cell.base];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *arrayCopy = self.tableViewItems.mutableCopy;
        [arrayCopy removeObjectAtIndex:indexPath.row];
        
        self.tableViewItems = [NSArray arrayWithArray:arrayCopy];
        [[NSUserDefaults standardUserDefaults] setObject:self.tableViewItems forKey:@"baseArray"];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray *array = self.tableViewItems.mutableCopy;

    id o = array[sourceIndexPath.row];
    [array removeObject:o];
    [array insertObject:o atIndex:destinationIndexPath.row];
    self.tableViewItems = [NSArray arrayWithArray:array];
    [[NSUserDefaults standardUserDefaults] setObject:self.tableViewItems forKey:@"baseArray"];
}

#pragma mark - Editing

- (void)addBase {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add New Base" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSInteger base = [alertController textFields][0].text.integerValue;
        [alertController dismissViewControllerAnimated:YES completion:nil];
        if (base > 62 || base < 1) {
            UIAlertController *invalidAlertController = [UIAlertController alertControllerWithTitle:@"Invalid Base" message:[NSString stringWithFormat:@"%ld is not a valid base (1-62)", base] preferredStyle:UIAlertControllerStyleActionSheet];
            [invalidAlertController addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [invalidAlertController dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:invalidAlertController animated:YES completion:nil];
        }
        self.tableViewItems = [self.tableViewItems arrayByAddingObject:@(base)];
        [[NSUserDefaults standardUserDefaults] setObject:self.tableViewItems forKey:@"baseArray"];
        [self.tableView reloadData];
    }]];
    [alertController addTextFieldWithConfigurationHandler:nil];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
