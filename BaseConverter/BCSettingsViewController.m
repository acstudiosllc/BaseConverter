//
//  BCSettingsViewController.m
//  BaseConverter
//
//  Created by Christopher Loonam on 12/3/15.
//  Copyright (c) 2015 Christopher Loonam. All rights reserved.
//

#import "BCSettingsViewController.h"
#import "BCAppDelegate.h"

NSString *const ACSettingsViewControllerKey = @"vc";
NSString *const ACSettingsSwitchKey = @"switch";
NSString *const ACSettingsTextFieldKey = @"text";
NSString *const ACSettingsSegmentedControlKey = @"segment";
NSString *const ACSettingsWebViewKey = @"web";
NSString *const ACSettingsButtonKey = @"button";

@implementation BCSettingsViewController {
    NSArray *settings;
}

- (BCAppDelegate *)appDelegate {
    return (BCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)populateSettings {
    NSDictionary *basicSettings =
    @{@"name" : @"Converter", @"items" : @[
              @{@"name" : @"Base name", @"type" : ACSettingsSegmentedControlKey, @"values" : @[@"Both", @"Number", @"Name"], @"selectedValue" : [[NSUserDefaults standardUserDefaults] objectForKey:@"baseDisplay"], @"selector" : @"displayNameChanged:"}
              ]};
    
    NSDictionary *supportSettings =
    @{
        @"name" : @"Support",
        @"items" : @[
            @{
                @"name" : @"Remove ads",
                @"type" : ACSettingsButtonKey,
                @"action": ^{
                    [[self appDelegate] removeAds];
                },
                @"requiresPurchase" : @(NO)
            },
            @{
                @"name" : @"Restore purchase",
                @"type" : ACSettingsButtonKey,
                @"action": ^{
                    [[self appDelegate] restorePurchase];
                },
                @"requiresPurchase" : @(NO)
            }
        ]
    };

    settings = @[
        basicSettings,
        supportSettings
#ifdef DEBUG
        , @{
            @"name": @"Debug",
            @"items": @[
                @{
                    @"name": @"Toggle premium",
                    @"type": ACSettingsButtonKey,
                    @"action": ^{
                        BOOL purchased = [[self appDelegate] allFeaturesUnlocked];
                        [[NSUserDefaults standardUserDefaults] setValue:@(!purchased) forKey:@"purchased"];
                    },
                    @"requiresPurchase": @(NO)
                }
            ]
        }
#endif
    ];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Settings";
    [self populateSettings];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self populateSettings];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return settings.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [settings[section][@"items"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return settings[section][@"name"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    
    NSDictionary *cellDictionary = settings[indexPath.section][@"items"][indexPath.row];
    NSString *cellType = cellDictionary[@"type"];
    
    cell.textLabel.text = cellDictionary[@"name"];
    
    if ([cellType isEqualToString:ACSettingsSwitchKey]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *boolSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = boolSwitch;
        boolSwitch.on = [cellDictionary[@"state"] boolValue];
        [boolSwitch addTarget:self action:NSSelectorFromString(cellDictionary[@"selector"]) forControlEvents:UIControlEventValueChanged];
    }
    else if ([cellType isEqualToString:ACSettingsTextFieldKey]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.detailTextLabel.hidden = YES;
        [[cell viewWithTag:3] removeFromSuperview];
        UITextField *textField = [[UITextField alloc] init];
        
        textField.text = cellDictionary[@"value"];
        textField.keyboardType = [cellDictionary[@"keyboard"] integerValue];
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        textField.tag = 3;
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:textField];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.textLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:8]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:8]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-8]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-16]];
        textField.textAlignment = NSTextAlignmentRight;
        
        [textField addTarget:self action:NSSelectorFromString(cellDictionary[@"selector"]) forControlEvents:UIControlEventEditingDidEnd];
        [textField addTarget:textField action:@selector(resignFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
    }
    else if ([cellType isEqualToString:ACSettingsSegmentedControlKey]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:cellDictionary[@"values"]];
        [segment addTarget:self action:NSSelectorFromString(cellDictionary[@"selector"]) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = segment;
        
        NSDictionary *titleAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12.0]};
        [segment setTitleTextAttributes:titleAttributes forState:UIControlStateNormal];
        
        NSString *selectedValue = cellDictionary[@"selectedValue"];
        for (int i = 0; i < [cellDictionary[@"values"] count]; i++)
            if ([[segment titleForSegmentAtIndex:i] isEqualToString:selectedValue])
                [segment setSelectedSegmentIndex:i];
    }
    else if ([cellType isEqualToString:ACSettingsViewControllerKey] || [cellType isEqualToString:ACSettingsWebViewKey]) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if ([cellType isEqualToString:ACSettingsButtonKey]) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    BOOL requiresPurchase = [cellDictionary[@"requiresPurchase"] boolValue];
    cell.textLabel.numberOfLines = 0;
    if (![[self appDelegate] allFeaturesUnlocked]) {
        if (requiresPurchase) {
            if (cell.accessoryView && [cell.accessoryView isKindOfClass:[UIControl class]])
                [(UIControl *)cell.accessoryView setEnabled:NO];
            cell.textLabel.enabled = NO;
            cell.userInteractionEnabled = NO;
        }
        else {
            if (cell.accessoryView && [cell.accessoryView isKindOfClass:[UIControl class]])
                [(UIControl *)cell.accessoryView setEnabled:YES];
            cell.textLabel.enabled = YES;
            cell.userInteractionEnabled = YES;
        }
    }
    else {
        if (cell.accessoryView && [cell.accessoryView isKindOfClass:[UIControl class]])
            [(UIControl *)cell.accessoryView setEnabled:YES];
        cell.textLabel.enabled = YES;
        cell.userInteractionEnabled = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *cellDictionary = settings[indexPath.section][@"items"][indexPath.row];
    NSString *cellType = cellDictionary[@"type"];
    
    UIViewController *vc = nil;
    
    if ([cellType isEqualToString:ACSettingsTextFieldKey] || [cellType isEqualToString:ACSettingsSegmentedControlKey] || [cellType isEqualToString:ACSettingsSwitchKey])
        return;
    else if ([cellType isEqualToString:ACSettingsButtonKey]) {
        void (^action)(void) = cellDictionary[@"action"];
        action();
        return;
    }
    else if ([cellType isEqualToString:ACSettingsWebViewKey]) {
//        UIViewController *webViewController = [[UIViewController alloc] init];
//        UIWebView *webView = [[UIWebView alloc] initWithFrame:webViewController.view.frame];
//        webViewController.automaticallyAdjustsScrollViewInsets = YES;
//        [webViewController.view addSubview:webView];
//        NSURL *URL = [NSURL URLWithString:cellDictionary[@"url"]];
//        [webView loadRequest:[NSURLRequest requestWithURL:URL]];
//        webView.scalesPageToFit = YES;
//        vc = webViewController;
    }
    else if ([cellType isEqualToString:ACSettingsViewControllerKey]) {
        Class c = NSClassFromString(cellDictionary[@"controller"]);
        vc = [[c alloc] init];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Actions

- (void)displayNameChanged:(UISegmentedControl *)sender {
    NSString *value = [sender titleForSegmentAtIndex:sender.selectedSegmentIndex];
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:@"baseDisplay"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"baseDisplayChanged" object:nil];
}

@end

