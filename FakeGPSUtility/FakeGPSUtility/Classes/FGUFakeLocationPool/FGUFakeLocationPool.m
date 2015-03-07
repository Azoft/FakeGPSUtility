//
//  FGUFakeLocationPool.m
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author:         Timur Kuchkarov
//                  Nikolay July
//  Responcible:    Nikolay July
//

#import <CoreLocation/CoreLocation.h>

#import "FGUFakeLocationPool.h"
#import "SynthesizeSingleton.h"
#import "FGURealLocationManager.h"
#import "FGUPathPoint.h"
#import "FGUPathPoint.h"

#if defined(USE_TEST_UTILITIES) && USE_TEST_UTILITIES

const int32_t TUNoSelectedSegmentIndex = -1;

NSString *const TULocationKey                   = @"TULocationKey";
NSString *const TUOldLocationKey                = @"TUOldLocationKey";
NSString *const TULocationPoolDidUpdateLocation = @"TULocationPoolDidUpdateLocation";
NSString *const TULocationPoolDidUpdatePathPointsNotification = @"TULocationPoolDidUpdatePathPoints";
NSString *const TULocationPoolDidStopSimulation = @"TULocationPoolDidStopSimulation";
NSString *const TULocationPoolDidStartSimulation= @"TULocationPoolDidStartSimulation";

// key for NSUserDefaults, NSData will be returned for this key
NSString *const TULocationSettingsKey = @"TULocationSettingsKey";

// coder keys
NSString *const TUCurrentSegmentSettingsKey = @"TUCurrentSegmentSettingsKey";
NSString *const TUPausedSettingsKey = @"TUPausedSettingsKey";
NSString *const TUSimulatingSettingsKey = @"TUSimulatingSettingsKey";
NSString *const TUSimulatingModeSettingsKey = @"TUSimulatingModeSettingsKey";
NSString *const TUTimescaleSettingsKey = @"TUTimescaleSettingsKey";
NSString *const TUSegmentsArraySettingsKey = @"TUSegmentsArraySettingsKey";
NSString *const TULoopSettingsKey = @"TULoopSettingsKey";

@interface FGUFakeLocationPool() <CLLocationManagerDelegate, NSCoding>

@property (nonatomic, getter = isPaused) BOOL paused;
@property (nonatomic, getter = isSimulating) BOOL simulating;
@property (nonatomic, getter = isPathUpdateInProgress) BOOL pathUpdateInProgress;
@property (nonatomic, readonly) NSMutableArray *pathPoints;
@property (nonatomic) int32_t currentSegmentIndex;
@property (nonatomic) dispatch_queue_t internalQueue;
@property (nonatomic, weak) FGUPathPoint *lastPathPoint;

@end

@implementation FGUFakeLocationPool

SYNTHESIZE_SINGLETON_FOR_CLASS(FGUFakeLocationPool);

#pragma mark - init/dealloc

