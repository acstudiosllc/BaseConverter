//
//  BCBaseCell.m
//  BaseConverter
//
//  Created by Christopher Loonam on 12/3/15.
//  Copyright (c) 2015 Christopher Loonam. All rights reserved.
//

#import "BCBaseCell.h"
#import "BCBaseConverter.h"

@implementation BCBaseCell

- (instancetype)init {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BCBaseCell"]) {
        self.baseLabel = [[UILabel alloc] init];
        self.textField = [[UITextField alloc] init];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.baseLabel];
        [self.contentView addSubview:self.textField];
        
        self.baseLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.baseLabel.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
        [self.baseLabel.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor constant:-40.0].active = YES;
        [self.baseLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10.0].active = YES;
        
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.spellCheckingType = UITextSpellCheckingTypeNo;
        [self.textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
        self.textField.borderStyle = UITextBorderStyleRoundedRect;
        self.textField.translatesAutoresizingMaskIntoConstraints = NO;
        [self.textField.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
        [self.textField.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor constant:-40.0].active = YES;
        [self.textField.topAnchor constraintEqualToAnchor:self.baseLabel.bottomAnchor constant:10.0].active = YES;
        [self.textField.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-10.0].active = YES;

        self.textField.text = @"0";
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"value"] && [object isKindOfClass:[BCBaseConverter class]] && ![self.textField isFirstResponder]) {
        self.textField.text = [(BCBaseConverter *)object getValueForBase:self.base];
    }
}

- (void)textChanged:(UITextField *)sender {
    NSString *text = sender.text;
    if (self.base <= 36) {
        text = [text uppercaseString];
    }
    if (text.length && [self.converter valueForDigit:[text substringFromIndex:text.length-1]] >= self.base) {
        text = [text substringToIndex:text.length-1];
    } else {
        [self.converter setValue:text inBase:self.base];
    }
    sender.text = text;
}

@end
