//
//  ComboBoxCell.m
//  Sample
//
//  Created by oneSecure on 11/22/17.
//  Copyright © 2017 oneSecure. All rights reserved.
//

#import "ComboBoxCell.h"
#import <UIComboBox/UIComboBox.h>

#define kControlFontSize 13

#define kNameLabelBegin  10
#define kSeparatorBegin  101
#define kValueLabelBegin 110
#define kNameLabelWidth  90


@implementation ComboBoxCell {
    UILabel *_titleLabel;
    UIComboBox<id> *_comboBox;
}

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self _doInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self _doInit];
}

- (void) _doInit {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_titleLabel];
    
    _comboBox = [[UIComboBox alloc] init];
    [self.contentView addSubview:_comboBox];
    
    [self setFont:[UIFont systemFontOfSize:kControlFontSize]];
}

- (NSString *) title {
    return _titleLabel.text;
}

- (void) setTitle:(NSString *)title {
    _titleLabel.text = title;
    [self setNeedsLayout];
}

- (UIFont *) font {
    return _titleLabel.font;
}

- (void) setFont:(UIFont *)font {
    _titleLabel.font = font;
    _comboBox.font = font;
}

- (NSArray *) entries {
    return _comboBox.entries;
}

- (void) setEntries:(NSArray *)entries {
    [_comboBox setEntries:[NSMutableArray arrayWithArray:entries]];
}

- (NSInteger) selectedIndex {
    return _comboBox.selectedItem;
}

- (void) setSelectedIndex:(NSInteger)selectedIndex {
    [_comboBox setSelectedItem:selectedIndex];
}

- (void) setSelectChanged:(void (^)(id obj, NSInteger selected))selectChanged {
    _comboBox.onItemSelected = selectChanged;
}

- (void (^)(id obj, NSInteger selected)) selectChanged {
    return _comboBox.onItemSelected;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.contentView.frame;
    CGFloat yBegin = 2.0;
    CGFloat yLabelHeight = frame.size.height - 2 * yBegin;
    
    CGSize titleSize = [_titleLabel.text sizeWithAttributes: @{NSFontAttributeName:_titleLabel.font}];
    
    _titleLabel.frame = CGRectMake(kNameLabelBegin, yBegin, titleSize.width, yLabelHeight);
    _comboBox.frame = CGRectMake(kNameLabelBegin * 2 + titleSize.width, yBegin, frame.size.width - titleSize.width - kNameLabelBegin*3, yLabelHeight);
}

@end
