//
//  FGUSettingsViewController.m
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author: Nikolay July
//  Responcible: Nikolay July
//

#import "FGUSettingsViewController.h"
#import "FGUFakeLocationPool.h"

#import <MapKit/MapKit.h>

#if defined(USE_TEST_UTILITIES) && USE_TEST_UTILITIES

typedef enum {
    FGUSettingsCellTimeScale       = 0,
    FGUSettingsCellLoop            = 1
} FGUSettingsCell;

@interface FGUSettingsViewController ()
    
// contains NSNumbers with FGUSettingsCell's
@property (nonatomic, strong) NSArray *cellsConfigurationArray;
@property (nonatomic, weak) UITextField *currentTextField;

@end

@implementation FGUSettingsViewController

#pragma mark UIView life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (NSClassFromString(@"MKRoute") != Nil) {
        UISegmentedControl *modeControl = (UISegmentedControl *)self.tableView.tableHeaderView;
        [modeControl insertSegmentWithTitle:@"Route" atIndex:modeControl.numberOfSegments animated:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self _reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_keyboardWillShowNotification:)
												 name:UIKeyboardWillShowNotification object:nil];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_keyboardWillHideNotification:)
												 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self _hideKeyboard];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

#pragma mark Actions

- (IBAction)simalationTypeWasChanged:(UISegmentedControl *)sender {
    SharedFakeLocationPool.currentSimulationMode = sender.selectedSegmentIndex;
    [self _reloadData];
}

- (IBAction)loopSwitcherChangedValue:(id)sender {
    SharedFakeLocationPool.loopSimulation = self.loopSwitch.on;
}

- (IBAction)accessoryDoneButtonAction:(id)sender {
    [self _hideKeyboard];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.cellsConfigurationArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *currentCellType = [_cellsConfigurationArray objectAtIndex:indexPath.section];
    switch (currentCellType.integerValue) {
        case FGUSettingsCellTimeScale: {
            return self.timescaleCell;
        }
            break;
        case FGUSettingsCellLoop: {
            return self.loopCell;
        }
            break;
            
        default:
            break;
    }
    
    return nil;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [textField setInputAccessoryView:self.accessoryView];
    self.currentTextField = textField;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self _updateDataFromTextField:textField];
    return YES;
}

-(BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    [self _updateDataFromTextField:textField];
    return YES;
}


#pragma mark hidden

- (void)onFileSimulationModeSelected {
    NSArray *pointsDicts = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Points" ofType:@"plist"]];
    if (!pointsDicts) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                   message:@"Invalid plist format"
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil] show];
    }
    [SharedFakeLocationPool beginUpdatePath];
    for (NSDictionary *pointDict in pointsDicts) {
        [SharedFakeLocationPool addLocationToPath:[[CLLocation alloc] initWithLatitude:[pointDict[@"latitude"] doubleValue]
                                                                             longitude:[pointDict[@"longitude"] doubleValue]]];
    }
    [SharedFakeLocationPool finishUpdatePath];
}

- (void)_reloadData {
    if ([self isViewLoaded] == NO) {
        return;
    }

    self.cellsConfigurationArray = nil;
    switch ([SharedFakeLocationPool currentSimulationMode]) {
        case FGULocationManagerSimModeSinglePointFromTouch:
            break;
        default: {
            self.cellsConfigurationArray = @[@(FGUSettingsCellTimeScale),
                                             @(FGUSettingsCellLoop)];
        }
            break;
    }
    
    ((UISegmentedControl *)self.tableView.tableHeaderView).selectedSegmentIndex = [SharedFakeLocationPool currentSimulationMode];
    
    self.timescaleTextField.text = [NSString stringWithFormat:@"%.02f", SharedFakeLocationPool.timescale];
    self.loopSwitch.on = SharedFakeLocationPool.loopSimulation;
    
    [self.tableView reloadData];
    
    if (SharedFakeLocationPool.currentSimulationMode == FGULocationManagerSimModeRouteFromFile) {
        [self onFileSimulationModeSelected];
    }
}

- (void)_updateDataFromTextField:(UITextField *)textField {
    if(!textField) {
        return;
    }
    
    if(textField == self.timescaleTextField) {
        double val = [self.timescaleTextField.text doubleValue];
        if(val <= 0) {
            val = 1.;
        }
        SharedFakeLocationPool.timescale = val;
        return;
    }
}   

- (void)_keyboardWillShowNotification:(NSNotification *)notification {
    
    double animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    double kbHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    [UIView animateWithDuration:animationDuration animations:^{
        self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height + kbHeight+40);
        CGPoint offsetPoint = CGPointMake(self.tableView.contentOffset.x, 78 + 70 * (self.currentTextField.tag - 1));
        if (offsetPoint.y < 0) {
            offsetPoint.y = 0;
        }
        self.tableView.contentOffset = offsetPoint;
    }];
}

- (void)_keyboardWillHideNotification:(NSNotification *)notification {
    double animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    double kbHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height - (kbHeight+40));
    }];
}

- (void)_hideKeyboard {
    [self.timescaleTextField resignFirstResponder];
}

@end

#endif