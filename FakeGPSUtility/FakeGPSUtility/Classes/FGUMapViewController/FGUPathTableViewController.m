//
//  FGUPathTableViewController.m
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author: Nikolay July
//  Responcible: Nikolay July
//

#import "FGUPathTableViewController.h"

#import "FGUFakeLocationPool.h"
#import "FGUMapItemCell.h"
#import "FGUPathPoint.h"

#if defined(USE_TEST_UTILITIES) && USE_TEST_UTILITIES

@interface FGUPathTableViewController ()

@end

@implementation FGUPathTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *nibName = NSStringFromClass([FGUMapItemCell class]);
    [self.tableView registerNib:[UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:nibName];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[SharedFakeLocationPool points] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FGUMapItemCell class])];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell_ forRowAtIndexPath:(NSIndexPath *)indexPath {
    FGUMapItemCell *cell = (FGUMapItemCell *)cell_;
    FGUPathPoint *point = [[SharedFakeLocationPool points] objectAtIndex:indexPath.row];
    
    BOOL single = SharedFakeLocationPool.currentSimulationMode == FGULocationManagerSimModeSinglePointFromTouch;

    cell.coordinateLabel.text = [NSString stringWithFormat:@"%@: \n(lat = %.2f, long = %.2f)",
                            single ? @"" : [NSString stringWithFormat:@"Point # %ld", indexPath.row + 1],
                            point.coordinate.latitude,
                            point.coordinate.longitude];
    cell.travelTimeLabel.text = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithDouble:point.timeInterval]
                                                                 numberStyle:NSNumberFormatterDecimalStyle];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end

#endif