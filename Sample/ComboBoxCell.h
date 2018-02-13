//
//  ComboBoxCell.h
//  Sample
//
//  Created by oneSecure on 11/22/17.
//  Copyright © 2017 oneSecure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComboBoxCell<ObjectType> : UITableViewCell
@property(strong, nonatomic) NSArray<ObjectType> *entries;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) UIFont *font;
@property(nonatomic, assign) NSInteger selectedIndex;
@property(nonatomic, strong) void(^selectChanged)(ObjectType obj, NSInteger selected);
@end

