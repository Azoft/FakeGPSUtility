//
//  FGUSettingsViewController.h
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author: Nikolay July
//  Responcible: Nikolay July
//

#import "FGUBaseViewController.h"
#import "FGUConstants.h"

#if defined(USE_TEST_UTILITIES) && USE_TEST_UTILITIES

@interface FGUSettingsViewController : FGUBaseViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property(nonatomic, weak) IBOutlet UITableView *tableView;

@property(nonatomic, strong) IBOutlet UITableViewCell *timescaleCell;
@property(nonatomic, weak) IBOutlet UITextField *timescaleTextField;

@property(nonatomic, strong) IBOutlet UITableViewCell *loopCell;
@property(nonatomic, weak) IBOutlet UISwitch *loopSwitch;

@property(nonatomic, strong) IBOutlet UIView *accessoryView;

@end

#endif