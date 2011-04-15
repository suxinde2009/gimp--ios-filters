//
//  MotionBlurFilterSettingsView.h
//  FiltersTest
//
//  Created by maxim on 29.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettisngsViewBase.h"

@interface MotionBlurFilterSettingsView : SettisngsViewBase <UITextFieldDelegate> {

	int length;
	int angle;
	int outward;
	int motionType;
	
 	int imgWidth;
	int imgHeight;
	
	UISegmentedControl *motionTypeControl;
	UISegmentedControl *zoomTypeControll;
	
	UISlider *lengthSlider;
	UISlider *angleSlider;
	
	UILabel *lengthLabel;
	UILabel *angleLabel;
	
	UITextField *centerxField;
	UITextField *centeryField;
	
	UILabel *centerLabel;
	UILabel *centerXLabel;
	UILabel *centerYLabel;
}

- (id)initWithFrame:(CGRect)frame width:(int)width andHeight:(int)height;

@end