- (id)init {
    NSData *savedData = [[NSUserDefaults standardUserDefaults] dataForKey:TULocationSettingsKey];
    if (savedData.length > 0) {
        NSKeyedUnarchiver *keyedUnachiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:savedData];
        self = [self initWithCoder:keyedUnachiver];
        [keyedUnachiver finishDecoding];
    } else {
        self = [super init];
        
        if (self) {
            _currentSegmentIndex = TUNoSelectedSegmentIndex;
            _paused = YES;
            _simulating = NO;
            _currentSimulationMode = FGULocationManagerSimModeSinglePointFromTouch;
            _timescale = 1.0f;
            _pathPoints = [[NSMutableArray alloc] initWithCapacity:50];
            [self _saveCurrentState];
        }
    }
    
    if (self) {
        _internalQueue = dispatch_queue_create("com.azoft.TestUtilities.FGUFakeLocationPool.internalDispatchQueue", DISPATCH_QUEUE_SERIAL);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationWillTeminate:) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        if (_simulating && !_paused) {
            [self resumeLocationSimulation];
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        _currentSegmentIndex = [aDecoder decodeInt32ForKey:TUCurrentSegmentSettingsKey];
        _paused = [aDecoder decodeBoolForKey:TUPausedSettingsKey];
        _loopSimulation = [aDecoder decodeBoolForKey:TULoopSettingsKey];
        _simulating = [aDecoder decodeBoolForKey:TUSimulatingSettingsKey];
        _currentSimulationMode = [aDecoder decodeInt32ForKey:TUSimulatingModeSettingsKey];
        _timescale = [aDecoder decodeDoubleForKey:TUTimescaleSettingsKey];
        _pathPoints = [[aDecoder decodeObjectForKey:TUSegmentsArraySettingsKey] mutableCopy];
        if (_pathPoints == nil) {
            _pathPoints = [[NSMutableArray alloc] initWithCapacity:50];
        }
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark - custom setters

- (void)setCurrentSimulationMode:(FGULocationManagerSimMode)currentSimulationMode {
    dispatch_async(self.internalQueue, ^{
        if (self.currentSimulationMode == currentSimulationMode) {
            return;
        }
        
        _currentSimulationMode = currentSimulationMode;
        [self stopLocationSimulation];
        
        if (self.currentSimulationMode == FGULocationManagerSimModeSinglePointFromTouch) {
            [self startLocationSimulation];
            FGUPathPoint *point = [self.pathPoints lastObject];
            if (self.simulating) {
                [self setSimulatedLocationToLocation:point fromLocation:self.currentPathPoint];
            }
            [self.pathPoints removeAllObjects];
            if (point) {
                [self.pathPoints addObject:point];
            }
        } else {
            [self.pathPoints removeAllObjects];
        }
        self.currentSegmentIndex = TUNoSelectedSegmentIndex;
    });
    
    [self postNotificationWithName:TULocationPoolDidUpdatePathPointsNotification];
}

- (void)setTimescale:(NSTimeInterval)timescale {
    dispatch_async(self.internalQueue, ^{
        _timescale = timescale;
        [self.pathPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ((FGUPathPoint *)obj).timeInterval = 1. / timescale;
        }];
    });
}

- (void)setPaused:(BOOL)paused {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _paused = paused;
}

- (void)beginUpdatePath {
    self.pathUpdateInProgress = YES;
}

- (void)finishUpdatePath {
    self.pathUpdateInProgress = NO;
    [self postNotificationWithName:TULocationPoolDidUpdatePathPointsNotification];
}

- (void)postNotificationWithName:(NSString *)notificationName {
    [self postNotificationWithName:notificationName userInfo:nil];
}

- (void)postNotificationWithName:(NSString *)notificationName userInfo:(NSDictionary *)userInfo {
    if (!self.pathUpdateInProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:userInfo];
        });
    }
}

- (void)addLocationToPath:(CLLocation *)location {
    dispatch_async(self.internalQueue, ^{
        FGUPathPoint *newPoint = [[FGUPathPoint alloc] initWithLocation:location];
        
        if (self.currentSimulationMode == FGULocationManagerSimModeSinglePointFromTouch) {
            newPoint.timeInterval = 0.;
            if (self.simulating) {
                [self setSimulatedLocationToLocation:newPoint fromLocation:self.currentPathPoint];
            }
            [self.pathPoints removeAllObjects];
        } else {
            newPoint.timeInterval = 1. / self.timescale;
        }
        
        [self.pathPoints addObject:newPoint];
    });
    
    [self postNotificationWithName:TULocationPoolDidUpdatePathPointsNotification];
}

- (void)setSimulatedLocationToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    if (newLocation != nil) {
        userInfo[TULocationKey] = newLocation;
    }
    if (oldLocation != nil) {
        userInfo[TUOldLocationKey] = oldLocation;
    }
    
    [self postNotificationWithName:TULocationPoolDidUpdateLocation userInfo:userInfo];
}

