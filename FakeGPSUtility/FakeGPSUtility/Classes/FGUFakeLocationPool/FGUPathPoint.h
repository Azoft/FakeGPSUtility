//
//  FGUPathSegment.h
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author: Nikolay July
//  Responcible: Nikolay July
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "FGUConstants.h"

#if defined(USE_TEST_UTILITIES) && USE_TEST_UTILITIES

@interface FGUPathPoint : CLLocation

/**
 *  Time delay for moveToNextLocation method
 */
@property(nonatomic) NSTimeInterval timeInterval;

- (instancetype)initWithLocation:(CLLocation *)location;

@end

#endif
