//
//  FGUBaseViewController.m
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author: Timur Kuchkarov
//  Responcible: Nikolay July
//

#import "FGUBaseViewController.h"

@interface FGUBaseViewController ()

@end

@implementation FGUBaseViewController

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
