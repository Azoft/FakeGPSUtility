//
//  FGUTestMainViewController.h
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
#import <MapKit/MapKit.h>
#import "FGUConstants.h"

@interface FGUTestMainViewController : FGUBaseViewController<MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@end
