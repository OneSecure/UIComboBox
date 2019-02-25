//
//  UIComboBox.m
//  UIComboBox
//
//  Created by oneSecure on 14-12-24.
//  Copyright (c) 2014 oneSecure. All rights reserved.
//

#import "UIComboBox.h"

@implementation NSArray (safeArray)
- (id) safe_objectAtIndex:(NSUInteger)index {
    if ((0 <= index) && (index < self.count)) {
        return [self objectAtIndex:index];
    }
    return nil;
}
@end

#define __USING_ANIMATE__ 1

static const NSTimeInterval kAnimateInerval = 0.2;

//========================== PassthroughView =============================================

@interface PassthroughView : UIView
@property (nonatomic, copy) NSArray<UIView *> *passViews;
@property(nonatomic, strong) void(^doPassthrough)(BOOL isPass);
@end

@implementation PassthroughView {
    BOOL _testHits;
}

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (_testHits) {
        return nil;
    }
    if (!self.passViews || (self.passViews && self.passViews.count==0)) {
        return nil;
    }
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        _testHits = YES;
        CGPoint superPoint = [self.superview convertPoint:point fromView:self];
        UIView *superHitView = [self.superview hitTest:superPoint withEvent:event];
        _testHits = NO;
        BOOL pass = [self isPassthroughView:superHitView];
        if (pass) {
            hitView = superHitView;
        }
        if (_doPassthrough) {
            _doPassthrough(pass);
        }
    }
    return hitView;
}

- (BOOL) isPassthroughView:(UIView *)view {
    if (view == nil) {
        return NO;
    }
    if ([self.passViews containsObject:view]) {
        return YES;
    }
    return [self isPassthroughView:view.superview];
}

@end


//========================== ImageTextView ==========================================

@implementation ImageTextView {
    UILabel *_textLabel;
    UIImageView *_imageView;
}

- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_textLabel];

        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
    }
    return self;
}

- (NSString *) text {
    return _textLabel.text;
}

- (void) setText:(NSString *)text {
    _textLabel.text = text;
}

- (UIFont *) font {
    return _textLabel.font;
}

- (void) setFont:(UIFont *)font {
    _textLabel.font = font;
}

- (UIColor *) textColor {
    return _textLabel.textColor;
}

- (void) setTextColor:(UIColor *)textColor {
    _textLabel.textColor = textColor;
}

- (NSTextAlignment) textAlignment {
    return _textLabel.textAlignment;
}

- (void) setTextAlignment:(NSTextAlignment)textAlignment {
    _textLabel.textAlignment = textAlignment;
}

- (UIColor *) shadowColor {
    return _textLabel.shadowColor;
}

- (void) setShadowColor:(UIColor *)shadowColor {
    _textLabel.shadowColor = shadowColor;
}

- (BOOL) highlighted {
    return _textLabel.highlighted;
}

- (void) setHighlighted:(BOOL)highlighted {
    _textLabel.highlighted = highlighted;
}

- (UIImage *) image {
    return _imageView.image;
}

- (void) setImage:(UIImage *)image {
    _imageView.image = image;
    [self setNeedsLayout];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    if (_imageView.image) {
        _imageView.frame = CGRectMake(0, 0, height, height);
        _textLabel.frame = CGRectMake(height, 0, width-height, height);
    } else {
        _imageView.frame = CGRectMake(0, 0, 0, height);
        _textLabel.frame = CGRectMake(0, 0, width, height);
    }
}

@end


//========================== UIComboBox =============================================


@interface UIComboBox () <UITableViewDelegate, UITableViewDataSource>
@end

@implementation UIComboBox {
    __weak ImageTextView *_textLabel;
    __weak UIImageView *_rightView;
    UITableView *_internalTableView;
    PassthroughView *_passthroughView;
    BOOL _tableViewOnAbove;
    NSDate *_tapMoment;
    
    NSMutableArray *_entries;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"UIComboBox instance %0xd", (int)self];
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initSubviews];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubviews];
    }
    return self;
}

- (instancetype) init {
    if (self = [super initWithFrame:CGRectMake(58, 102, 165, 37)]) {
        [self initSubviews];
    }
    return self;
}

- (void) setEntries:(NSArray *)entries {
    [_entries removeAllObjects];
    if (entries) {
        [_entries addObjectsFromArray:entries];
    }
    [_internalTableView reloadData];
}

- (NSArray *) entries {
    return _entries;
}

- (void) setSelectedItem:(NSInteger)selectedItem {
    if (_selectedItem == selectedItem) {
        return;
    }
    _selectedItem = selectedItem;
    if (_entries.count == 0) {
        _textLabel.text = nil;
        _textLabel.image = nil;
        return;
    }

    id obj = [_entries safe_objectAtIndex:_selectedItem];
    if (obj == nil) {
        return;
    }

    NSString *text = nil;
    if ([obj respondsToSelector:@selector(description)]) {
        text = [obj performSelector:@selector(description)];
    }
    _textLabel.text = text.length ? text : @"(NULL)";

    if ([obj respondsToSelector:@selector(image)]) {
        _textLabel.image = [obj performSelector:@selector(image)];
    }

    if (_internalTableView) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:_selectedItem inSection:0];
        [_internalTableView selectRowAtIndexPath:path
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (void) setEnabled:(BOOL)enabled {
    //_textLabel.textLabel.enabled = enabled;
    _textLabel.textColor = enabled?[UIColor blackColor]:[UIColor grayColor];
    _rightView.highlighted = !enabled;
    [super setEnabled:enabled];
}

- (void) setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = _borderColor.CGColor;
}

