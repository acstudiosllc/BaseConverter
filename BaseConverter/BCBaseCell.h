//
//  BCBaseCell.h
//  BaseConverter
//
//  Created by Christopher Loonam on 12/3/15.
//  Copyright (c) 2015 Christopher Loonam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCBaseConverter;

@interface BCBaseCell : UITableViewCell

@property (nonatomic) NSInteger base;
@property (strong, nonatomic) UILabel *baseLabel;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) BCBaseConverter *converter;

@end
