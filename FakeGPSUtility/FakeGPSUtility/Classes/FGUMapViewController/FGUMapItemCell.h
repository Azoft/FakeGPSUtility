//
//  FGUMapItemCell.h
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

#if defined(USE_TEST_UTILITIES) && USE_TEST_UTILITIES

@interface FGUMapItemCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *coordinateLabel;
@property (nonatomic, retain) IBOutlet UILabel *travelTimeLabel;

@end

#endif
