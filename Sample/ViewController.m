//
//  ViewController.m
//  Sample
//
//  Created by oneSecure on 14-12-24.
//  Copyright (c) 2014年 oneSecure. All rights reserved.
//

#import "ViewController.h"
#import "UIComboBox.h"
#import "ComboBoxCell.h"

@interface SomeObject : NSObject
@property(nonatomic, strong) NSString *text;
@property(nonatomic, strong) UIImage *image;
- (instancetype) initWithText:(NSString *)text image:(UIImage *)image;
@end

@implementation SomeObject

- (instancetype) initWithText:(NSString *)text image:(UIImage *)image {
    if (self = [super init]) {
        _text = text;
        _image = image;
    }
    return self;
}

- (NSString *) description {
    return _text;
}

@end

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@end

@implementation ViewController {
    __weak IBOutlet UIComboBox *_myComboBox;
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UIComboBox *_bottomComboBox;
}

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _myComboBox.backgroundColor = [UIColor whiteColor];
    _myComboBox.entries = @[@"15 minutes", @"30 minutes", @"1 hours", @"2 hours"];
    _myComboBox.selectedItem = 1;
    [_myComboBox setOnItemSelected:^(NSString *selectedObject, NSInteger selectedIndex) {
        NSLog(@"%@ selectd and index is %ld", selectedObject, (long)selectedIndex);
    }];

    _myComboBox.editable = YES;
    [_myComboBox setOnItemDeleted:^(NSString *deletedObject, NSInteger deletedIndex) {
        NSLog(@"%@ deleted and index is %ld", deletedObject, (long)deletedIndex);
    }];

#if 0
    UIComboBox<NSString *> *box = [[UIComboBox alloc] initWithFrame:CGRectMake(58, 100, 165, 37)];
#else
    UIComboBox<NSString *> *box = [[UIComboBox alloc] init];
    box.frame = CGRectMake(58, 100, 165, 37);
#endif
    [box setOnItemSelected:^(NSString *selectedObject, NSInteger selectedIndex) {
        NSLog(@"select changed to %ld", (long)selectedIndex);
    }];
    box.entries = @[@"xxxx", @"yyyyabcdefghijklmnopqrst", @"zzzz", @"hhhh", @"wwww", @"aaaaa", @"bbbb", @"xxxx", @"yyyy", @"zzzz", @"hhhh", @"wwww", @"aaaaa", @"bbbb", @"xxxx", @"yyyy", @"zzzz", @"hhhh", @"wwww", @"aaaaa", @"bbbb", ];
    box.selectedItem = 5;

    [self.view addSubview:box];
    
    _tableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _tableView.layer.borderWidth = .5;
    _tableView.layer.cornerRadius = 5;
    _tableView.dataSource = self;
    _tableView.delegate = self;

    _bottomComboBox.backgroundColor = [UIColor whiteColor];
    _bottomComboBox.entries = @[@"red", @"blue", @"yellow", @"green", @"red", @"blue", @"yellow", @"green", @"red", @"blue", @"yellow", @"green", @"red", @"blue", @"yellow", @"green", ];
    _bottomComboBox.selectedItem = 1;
    [_bottomComboBox setOnItemSelected:^(NSString *selectedObject, NSInteger selectedIndex) {
        NSLog(@"%@ selectd and index is %ld", selectedObject, (long)selectedIndex);
    }];
    _bottomComboBox.editable = YES;
    [_bottomComboBox setOnItemDeleted:^(NSString *deletedObject, NSInteger deletedIndex) {
        NSLog(@"%@ deleted and index is %ld", deletedObject, (long)deletedIndex);
    }];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //_myComboBox.frame = CGRectMake(58, 130, 165, 37);
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ComboBoxCell<SomeObject *> *someTypeCell = [[ComboBoxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    someTypeCell.entries = [self serverTypeCollection:indexPath.row];
    someTypeCell.selectedIndex = indexPath.row;
    someTypeCell.title = NSLocalizedString(@"Something type", nil);
    someTypeCell.selectChanged = ^(SomeObject *obj, NSInteger selected) {
        NSLog(@"selectChanged %@, selected=%ld", obj, (long)selected);
    };
    return someTypeCell;
}

- (NSArray<SomeObject *> *) serverTypeCollection:(NSInteger)row {
    NSMutableArray<SomeObject *> *result = [[NSMutableArray alloc] init];
    for (int i=0; i<5; ++i) {
        NSString *txt = [NSString stringWithFormat:@"row=%ld item=%d", (long)row, i];
        if (i==3) {
            txt = [NSString stringWithFormat:@"row=%ld item=%d opqrstuvwxyz1234567890", (long)row, i];
        }
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"image%d", i]];
        [result addObject:[[SomeObject alloc] initWithText:txt image:img]];
    }
    return result;
}

@end