- (UIFont *) font {
    return _textLabel.font;
}

- (void) setFont:(UIFont *)font {
    _textLabel.font = font;
    [_internalTableView reloadData];
}

- (UIColor *) textColor {
    return _textLabel.textColor;
}

- (void) setTextColor:(UIColor *)textColor {
    _textLabel.textColor = textColor;
    [_internalTableView reloadData];
}

- (void) setShowArrow:(BOOL)showArrow {
    _showArrow = showArrow;
    [self layoutIfNeeded];
}

- (void) appendObject:(id)object {
    NSAssert(object, @"nil object");
    if (object) {
        [_entries addObject:object];
        [_internalTableView reloadData];

        if (_entries.count == 1) {
            [self setSelectedItem:0];
            if (_onItemSelected) {
                _onItemSelected(object, 0);
            }
        }
    }
}

- (void) initSubviews {
    self.layer.cornerRadius = 7.;
    self.layer.borderWidth = .5;
    _borderColor = [UIColor colorWithCGColor:self.layer.borderColor];

    ImageTextView *textLabel = [[ImageTextView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:textLabel];
    _textLabel = textLabel;

    UIImageView *rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"combobox_down"]];
    rightView.highlightedImage = [UIImage imageNamed:@"combobox_down_highlighed"];
    [self addSubview:rightView];
    _rightView = rightView;

    self.userInteractionEnabled = YES;

    _entries = [[NSMutableArray alloc] init];
    
    _tapMoment = [NSDate date];
    
    _showArrow = YES;
    
    _selectedItem = -1;
}

- (void) layoutSubviews {
    [super layoutSubviews];

    CGRect rc = CGRectZero; rc.size = self.frame.size;

    if (_showArrow) {
        CGRect rcRight = rc;
        rcRight.size.width = rc.size.height;
        rcRight.origin.x = rc.origin.x + rc.size.width -rcRight.size.width;

        CGRect rcLabel = rc;
        rcLabel.size.width = rc.size.width - rcRight.size.width;

        rcLabel = CGRectInset(rcLabel, 2, 2);
        rcRight = CGRectInset(rcRight, 2, 2);

        _textLabel.frame = rcLabel;
        _rightView.frame = rcRight;
    } else {
        _textLabel.frame = rc;
        _rightView.frame = CGRectZero;
    }

    _passthroughView.frame = [UIScreen mainScreen].bounds;
}

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.enabled) {
        if (CGRectContainsPoint(_textLabel.frame, point) || CGRectContainsPoint(_rightView.frame, point)) {
            [self tapHandle];
        }
    }
    return [super hitTest:point withEvent:event];
}

#pragma mark - firstResponder
- (void) tapHandle {
    UIView *topView = [UIComboBox topMostView:self];
    NSAssert(topView, @"Can not obtain the most-top leave view.");
    if (!_internalTableView) {
        UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        [tableView setDelegate:self];
        [tableView setDataSource:self];
        tableView.layer.cornerRadius = 7.;
        tableView.layer.borderWidth = .5;
        _internalTableView = tableView;
    }
    
    if ([_borderColor isEqual:[UIColor whiteColor]]) {
        _internalTableView.layer.borderColor = [UIColor blackColor].CGColor;
    } else {
        _internalTableView.layer.borderColor = _borderColor.CGColor;
    }

    if (_internalTableView.superview == nil) {
        NSDate *current = [NSDate date];
        if ([current timeIntervalSinceDate:_tapMoment] < kAnimateInerval) {
            return;
        }
        _tapMoment = current;

        _rightView.image = [UIImage imageNamed:@"combobox_up"];
        _rightView.highlightedImage = [UIImage imageNamed:@"combobox_up_highlighed"];

        CGRect frame = [self calcTableViewRect];
        
        [topView addSubview:_internalTableView];

#if __USING_ANIMATE__
        CGRect initRc = frame;
        if (_tableViewOnAbove) {
            initRc.origin.y += initRc.size.height;
        }
        initRc.size.height = 0;
        _internalTableView.frame = initRc;
        [UIView animateWithDuration:kAnimateInerval animations:^{
            self->_internalTableView.frame = frame;
        } completion:^(BOOL finished) {
            //
        }];
#else
        _internalTableView.frame = frame;
#endif

        if (_entries.count && ([_entries safe_objectAtIndex:_selectedItem] != nil)) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:_selectedItem inSection:0];
            [_internalTableView selectRowAtIndexPath:path
                                            animated:YES
                                      scrollPosition:UITableViewScrollPositionMiddle];
        }

        if (_passthroughView == nil) {
            CGRect rc = [UIScreen mainScreen].bounds;

            _passthroughView = [[PassthroughView alloc] initWithFrame:rc];
            _passthroughView.passViews = @[self, _internalTableView, ];

            __weak typeof(self) weakSelf = self;
            [_passthroughView setDoPassthrough:^(BOOL isPass) {
                __strong typeof(self) strongSelf = weakSelf;
                if (!isPass) {
                    [strongSelf doClearup];
                }
            }];
        }
        [topView addSubview:_passthroughView];
    } else {
        [self doClearup];
    }
}

