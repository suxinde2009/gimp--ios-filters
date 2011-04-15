//
//  EmbossFilterSettingsView.h
//  FiltersTest
//
//  Created by maxim on 27.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettisngsViewBase.h"

@interface EmbossFilterSettingsView : SettisngsViewBase {
	double  azimuth; // азимут 0 - 360
	double  elevation; // возвышение 0 - 180
	int   depth; // глубина - 1 - 100
	int   embossp; // 0, 1 - рельеф, барельеф
	
	UISegmentedControl *functionTypeControl; // Emboss or Bumpmap
	
	UISlider *azimuthSlider;
	UISlider *elevationSlider;
	UISlider *depthSlider;
	
	UILabel *azimuthLabel;
	UILabel *elevationLabel;
	UILabel *depthLabel;
}

@end
