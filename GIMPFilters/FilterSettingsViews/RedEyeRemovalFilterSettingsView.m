//
//  RedEyeRemovalFilterSettingsView.m
//  FiltersTest
//
//  Created by maxim on 01.02.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import "RedEyeRemovalFilterSettingsView.h"


@implementation RedEyeRemovalFilterSettingsView


- (id)initWithFrame:(CGRect)frame {
	if (CGRectEqualToRect(frame, CGRectZero)) {
		frame = CGRectMake(0.0, 0.0, 320.0, 110.0);
	}
	CGFloat w = frame.size.width;
	CGFloat padding = 10.;

    if ((self = [super initWithFrame:frame])) {
        // Initialization code

		thresholdLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 10.0, 200.0, 20.0)];
		thresholdLabel.backgroundColor = [UIColor clearColor];
		thresholdLabel.textColor = [UIColor whiteColor];
		thresholdLabel.text = @"Threshold:";
		[self addSubview:thresholdLabel];
		
		thresholdSlider = [[UISlider alloc] initWithFrame:CGRectMake(padding, 30.0, w - padding * 2, 20.0)];
		thresholdSlider.minimumValue = 0;
		thresholdSlider.maximumValue = 100;
		thresholdSlider.value = 50;
		[thresholdSlider addTarget:self action:@selector(thresholdSliderAction:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:thresholdSlider];
		
		threshold = thresholdSlider.value;
    }
    return self;
}


- (void)dealloc {
	[thresholdLabel release];
	[thresholdSlider release];
    [super dealloc];
}


- (void)thresholdSliderAction:(id)sender {
	threshold = thresholdSlider.value;
}

- (NSMutableDictionary*)settingsDictionary {
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:threshold], @"threshold", nil];
}


@end