#pragma mark - change state when highlighed

- (void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    _rightView.highlighted = highlighted; // change button to highlighed state
    _textLabel.highlighted = highlighted; // change label to highlighed state
    _textLabel.shadowColor = highlighted ? [UIColor lightGrayColor] : nil;
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_entries count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.frame.size.height;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* identifier = @"UIComboBoxCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    cell.textLabel.font = _textLabel.font;

    id obj = [_entries objectAtIndex:[indexPath row] ];

    if ([obj respondsToSelector:@selector(description)]) {
        NSString *text = [obj performSelector:@selector(description)];
        cell.textLabel.text = (text.length != 0) ? text : @"(NULL)";
        cell.textLabel.textColor = _textLabel.textColor;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    if ([obj respondsToSelector:@selector(image)]) {
        cell.imageView.image = [obj performSelector:@selector(image)];
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return _editable;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger row = indexPath.row;
        id obj = _entries[row];
        [_entries removeObjectAtIndex:row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if (_onItemDeleted) {
            _onItemDeleted(obj, (int)row);
        }

        NSInteger current = self.selectedItem;

        if (current >= row) {
            [self setSelectedItem:(current - 1)];
            if (current == row) {
                if (_onItemSelected && _entries.count) {
                    NSInteger newSelect = self.selectedItem;
                    _onItemSelected(_entries[newSelect], (int)newSelect);
                }
            }
        } else {
            [self setSelectedItem:current];
        }
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger selectedItem = (NSInteger) indexPath.row;
    [self setSelectedItem:selectedItem];
    [self doClearup];

    if (_onItemSelected) {
        _onItemSelected(_entries[selectedItem], selectedItem);
    }
}

- (void) doClearup {
#if __USING_ANIMATE__
    NSDate *current = [NSDate date];
    if ([current timeIntervalSinceDate:_tapMoment] < kAnimateInerval) {
        return;
    }
    _tapMoment = current;
    
    CGRect frame = _internalTableView.frame;
    if (_tableViewOnAbove) {
        frame.origin.y += frame.size.height;
    }
    frame.size.height = 0.0;
    [UIView animateWithDuration:kAnimateInerval animations:^{
        self->_internalTableView.frame = frame;
    } completion:^(BOOL finished) {
        [self->_internalTableView removeFromSuperview];
        [self->_passthroughView removeFromSuperview];
    }];
#else
    [_internalTableView removeFromSuperview];
    [_passthroughView removeFromSuperview];
#endif
    _rightView.image = [UIImage imageNamed:@"combobox_down"];
    _rightView.highlightedImage = [UIImage imageNamed:@"combobox_down_highlighed"];
}

- (CGRect) calcTableViewRect {
    static const CGFloat gapOfViews = 2.0;
    UIView *topView = [UIComboBox topMostView:self];
    CGFloat screenHeight = topView.frame.size.height;
    CGRect rc = self.frame;
    rc = [self.superview convertRect:rc toView:topView];
    
    CGFloat topLine = rc.origin.y - gapOfViews;
    CGFloat bottomLine = rc.origin.y + rc.size.height + gapOfViews;
    
    NSInteger count = [_internalTableView numberOfRowsInSection:0];
    if (count < 1) {
        count = 1;
    }
    CGFloat tableViewMaxHeight = count * self.frame.size.height;
    CGFloat statusBarHeight = [UIComboBox statusBarHeight];
    
    _tableViewOnAbove = NO;
    
    if (bottomLine + tableViewMaxHeight < screenHeight) {
        rc.origin.y = bottomLine;
        rc.size.height = tableViewMaxHeight;
    } else if (topLine - tableViewMaxHeight >= statusBarHeight) {
        rc.origin.y = topLine - tableViewMaxHeight;
        rc.size.height = tableViewMaxHeight;
        _tableViewOnAbove = YES;
    } else {
        if ((topLine - statusBarHeight) > (screenHeight - bottomLine)) {
            rc.origin.y = statusBarHeight + gapOfViews;
            rc.size.height = topLine - (statusBarHeight + gapOfViews);
            _tableViewOnAbove = YES;
        } else {
            rc.origin.y = bottomLine;
            rc.size.height = screenHeight - gapOfViews - bottomLine;
        }
    }
    return rc;
}

#pragma mark -

+ (UIView *) topMostView:(UIView *)view {
    UIView *superView = view.superview;
    if (superView) {
        return [self topMostView:superView];
    } else {
        return view;
    }
}

+ (CGFloat) statusBarHeight {
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

@end
