UIComboBox
===========
A simple ComboBox implement for iOS.
Using a UITableView to display the data.

![](https://raw.githubusercontent.com/onesecure/UIComboBox/master/sample.png)
![](https://raw.githubusercontent.com/onesecure/UIComboBox/master/sample2.png)


## Usage
Add the following line to your application:

```objective-c
UIComboBox<NSString *> *box = [[UIComboBox alloc] initWithFrame:CGRectMake(58, 202, 165, 37)];
box.entries = @[@"15 minutes", @"30 minutes", @"1 hours", @"2 hours"];
box.selectedItem = 2;
[box setOnItemSelected:^(NSString *selectedObject, NSInteger selectedIndex) {
    NSLog(@"%@ selectd and index is %d", selectedObject, selectedIndex);
}];

box.editable = YES;
[box setOnItemDeleted:^(NSString *deletedObject, NSInteger deletedIndex) {
    NSLog(@"%@ deleted and index is %d", deletedObject, deletedIndex);
}];
[self.view addSubview:box];
```

## Supported OS
Tested in iOS 6.0 and later devices and simulators

## LICENSE
Released in [MIT License](http://opensource.org/licenses/mit-license.php)
