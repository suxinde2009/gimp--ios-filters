//
//  SoftGlowFilterSettingsView.h
//  FiltersTest
//
//  Created by maxim on 28.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettisngsViewBase.h"

@interface SoftGlowFilterSettingsView : SettisngsViewBase {
	double glow_radius;
	double brightness;
	double sharpness;
	
	UISlider *glowRadiusSlider;
	UISlider *brightnessSlider;
	UISlider *sharpnessSlider;
	
	UILabel *glowRadiusLabel;
	UILabel *brightnessLabel;
	UILabel *sharpnessLabel;
}

@end
