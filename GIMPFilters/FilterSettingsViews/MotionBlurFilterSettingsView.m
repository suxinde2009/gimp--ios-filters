//
//  MotionBlurFilterSettingsView.m
//  FiltersTest
//
//  Created by maxim on 29.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import "MotionBlurFilterSettingsView.h"

@implementation MotionBlurFilterSettingsView

- (id)initWithFrame:(CGRect)frame width:(int)width andHeight:(int)height {
	if (CGRectEqualToRect(frame, CGRectZero)) {
		frame = CGRectMake(0.0, 0.0, 320.0, 250.0);
	}	
	CGFloat w = frame.size.width;
	CGFloat padding = 10.;

    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		
		imgWidth = width;
		imgHeight = height;
		
		motionTypeControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Linear", @"Zoom", @"Radial", nil]];
		CGRect rect = CGRectMake(padding, 10.0, w - padding * 2, 30.0);
		motionTypeControl.frame = rect;
		motionTypeControl.segmentedControlStyle = UISegmentedControlStyleBar;
		motionTypeControl.selectedSegmentIndex = 0;
		[motionTypeControl addTarget:self action:@selector(motionTypeControlAction:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:motionTypeControl];
		
		zoomTypeControll = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Outward", @"Inward", nil]];
		rect = CGRectMake(145.0, 190.0, 155, 35.0);
		zoomTypeControll.frame = rect;
		zoomTypeControll.segmentedControlStyle = UISegmentedControlStyleBar;
		zoomTypeControll.selectedSegmentIndex = 0;
		[zoomTypeControll addTarget:self action:@selector(zoomTypeControllAction:) forControlEvents:UIControlEventValueChanged];
		zoomTypeControll.hidden = YES;
		[self addSubview:zoomTypeControll];
		
		
		lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 50.0, 200.0, 20.0)];
		lengthLabel.backgroundColor = [UIColor clearColor];
		lengthLabel.textColor = [UIColor whiteColor];
		lengthLabel.text = @"Length:";
		[self addSubview:lengthLabel];
		
		lengthSlider = [[UISlider alloc] initWithFrame:CGRectMake(padding, 70.0, w - padding * 2, 20.0)];
		lengthSlider.minimumValue = 1;
		lengthSlider.maximumValue = 256;
		lengthSlider.value = 5;
		[lengthSlider addTarget:self action:@selector(lengthSliderAction:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:lengthSlider];
		
		angleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 100.0, 200.0, 20.0)];
		angleLabel.backgroundColor = [UIColor clearColor];
		angleLabel.textColor = [UIColor whiteColor];
		angleLabel.text = @"Angle:";
		[self addSubview:angleLabel];
		
		angleSlider = [[UISlider alloc] initWithFrame:CGRectMake(padding, 120.0, w - padding * 2, 20.0)];
		angleSlider.minimumValue = 0;
		angleSlider.maximumValue = 360;
		angleSlider.value = 10;
		[angleSlider addTarget:self action:@selector(angleSliderAction:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:angleSlider];
		
		centerLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 150.0, 100.0, 30.0)];
		centerLabel.backgroundColor = [UIColor clearColor];
		centerLabel.textColor = [UIColor whiteColor];
		centerLabel.text = @"Blur Center:";
		[self addSubview:centerLabel];
		
		centerXLabel = [[UILabel alloc] initWithFrame:CGRectMake(115.0, 150.0, 20.0, 30.0)];
		centerXLabel.backgroundColor = [UIColor clearColor];
		centerXLabel.textColor = [UIColor whiteColor];
		centerXLabel.text = @"X:";
		[self addSubview:centerXLabel];
		
		centerYLabel = [[UILabel alloc] initWithFrame:CGRectMake(215.0, 150.0, 20.0, 30.0)];
		centerYLabel.backgroundColor = [UIColor clearColor];
		centerYLabel.textColor = [UIColor whiteColor];
		centerYLabel.text = @"Y:";
		[self addSubview:centerYLabel];
		
		centerxField = [[UITextField alloc] initWithFrame:CGRectMake(145.0, 150.0, 60.0, 30.0)];
		centerxField.backgroundColor = [UIColor clearColor];
		centerxField.borderStyle = UITextBorderStyleRoundedRect;
		centerxField.returnKeyType = UIReturnKeyDefault;
		centerxField.keyboardType = UIKeyboardTypeNumberPad;
		centerxField.delegate = self;
		centerxField.text = [NSString stringWithFormat:@"%d", imgWidth / 2];
		centerxField.enabled = NO;
		[self addSubview:centerxField];
		
		centeryField = [[UITextField alloc] initWithFrame:CGRectMake(240.0, 150.0, 60.0, 30.0)];
		centeryField.backgroundColor = [UIColor clearColor];
		centeryField.borderStyle = UITextBorderStyleRoundedRect;
		centeryField.returnKeyType = UIReturnKeyDefault;
		centeryField.keyboardType = UIKeyboardTypeNumberPad;
		centeryField.delegate = self;
		centeryField.text = [NSString stringWithFormat:@"%d", imgHeight / 2];
		centeryField.enabled = NO;
		[self addSubview:centeryField];
		
		length = lengthSlider.value;
		angle = angleSlider.value;
		outward = zoomTypeControll.selectedSegmentIndex == 0 ? 1 : 0;
		motionType = motionTypeControl.selectedSegmentIndex;
    }
    return self;
}


