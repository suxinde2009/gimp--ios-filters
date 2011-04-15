//
//  EmbossFilterSettingsView.m
//  FiltersTest
//
//  Created by maxim on 27.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import "EmbossFilterSettingsView.h"

#import "EmbossFilter.h"


@implementation EmbossFilterSettingsView


- (id)initWithFrame:(CGRect)frame {
	if (CGRectEqualToRect(frame, CGRectZero)) {
		frame = CGRectMake(0.0, 0.0, 320.0, 250.0);
	}
	CGFloat w = frame.size.width;
	CGFloat padding = 10., bottomPadding = 10.;
	
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		functionTypeControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Emboss", @"Bumpmap", nil]];
		CGRect rect = CGRectMake(padding, bottomPadding, w - padding * 2., 30.0);
		functionTypeControl.frame = rect;
		functionTypeControl.segmentedControlStyle = UISegmentedControlStyleBar;
		functionTypeControl.selectedSegmentIndex = 0;
		[functionTypeControl addTarget:self action:@selector(functionTypeControlAction:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:functionTypeControl];
		
		azimuthLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 50.0, 100.0, 20.0)];
		azimuthLabel.backgroundColor = [UIColor clearColor];
		azimuthLabel.textColor = [UIColor whiteColor];
		azimuthLabel.text = @"Azimuth:";
		[self addSubview:azimuthLabel];
		
		azimuthSlider = [[UISlider alloc] initWithFrame:CGRectMake(padding, 70.0, w - padding * 2., 20)];
		azimuthSlider.minimumValue = 0.0;
		azimuthSlider.maximumValue = 360.0;
		azimuthSlider.value = 30.0;
		[azimuthSlider addTarget:self action:@selector(azimuthSliderAction:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:azimuthSlider];

		elevationLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 100.0, 100.0, 20.0)];
		elevationLabel.backgroundColor = [UIColor clearColor];
		elevationLabel.textColor = [UIColor whiteColor];
		elevationLabel.text = @"Elevation:";
		[self addSubview:elevationLabel];

		elevationSlider = [[UISlider alloc] initWithFrame:CGRectMake(padding, 120.0, w - padding * 2., 20)];
		elevationSlider.minimumValue = 0.0;
		elevationSlider.maximumValue = 180.0;
		elevationSlider.value = 45.0;
		[elevationSlider addTarget:self action:@selector(elevationSliderAction:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:elevationSlider];
		
		depthLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 150.0, 100.0, 20.0)];
		depthLabel.backgroundColor = [UIColor clearColor];
		depthLabel.textColor = [UIColor whiteColor];
		depthLabel.text = @"Depth:";
		[self addSubview:depthLabel];
		
		
		depthSlider = [[UISlider alloc] initWithFrame:CGRectMake(padding, 170.0, w - padding * 2., 20)];
		depthSlider.minimumValue = 1.0;
		depthSlider.maximumValue = 100;
		depthSlider.value = 20.0;
		[depthSlider addTarget:self action:@selector(depthSliderAction:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:depthSlider];
		
		azimuth = azimuthSlider.value;
		elevation = elevationSlider.value;
		depth = depthSlider.value;
		embossp = functionTypeControl.selectedSegmentIndex == 0 ? 1 : 0;
	}
    return self;
}


- (void)dealloc {
	[functionTypeControl release];
	
	[azimuthSlider release];
	[elevationSlider release];
	[depthSlider release];
	
	[azimuthLabel release];
	[elevationLabel release];
	[depthLabel release];
    [super dealloc];
}


#pragma mark -
#pragma mark Actions


- (void)functionTypeControlAction:(id)sender {
	embossp = functionTypeControl.selectedSegmentIndex == 0 ? 1 : 0;
}


- (void)azimuthSliderAction:(id)sender {
	azimuth = azimuthSlider.value;
}


- (void)elevationSliderAction:(id)sender {
	elevation = elevationSlider.value;
}


- (void)depthSliderAction:(id)sender {
	depth = depthSlider.value;
}


- (NSMutableDictionary*)settingsDictionary {
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithDouble:azimuth], @"azimuth",
			[NSNumber numberWithDouble:elevation], @"elevation", 
			[NSNumber numberWithInt:depth], @"depth", 
			[NSNumber numberWithInt:embossp], @"embossp", nil];
}


@end
