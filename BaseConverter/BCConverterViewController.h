//
//  BCConverterViewController.h
//  BaseConverter
//
//  Created by Christopher Loonam on 12/3/15.
//  Copyright (c) 2015 Christopher Loonam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCBaseCell.h"

@interface BCConverterViewController : UITableViewController <BCBaseCellDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSString *currentValue;
@property (nonatomic) NSInteger currentBase;
@property (strong, nonatomic) NSArray *tableViewItems;

@end