- (void)dealloc {
	[lengthSlider release];
	[angleSlider release];
	
	[lengthLabel release];
	[angleLabel release];
	
	[centerxField release];
	[centeryField release];
	
	[centerLabel release];
	[centerXLabel release];
	[centerYLabel release];
    [super dealloc];
}


- (void)motionTypeControlAction:(id)sender {
	switch (motionTypeControl.selectedSegmentIndex) {
		case 0: {
			lengthSlider.enabled = YES;
			angleSlider.enabled = YES;
			zoomTypeControll.hidden = YES;
			centerxField.enabled = NO;
			centeryField.enabled = NO;
		} break;
		case 1: {
			lengthSlider.enabled = YES;
			angleSlider.enabled = NO;
			zoomTypeControll.hidden = NO;
			centerxField.enabled = YES;
			centeryField.enabled = YES;
		} break;
		case 2: {
			lengthSlider.enabled = NO;
			angleSlider.enabled = YES;
			zoomTypeControll.hidden = YES;
			centerxField.enabled = YES;
			centeryField.enabled = YES;
		} break;
		default:
			break;
	}
	motionType = motionTypeControl.selectedSegmentIndex;
}

- (void)zoomTypeControllAction:(id) sender {
	outward = zoomTypeControll.selectedSegmentIndex == 0 ? 1 : 0;
}

- (void)lengthSliderAction:(id)sender {
	length = lengthSlider.value;
}

- (void)angleSliderAction:(id)sender {
	angle = angleSlider.value;
}

- (NSMutableDictionary*)settingsDictionary {
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:length], @"length",
			[NSNumber numberWithInt:angle], @"angle", 
			[NSNumber numberWithInt:outward], @"outward",
			[NSNumber numberWithInt:[centerxField.text intValue]], @"centerX",
			[NSNumber numberWithInt:[centeryField.text intValue]], @"centerY",
			[NSNumber numberWithInt:motionType], @"motionType", nil];
}


#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
	if (textField == centerxField) {
		if ([newString intValue] > imgWidth) {
			textField.text = [NSString stringWithFormat:@"%d", imgWidth];
			return NO;
		}
	}
	
	if (textField == centeryField) {
		if ([newString intValue] > imgHeight) {
			textField.text = [NSString stringWithFormat:@"%d", imgHeight];
			return NO;
		}
	}
	
	return [newString length] <= 4;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[centerxField resignFirstResponder];
	[centeryField resignFirstResponder];
}
@end
