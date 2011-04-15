//
//  GaussSelectiveBlurFilterSettingsView.h
//  FiltersTest
//
//  Created by maxim on 02.02.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettisngsViewBase.h"

@interface GaussSelectiveBlurFilterSettingsView : SettisngsViewBase {
	int radius;
	int max_delta;
	
	UISlider *radiusSlider;
	UISlider *maxDeltaSlider;
	
	UILabel *radiusLabel;
	UILabel *maxDeltaLabel;
}

@end
