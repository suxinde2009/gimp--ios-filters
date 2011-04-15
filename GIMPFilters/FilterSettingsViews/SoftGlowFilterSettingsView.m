//
//  SoftGlowFilterSettingsView.m
//  FiltersTest
//
//  Created by maxim on 28.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import "SoftGlowFilterSettingsView.h"


@implementation SoftGlowFilterSettingsView


- (id)initWithFrame:(CGRect)frame {
	if (CGRectEqualToRect(frame, CGRectZero)) {
		frame = CGRectMake(0.0, 0.0, 320.0, 210.0);
	}
	CGFloat w = frame.size.width;
	CGFloat padding = 10.;

    if ((self = [super initWithFrame:frame])) {
        // Initialization code

		glowRadiusLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 10.0, 200.0, 20.0)];
		glowRadiusLabel.backgroundColor = [UIColor clearColor];
		glowRadiusLabel.textColor = [UIColor whiteColor];
		glowRadiusLabel.text = @"Glow Radius:";
		[self addSubview:glowRadiusLabel];
		
		glowRadiusSlider = [[UISlider alloc] initWithFrame:CGRectMake(padding, 30.0, w - padding * 2, 20.0)];
		glowRadiusSlider.minimumValue = 1;
		glowRadiusSlider.maximumValue = 50;
		glowRadiusSlider.value = 10.0;
		[glowRadiusSlider addTarget:self action:@selector(glowRadiusSliderAction:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:glowRadiusSlider];
		
		brightnessLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 60.0, 200.0, 20.0)];
		brightnessLabel.backgroundColor = [UIColor clearColor];
		brightnessLabel.textColor = [UIColor whiteColor];
		brightnessLabel.text = @"Brightness:";
		[self addSubview:brightnessLabel];
		
		brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(padding, 80.0, w - padding * 2, 20.0)];
		brightnessSlider.minimumValue = 0.0;
		brightnessSlider.maximumValue = 1.00;
		brightnessSlider.value = 0.75;
		[brightnessSlider addTarget:self action:@selector(brightnessSliderAction:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:brightnessSlider];
		
		sharpnessLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 110.0, 200.0, 20.0)];
		sharpnessLabel.backgroundColor = [UIColor clearColor];
		sharpnessLabel.textColor = [UIColor whiteColor];
		sharpnessLabel.text = @"Sharpness:";
		[self addSubview:sharpnessLabel];
		
		sharpnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(padding, 130.0, w - padding * 2, 20.0)];
		sharpnessSlider.minimumValue = 0.0;
		sharpnessSlider.maximumValue = 1.0;
		sharpnessSlider.value = 0.85;
		[sharpnessSlider addTarget:self action:@selector(sharpnessSliderAction:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:sharpnessSlider];
		
		glow_radius = glowRadiusSlider.value;
		brightness = brightnessSlider.value;
		sharpness = sharpnessSlider.value;
    }
    return self;
}


- (void)dealloc {
	[glowRadiusSlider release];
	[brightnessSlider release];
	[sharpnessSlider release];
	
	[glowRadiusLabel release];
	[brightnessLabel release];
	[sharpnessLabel release];
    [super dealloc];
}

- (void)glowRadiusSliderAction:(id)sender {
	glow_radius = glowRadiusSlider.value;
}

- (void)brightnessSliderAction:(id)sender {
	brightness = brightnessSlider.value;
}

- (void)sharpnessSliderAction:(id)sender {
	sharpness = sharpnessSlider.value;
}

- (NSMutableDictionary*)settingsDictionary {
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:glow_radius], @"glowRadius",
			[NSNumber numberWithDouble:brightness], @"brightness",
			[NSNumber numberWithDouble:sharpness], @"sharpness", nil];
}


@end
