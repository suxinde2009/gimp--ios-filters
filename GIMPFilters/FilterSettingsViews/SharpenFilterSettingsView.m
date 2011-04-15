//
//  SharpenFilterSettingsView.m
//  FiltersTest
//
//  Created by maxim on 28.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import "SharpenFilterSettingsView.h"


@implementation SharpenFilterSettingsView


- (id)initWithFrame:(CGRect)frame {
	if (CGRectEqualToRect(frame, CGRectZero)) {
		frame = CGRectMake(0.0, 0.0, 320.0, 110.0);
	}
	CGFloat w = frame.size.width;
	CGFloat padding = 10.;

    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		
		sharpenPercentLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 10.0, 200.0, 20.0)];
		sharpenPercentLabel.backgroundColor = [UIColor clearColor];
		sharpenPercentLabel.textColor = [UIColor whiteColor];
		sharpenPercentLabel.text = @"Sharpen Percent:";
		[self addSubview:sharpenPercentLabel];
				
		sharpenPercentSlider = [[UISlider alloc] initWithFrame:CGRectMake(padding, 30.0, w - padding * 2, 20)];
		sharpenPercentSlider.minimumValue = 0;
		sharpenPercentSlider.maximumValue = 100;
		sharpenPercentSlider.value = 10;
		[sharpenPercentSlider addTarget:self action:@selector(sharpenPercentSliderAction:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:sharpenPercentSlider];
		
		sharpenPercent = sharpenPercentSlider.value;
    }
    return self;
}


- (void)dealloc {
	[sharpenPercentSlider release];
	[sharpenPercentLabel release];
    [super dealloc];
}

- (void)sharpenPercentSliderAction:(id)sender {
	sharpenPercent = sharpenPercentSlider.value;
}

- (NSMutableDictionary*)settingsDictionary {
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:sharpenPercent], @"sharpenPercent", nil];
}


@end
