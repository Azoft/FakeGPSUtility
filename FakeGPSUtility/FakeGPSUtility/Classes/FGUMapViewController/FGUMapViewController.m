//
//  TUViewController.m
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author: Timur Kuchkarov
//  Responcible: Nikolay July
//

#import "FGUMapViewController.h"
#import "FGUMapItemCell.h"
#import "FGUFakeLocationPool.h"
#import "FGUConstants.h"
#import "FGULocationManager.h"
#import "FGUPathPoint.h"

#if defined(USE_TEST_UTILITIES) && USE_TEST_UTILITIES

BOOL CLLocationCoordinate2DIsEmpty(CLLocationCoordinate2D coordinate) {
    return coordinate.latitude == 0. && coordinate.longitude == 0.;
}

CLLocationCoordinate2D CLLocationCoordinate2DEmpty() {
    return CLLocationCoordinate2DMake(0., 0.);
}

@interface FGUMapViewController ()

@property (nonatomic) CLLocationCoordinate2D startPathCoordinate;
@property (nonatomic) CLLocationCoordinate2D endPathCoordinate;
@property (nonatomic, strong) MKPointAnnotation *startPathAnnotation;
@property (nonatomic, strong) MKPointAnnotation *endPathAnnotation;

@property (nonatomic, strong) MKDirections *directions;
@property (nonatomic, strong) MKRoute *currentRoute;

@end

@implementation FGUMapViewController

#pragma mark - init/dealloc & view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_longPressAction:)];
    longPress.minimumPressDuration = LONG_PRESS_DURATION;
    [self.mapView addGestureRecognizer:longPress];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (SharedFakeLocationPool.currentSimulationMode != FGULocationManagerSimModeRouteFromMKRoute) {
        [self _resetRoute];
    }
    
    [self _updateMap];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_segmentsOnFakePoolLocationsWereChanged:) name:TULocationPoolDidUpdatePathPointsNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TULocationPoolDidUpdatePathPointsNotification object:nil];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if (self.currentRoute) {
        if ([overlay isKindOfClass:[MKPolyline class]]) {
            MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:self.currentRoute.polyline];
            routeRenderer.strokeColor = [UIColor blueColor];
            return routeRenderer;
        }
    }
    return nil;
}

#pragma mark hidden

- (void)setDirections:(MKDirections *)directions {
    [_directions cancel];
    _directions = directions;
}

- (void)setCurrentRoute:(MKRoute *)currentRoute {
    [self.mapView removeOverlay:_currentRoute.polyline];
    _currentRoute = currentRoute;
    if (_currentRoute) {
        [self.mapView addOverlay:_currentRoute.polyline];
    }
}

#define ADD_UPDATE_POINT_ANNOTATION(ann, coordinate) \
MKPointAnnotation *annotation = ann; \
[self addOrUpdateAnnotation:&annotation forCoordinate:coordinate]; \
ann = annotation;

- (void)setStartPathCoordinate:(CLLocationCoordinate2D)startPathCoordinate {
    _startPathCoordinate = startPathCoordinate;
    
    ADD_UPDATE_POINT_ANNOTATION(self.startPathAnnotation, startPathCoordinate);
}

- (void)setEndPathCoordinate:(CLLocationCoordinate2D)endPathCoordinate {
    _endPathCoordinate = endPathCoordinate;
    
    ADD_UPDATE_POINT_ANNOTATION(self.endPathAnnotation, endPathCoordinate);
}

- (void)addOrUpdateAnnotation:(MKPointAnnotation **)anotation forCoordinate:(CLLocationCoordinate2D)coordinate {
    MKPointAnnotation *pointAnnotation = *anotation;
    if (CLLocationCoordinate2DIsEmpty(coordinate)) {
        if (pointAnnotation) {
            [self.mapView removeAnnotation:pointAnnotation];
        }
    } else if (!pointAnnotation) {
        pointAnnotation = [[MKPointAnnotation alloc] init];
        [self.mapView addAnnotation:pointAnnotation];
        *anotation = pointAnnotation;
    }
    pointAnnotation.coordinate = coordinate;
}

