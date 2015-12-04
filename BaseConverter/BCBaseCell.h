//
//  BCBaseCell.h
//  BaseConverter
//
//  Created by Christopher Loonam on 12/3/15.
//  Copyright (c) 2015 Christopher Loonam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCBaseCell;

@protocol BCBaseCellDelegate <NSObject>

- (void)cell:(BCBaseCell *)cell textDidChange:(NSString *)text;

@end

@interface BCBaseCell : UITableViewCell

@property (nonatomic) NSInteger base;
@property (weak, nonatomic) IBOutlet UILabel *baseLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) id<BCBaseCellDelegate> delegate;

- (IBAction)textChanged:(id)sender;

@end
