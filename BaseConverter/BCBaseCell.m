//
//  BCBaseCell.m
//  BaseConverter
//
//  Created by Christopher Loonam on 12/3/15.
//  Copyright (c) 2015 Christopher Loonam. All rights reserved.
//

#import "BCBaseCell.h"

@implementation BCBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)textChanged:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cell:textDidChange:)])
        [self.delegate cell:self textDidChange:self.textField.text];
    [sender resignFirstResponder];
}

@end
