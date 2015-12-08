//
//  BCConverterViewController.m
//  BaseConverter
//
//  Created by Christopher Loonam on 12/3/15.
//  Copyright (c) 2015 Christopher Loonam. All rights reserved.
//

#import <iAd/iAd.h>
#import "BCConverterViewController.h"
#import "BCBaseConverter.h"
#import "BCAppDelegate.h"

@implementation BCConverterViewController {
    BCBaseConverter *baseConverter;
}

- (BCAppDelegate *)appDelegate {
    return (BCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (instancetype)init {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        [self.tableView registerNib:[UINib nibWithNibName:@"BCBaseCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
        
        if (!(self.tableViewItems = [[NSUserDefaults standardUserDefaults] objectForKey:@"baseArray"]))
            self.tableViewItems = @[@(10), @(16), @(8), @(2)];
        self.currentValue = @"0";
        self.currentBase = 10;
        
        [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:@"baseDisplayChanged" object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.navigationItem) {
        self.navigationItem.title = @"Converter";
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
    }
    
    if (![self appDelegate].allFeaturesUnlocked) {
        self.canDisplayBannerAds = YES;
        self.interstitialPresentationPolicy = ADInterstitialPresentationPolicyAutomatic;
    } else {
        self.canDisplayBannerAds = NO;
        self.interstitialPresentationPolicy = ADInterstitialPresentationPolicyNone;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![self appDelegate].allFeaturesUnlocked) {
        self.canDisplayBannerAds = YES;
        self.interstitialPresentationPolicy = ADInterstitialPresentationPolicyAutomatic;
    } else {
        self.canDisplayBannerAds = NO;
        self.interstitialPresentationPolicy = ADInterstitialPresentationPolicyNone;
    }
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
    self.currentBase = cell.base;
    self.currentValue = text;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"Cell";
    BCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if (!baseConverter)
        baseConverter = [[BCBaseConverter alloc] init];
    
    cell.base = [self.tableViewItems[indexPath.row] integerValue];
    
    NSString *baseDisplay = [[NSUserDefaults standardUserDefaults] objectForKey:@"baseDisplay"];
    if ([baseDisplay isEqualToString:@"Both"])
        cell.baseLabel.text = [NSString stringWithFormat:@"Base %d (%@)", (int)cell.base, [baseConverter nameForBase:cell.base]];
    else if ([baseDisplay isEqualToString:@"Number"])
        cell.baseLabel.text = [NSString stringWithFormat:@"Base %d", (int)cell.base];
    else
        cell.baseLabel.text = [NSString stringWithFormat:@"%@", [baseConverter nameForBase:cell.base]];
    
    cell.textField.text = [baseConverter convertNumber:self.currentValue fromBase:self.currentBase toBase:cell.base];
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    NSInteger base = [alertView textFieldAtIndex:0].text.integerValue;
    
    if ([buttonTitle isEqualToString:@"Add"]) {
        if (base > 62 || base < 1) {
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Base must be between 1 and 62" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorAlertView show];
            return;
        }
        self.tableViewItems = [self.tableViewItems arrayByAddingObject:@(base)];
        [[NSUserDefaults standardUserDefaults] setObject:self.tableViewItems forKey:@"baseArray"];
        [self.tableView reloadData];
    }
}

- (void)addBase {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add Base" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    if (editing) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBase)];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

@end
