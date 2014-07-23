//
//  FGUPathSegment.m
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author: Nikolay July
//  Responcible: Nikolay July
//

#import "FGUPathPoint.h"

#if defined(USE_TEST_UTILITIES) && USE_TEST_UTILITIES

NSString *FGUTimeIntervalKey = @"TUSpeedtKey";

@implementation FGUPathPoint

- (instancetype)initWithLocation:(CLLocation *)location {
    return [self initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeDouble:self.timeInterval forKey:FGUTimeIntervalKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _timeInterval = [aDecoder decodeDoubleForKey:FGUTimeIntervalKey];
    }
    return self;
}

@end

#endif
