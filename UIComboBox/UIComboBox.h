//
//  UIComboBox.h
//  Sample
//
//  Created by oneSecure on 14-12-24.
//  Copyright (c) 2014 oneSecure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSArray (safeArray)
- (id) safe_objectAtIndex:(NSUInteger)index;
@end

@interface ImageTextView : UIView
@property(nonatomic, strong) NSString *text;
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) UIFont *font;
@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic, assign) NSTextAlignment textAlignment;
@property(nonatomic, strong) UIColor *shadowColor;
@property(nonatomic, assign) BOOL highlighted;
- (instancetype)initWithFrame:(CGRect)frame;
@end

@interface UIComboBox<ObjectType> : UIControl
@property(nonatomic, strong) NSArray<ObjectType> *entries;
@property(nonatomic, assign) NSInteger selectedItem;
@property(nonatomic, assign) BOOL editable;
@property(nonatomic, strong) void (^onItemSelected)(ObjectType selectedObject, NSInteger selectedIndex);
@property(nonatomic, strong) void (^onItemDeleted)(ObjectType deletedObject, NSInteger deletedIndex);
@property(nonatomic, strong) UIColor *borderColor;
@property(nonatomic, strong) UIFont *font;
@property(nonatomic, strong) UIColor *textColor;
@property(nonatomic, assign) BOOL showArrow;
- (void) appendObject:(ObjectType)object;
@end
