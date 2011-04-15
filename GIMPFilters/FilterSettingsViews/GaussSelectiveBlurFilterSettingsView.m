//
//  GaussSelectiveBlurFilterSettingsView.m
//  FiltersTest
//
//  Created by maxim on 02.02.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import "GaussSelectiveBlurFilterSettingsView.h"


@implementation GaussSelectiveBlurFilterSettingsView


- (id)initWithFrame:(CGRect)frame {
	if (CGRectEqualToRect(frame, CGRectZero)) {
		frame = CGRectMake(0.0, 0.0, 320.0, 160.0);
	}
	CGFloat w = frame.size.width;
	CGFloat padding = 10.;
	
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		
		radiusLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 10.0, 200.0, 20.0)];
		radiusLabel.backgroundColor = [UIColor clearColor];
		radiusLabel.textColor = [UIColor whiteColor];
		radiusLabel.text = @"Radius:";
		[self addSubview:radiusLabel];
		
		radiusSlider = [[UISlider alloc] initWithFrame:CGRectMake(padding, 30.0, w - padding * 2, 20.0)];
		radiusSlider.minimumValue = 1;
		radiusSlider.maximumValue = 25;
		radiusSlider.value = 5.0;
		[radiusSlider addTarget:self action:@selector(radiusSliderAction:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:radiusSlider];
		
		maxDeltaLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 60.0, 200.0, 20.0)];
		maxDeltaLabel.backgroundColor = [UIColor clearColor];
		maxDeltaLabel.textColor = [UIColor whiteColor];
		maxDeltaLabel.text = @"Max Delta:";
		[self addSubview:maxDeltaLabel];
		
		maxDeltaSlider = [[UISlider alloc] initWithFrame:CGRectMake(padding, 80.0, w - padding * 2, 20.0)];
		maxDeltaSlider.minimumValue = 0;
		maxDeltaSlider.maximumValue = 255;
		maxDeltaSlider.value = 50;
		[maxDeltaSlider addTarget:self action:@selector(maxDeltaSliderAction:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:maxDeltaSlider];
		
		radius = radiusSlider.value;
		max_delta = maxDeltaSlider.value;		
    }
    return self;
}


- (void)dealloc {
	[radiusSlider release];
	[maxDeltaSlider release];
	
	[radiusLabel release];
	[maxDeltaLabel release];
    [super dealloc];
}


- (void)radiusSliderAction:(id)sender {
	radius = radiusSlider.value;
}

- (void)maxDeltaSliderAction:(id)sender {
	max_delta = maxDeltaSlider.value;
}

- (NSMutableDictionary*)settingsDictionary {
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:radius], @"radius", 
			[NSNumber numberWithInt:max_delta], @"maxDelta", nil];
}


@end
