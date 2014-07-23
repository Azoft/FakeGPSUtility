//
//  FGUTestMainViewController.m
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author: Timur Kuchkarov
//  Responcible: Nikolay July
//

#import "FGUTestMainViewController.h"
#import "FGUMenuViewController.h"
#import "FGUMenuWindow.h"

@interface FGUTestMainViewController () {
    MKPointAnnotation *_pointAnnotation;
}

@property(nonatomic, retain) CLLocationManager *locationManager;

@end

@implementation FGUTestMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.locationManager startUpdatingLocation];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.locationManager stopUpdatingLocation];
}

#pragma CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (locations.count == 0) {
        if (self.mapView.annotations.count > 0) {
            [self.mapView removeAnnotations:self.mapView.annotations];
        }
        return;
    }
    
    if (_pointAnnotation == nil) {
        _pointAnnotation = [[MKPointAnnotation alloc] init];
        [self.mapView addAnnotation:_pointAnnotation];
    }
    
    CLLocation *currentLocation = [locations lastObject];
    _pointAnnotation.coordinate = currentLocation.coordinate;
}

@end
