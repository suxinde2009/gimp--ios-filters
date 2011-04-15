//
//  SharpenFilterSettingsView.h
//  FiltersTest
//
//  Created by maxim on 28.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettisngsViewBase.h"

@interface SharpenFilterSettingsView : SettisngsViewBase {
	int sharpenPercent;
	
	UISlider *sharpenPercentSlider;
	
	UILabel *sharpenPercentLabel;
}

@end
