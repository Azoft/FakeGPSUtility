//
//  TUViewController.h
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author: Timur Kuchkarov
//  Responcible: Nikolay July
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FGUBaseViewController.h"
#import "FGUConstants.h"

#if defined(USE_TEST_UTILITIES) && USE_TEST_UTILITIES

@class FGULocationManager;

@interface FGUMapViewController : FGUBaseViewController<MKMapViewDelegate>

@property(nonatomic, retain) IBOutlet MKMapView *mapView;

@end

#endif
