//
//  FGUPathTableViewController.h
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

@interface FGUPathTableViewController : FGUBaseViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak) IBOutlet UITableView *tableView;

@end

#endif