- (void)moveToNextLocation {
    dispatch_async(self.internalQueue, ^{
        if ([self.pathPoints count] == 0) {
            return;
        }
        
        if (self.currentSegmentIndex == TUNoSelectedSegmentIndex) {
            self.currentSegmentIndex = 0;
        }
        
        FGUPathPoint *endPoint = self.pathPoints[self.currentSegmentIndex];
        [self setSimulatedLocationToLocation:endPoint fromLocation:self.lastPathPoint];
        
        if (endPoint.timeInterval > 0.) {
            [self performSelector:_cmd withObject:nil afterDelay:endPoint.timeInterval];
        }
        
        self.lastPathPoint = endPoint;
        self.currentSegmentIndex++;
        
        if (self.currentSegmentIndex >= [self.pathPoints count]) {
            if (self.loopSimulation) {
                self.currentSegmentIndex = 0;
            } else {
                [self stopLocationSimulation];
                return;
            }
        }
    });
}

#pragma mark - getters

- (NSArray *)points {
    return [self.pathPoints copy];
}

#pragma mark - explicit simulation control

- (void)pauseLocationSimulation {
    self.paused = YES;
    self.simulating  = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TULocationPoolDidStopSimulation object:self];
    });
}

- (void)stopLocationSimulation {
    [self pauseLocationSimulation];
    self.currentSegmentIndex = TUNoSelectedSegmentIndex;
}

- (void)resumeLocationSimulation {
    self.paused = NO;
    self.simulating = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TULocationPoolDidStartSimulation object:self];
    });

    [self moveToNextLocation];
}

- (void)startLocationSimulation {
    self.currentSegmentIndex = TUNoSelectedSegmentIndex;
    
    [self resumeLocationSimulation];
}

- (FGUPathPoint *)currentPathPoint {
    if (self.paused || !self.simulating) {
        return nil;
    }
    
    if (self.currentSegmentIndex == TUNoSelectedSegmentIndex) {
        return nil;
    }
    
    NSAssert(self.currentSegmentIndex < [self.pathPoints count], @"Invalid currentSegmentIndex = %lu, points count = %lu",
             (unsigned long)self.currentSegmentIndex, (unsigned long)[self.pathPoints count]);
    
    return [self.pathPoints objectAtIndex:self.currentSegmentIndex];
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (self.simulating) {
        return;
    }
    
    CLLocation *newLocation = locations.count > 0 ? [locations lastObject] : nil;
    
    [self setSimulatedLocationToLocation:newLocation fromLocation:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self setSimulatedLocationToLocation:nil fromLocation:nil];
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt32:(int32_t)_currentSegmentIndex forKey:TUCurrentSegmentSettingsKey];
    [aCoder encodeBool:self.paused forKey:TUPausedSettingsKey];
    [aCoder encodeBool:self.simulating forKey:TUSimulatingSettingsKey];
    [aCoder encodeInt32:self.currentSimulationMode forKey:TUSimulatingModeSettingsKey];
    [aCoder encodeBool:self.loopSimulation forKey:TULoopSettingsKey];
    [aCoder encodeDouble:self.timescale forKey:TUTimescaleSettingsKey];
    [aCoder encodeObject:self.pathPoints ?: @[] forKey:TUSegmentsArraySettingsKey];
}

#pragma mark hidden

- (void)_applicationWillTeminate:(NSNotification *)notification {
    [self _saveCurrentState];
}

- (void)_applicationDidEnterBackgroundNotification:(NSNotification *)notification {
    [self _saveCurrentState];
}

- (void)_saveCurrentState {
    NSMutableData *data = [NSMutableData new];
    NSKeyedArchiver *arch = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [self encodeWithCoder:arch];
    [arch finishEncoding];
    
    if (data.length > 0) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:data forKey:TULocationSettingsKey];
        [userDefaults synchronize];
    }
}

@end

#endif
