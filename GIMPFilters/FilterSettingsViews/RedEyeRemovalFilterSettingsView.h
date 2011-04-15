//
//  RedEyeRemovalFilterSettingsView.h
//  FiltersTest
//
//  Created by maxim on 01.02.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettisngsViewBase.h"

@interface RedEyeRemovalFilterSettingsView : SettisngsViewBase {
	int threshold;
	
	UISlider *thresholdSlider;
	UILabel *thresholdLabel;
}

@end
