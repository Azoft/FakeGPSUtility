//
//  FGULocationManagerInternal.m
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author: Nikolay July
//  Responcible: Nikolay July
//

#import <objc/runtime.h>

#import "FGULocationManagerInternal.h"
#import "FGURealLocationManager.h"
#import "FGUFakeLocationPool.h"

#if defined(USE_TEST_UTILITIES) && USE_TEST_UTILITIES

@implementation FGULocationManagerInternal

- (id)init {
    self = [super init];
    
    if (self) {
         _realLocationManager = [[FGURealLocationManager alloc] init];
         _realLocationManager.delegate = self;
    }
    
    return self;
}

#pragma mark CLLocationManagerDelegate
/* for iOS 5*/
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self performRealDelegateSelector:_cmd withObjects:@[self.fakeLocationManager, newLocation, oldLocation]];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self performRealDelegateSelector:_cmd withObjects:@[self.fakeLocationManager, locations]];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self performRealDelegateSelector:_cmd withObjects:@[self.fakeLocationManager, error]];
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    [self performRealDelegateSelector:_cmd withObjects:@[self.fakeLocationManager]];
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    [self performRealDelegateSelector:_cmd withObjects:@[self.fakeLocationManager]];
}

- (void)performRealDelegateSelector:(SEL)aSelector withObjects:(NSArray *)objects {
    if (SharedFakeLocationPool.isSimulating || self.locationUpdating == NO) {
        return;
    }
    
    if ([self.realManagerDelegate respondsToSelector:aSelector] == NO) {
        return;
    }
    
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[(id)self.realManagerDelegate methodSignatureForSelector:aSelector]];
    [inv setTarget:self.realManagerDelegate];
    [inv setSelector:aSelector];
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [inv setArgument:&(obj) atIndex:idx + 2];
    }];
    [inv invoke];
}

#pragma mark NSObject

- (BOOL)respondsToSelector:(SEL)aSelector {
    return class_respondsToSelector([self class], aSelector) ||
    (self.realManagerDelegate != nil && [self.realManagerDelegate respondsToSelector:aSelector]);
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.realManagerDelegate;
}

@end

#endif