- (void)_resetRoute {
    self.startPathCoordinate = CLLocationCoordinate2DEmpty();
    self.endPathCoordinate = CLLocationCoordinate2DEmpty();
    self.currentRoute = nil;
    [self.directions cancel];
    self.directions = nil;
}

- (void)_loadRoute {
    MKDirectionsRequest *directionRequest = [[MKDirectionsRequest alloc] init];
    [directionRequest setSource:[[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:self.startPathCoordinate
                                                                                           addressDictionary:nil]]];
    [directionRequest setDestination:[[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:self.endPathCoordinate
                                                                                                addressDictionary:nil]]];
    
    __weak __typeof(self) this = self;
    
    self.directions = [[MKDirections alloc] initWithRequest:directionRequest];
    [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        this.currentRoute = [response.routes lastObject];
        if (error || !this.currentRoute) {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                       message:error ? [error localizedDescription] : @"Could not calculate direction"
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil] show];
        }
        CLLocationCoordinate2D *cc = malloc(sizeof(CLLocationCoordinate2D) * this.currentRoute.polyline.pointCount);
        [this.currentRoute.polyline getCoordinates:cc range:NSMakeRange(0, this.currentRoute.polyline.pointCount)];
        
        [SharedFakeLocationPool beginUpdatePath];
        for (int i = 0; i < this.currentRoute.polyline.pointCount; i++) {
            CLLocationCoordinate2D point = cc[i];
            [SharedFakeLocationPool addLocationToPath:[[CLLocation alloc] initWithLatitude:point.latitude longitude:point.longitude]];
        }
        [SharedFakeLocationPool finishUpdatePath];
        free(cc);
    }];
}

- (void)_longPressAction:(UILongPressGestureRecognizer *)longPressRecognizer {
    if (longPressRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint locationPoint = [longPressRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D cooedinate = [self.mapView convertPoint:locationPoint toCoordinateFromView:self.mapView];
    
    if (SharedFakeLocationPool.currentSimulationMode == FGULocationManagerSimModeRouteFromMKRoute) {
        if (!CLLocationCoordinate2DIsEmpty(self.startPathCoordinate)) {
            if (CLLocationCoordinate2DIsEmpty(self.endPathCoordinate)) {
                self.endPathCoordinate = cooedinate;
            } else {
                self.startPathCoordinate = self.endPathCoordinate;
                self.endPathCoordinate = cooedinate;
            }
            [self _loadRoute];
        } else {
            self.startPathCoordinate = cooedinate;
        }
    } else {
        CLLocation *newlocation = [[CLLocation alloc] initWithLatitude:cooedinate.latitude longitude:cooedinate.longitude];
        [SharedFakeLocationPool addLocationToPath:newlocation];
    }

}

- (void)_segmentsOnFakePoolLocationsWereChanged:(NSNotification *)notification {
    [self _updateMap];
}

- (void)_updateMap {
    if ([NSThread isMainThread] == NO) {
        LOG_ERROR(@"Must be called only on main thread");
        return;
    }
    
    for (id<MKAnnotation> annotatin in _mapView.annotations) {
        if ([annotatin isKindOfClass:[MKUserLocation class]] || annotatin == self.startPathAnnotation || annotatin == self.endPathAnnotation) {
            continue;
        }
        
        [self.mapView removeAnnotation:annotatin];
    }

    if (SharedFakeLocationPool.currentSimulationMode != FGULocationManagerSimModeRouteFromMKRoute &&
        SharedFakeLocationPool.currentSimulationMode != FGULocationManagerSimModeRouteFromFile) {
        NSArray *segmentsArray = SharedFakeLocationPool.points;
        for (NSUInteger i = 0; i < segmentsArray.count; i++) {
            FGUPathPoint *currentPoint = [segmentsArray objectAtIndex:i];
            MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
            pointAnnotation.coordinate = currentPoint.coordinate;
            [self.mapView addAnnotation:pointAnnotation];
        }
    }
}

@end

#endif
