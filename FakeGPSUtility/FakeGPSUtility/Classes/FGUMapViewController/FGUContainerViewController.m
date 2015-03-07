//
//  FGUContainerViewController.m
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author: Nikolay July
//  Responcible: Nikolay July
//

#import "FGUContainerViewController.h"

#import "FGUMapViewController.h"
#import "FGUPathTableViewController.h"
#import "FGUSettingsViewController.h"
#import "FGUFakeLocationPool.h"

#if defined(USE_TEST_UTILITIES) && USE_TEST_UTILITIES

typedef enum {
    FGUPresentedControllerTypeMap = 0,
    FGUPresentedControllerTypePathTable,
    FGUPresentedControllerTypeSettings,
    FGUPresentedControllerTypeNone
} FGUPresentedControllerType;

@interface FGUContainerViewController ()

@property (nonatomic) FGUPresentedControllerType currentControllerType;

@property(nonatomic, weak) IBOutlet UIView *containerView;

@property(nonatomic, strong) IBOutlet FGUMapViewController *mapViewController;
@property(nonatomic, strong) IBOutlet FGUSettingsViewController *settingsViewController;
@property(nonatomic, strong) IBOutlet FGUPathTableViewController *pathTableViewController;

@end

@implementation FGUContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentControllerType = FGUPresentedControllerTypeNone;
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeBottom;
    }
    
    self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                                                             target:self
                                                                                             action:@selector(onPlayTap:)],
                                               [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                             target:self
                                                                                             action:@selector(onStopTap:)]];
    self.navigationItem.leftItemsSupplementBackButton = YES;
    [self refreshPlayButton];    
    [self _presentController:FGUPresentedControllerTypeMap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [SharedFakeLocationPool addObserver:self forKeyPath:@"paused" options:NSKeyValueObservingOptionNew context:nil];
    [SharedFakeLocationPool addObserver:self forKeyPath:@"simulating" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [SharedFakeLocationPool removeObserver:self forKeyPath:@"paused"];
    [SharedFakeLocationPool removeObserver:self forKeyPath:@"simulating"];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"paused"] || [keyPath isEqualToString:@"simulating"]) {
      SAFE_MAIN_THREAD_EXECUTION({
        [self refreshPlayButton];
      });

    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)refreshPlayButton {
    UIBarButtonItem *newItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:SharedFakeLocationPool.paused ? UIBarButtonSystemItemPlay : UIBarButtonSystemItemPause
                                                                             target:self
                                                                             action:@selector(onPlayTap:)];
    NSMutableArray *items = [self.navigationItem.leftBarButtonItems mutableCopy];
    [items replaceObjectAtIndex:0 withObject:newItem];
    [self.navigationItem setLeftBarButtonItems:[items copy] animated:NO];
}

- (void)onPlayTap:(id)sender {
    if(SharedFakeLocationPool.paused) {
        [SharedFakeLocationPool resumeLocationSimulation];
    } else {
        [SharedFakeLocationPool pauseLocationSimulation];
    }
}

- (void)onStopTap:(id)sender {
    [SharedFakeLocationPool stopLocationSimulation];
}

#pragma mark actions

- (IBAction)viewSwitcherChanged:(UISegmentedControl *)sender {
    [self _presentController:(int)sender.selectedSegmentIndex];
}

#pragma mark hidden

- (void)_presentController:(FGUPresentedControllerType)newControllerController {
    if (self.currentControllerType == newControllerController) {
        // it is already there
        return;
    }
    UIViewController *currentlyPresentedViewController = [self _viewcontrollerWithType:self.currentControllerType];

    if (currentlyPresentedViewController != nil) {
        [currentlyPresentedViewController willMoveToParentViewController:nil];
        [currentlyPresentedViewController.view removeFromSuperview];
        [currentlyPresentedViewController removeFromParentViewController];
    }
    
    self.currentControllerType = newControllerController;
    UIViewController *newPresentedViewController = [self _viewcontrollerWithType:self.currentControllerType];
    
    [self addChildViewController:newPresentedViewController];
    newPresentedViewController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:newPresentedViewController.view];
    [newPresentedViewController didMoveToParentViewController:self];

}

- (UIViewController *)_viewcontrollerWithType:(FGUPresentedControllerType)presentedController {
    UIViewController *resViewController = nil;
    switch (presentedController) {
        case FGUPresentedControllerTypeMap: {
            resViewController = self.mapViewController;
        }
            break;
        case FGUPresentedControllerTypePathTable: {
            resViewController = self.pathTableViewController;
        }
            break;
        case FGUPresentedControllerTypeSettings: {
            resViewController = self.settingsViewController;
        }
            break;
            
        default:
            break;
    }
    
    return resViewController;
}

@end

#endif