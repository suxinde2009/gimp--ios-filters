//
//  GlassTileFilterSettingsView.m
//  FiltersTest
//
//  Created by maxim on 28.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import "GlassTileFilterSettingsView.h"


@implementation GlassTileFilterSettingsView


- (id)initWithFrame:(CGRect)frame {
	if (CGRectEqualToRect(frame, CGRectZero)) {
		frame = CGRectMake(0.0, 0.0, 320.0, 160.0);
	}	
	CGFloat w = frame.size.width;
	CGFloat padding = 10.;

    if ((self = [super initWithFrame:frame])) {
        // Initialization code

		xblockLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 10.0, 200.0, 20.0)];
		xblockLabel.backgroundColor = [UIColor clearColor];
		xblockLabel.textColor = [UIColor whiteColor];
		xblockLabel.text = @"Block Width:";
		[self addSubview:xblockLabel];
		
		xblockSlider = [[UISlider alloc] initWithFrame:CGRectMake(padding, 30.0, w - padding * 2., 20.0)];
		xblockSlider.minimumValue = 10;
		xblockSlider.maximumValue = 50;
		xblockSlider.value = 20;
		[xblockSlider addTarget:self action:@selector(xblockSliderAction:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:xblockSlider];
		
		yblockLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 60.0, 200.0, 20.0)];
		yblockLabel.backgroundColor = [UIColor clearColor];
		yblockLabel.textColor = [UIColor whiteColor];
		yblockLabel.text = @"Block Height:";
		[self addSubview:yblockLabel];
		
		yblockSlider = [[UISlider alloc] initWithFrame:CGRectMake(padding, 80.0, w - padding * 2., 20.0)];
		yblockSlider.minimumValue = 10;
		yblockSlider.maximumValue = 50;
		yblockSlider.value = 20;
		[yblockSlider addTarget:self action:@selector(yblockSliderAction:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:yblockSlider];
		
		xblock = xblockSlider.value;
		yblock = yblockSlider.value;
    }
    return self;
}


- (void)dealloc {
	[xblockSlider release];
	[yblockSlider release];
	
	[xblockLabel release];
	[yblockLabel release];
    [super dealloc];
}

- (void)xblockSliderAction:(id)sender {
	xblock = xblockSlider.value;
}

- (void)yblockSliderAction:(id)sender {
	yblock = yblockSlider.value;
}

- (NSMutableDictionary*)settingsDictionary {
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:xblock], @"xblock", 
			[NSNumber numberWithInt:yblock], @"yblock", nil];
}


@end
