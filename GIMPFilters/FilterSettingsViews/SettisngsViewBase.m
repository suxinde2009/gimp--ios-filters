//
//  SettisngsViewBase.m
//  FiltersTest
//
//  Created by maxim on 03.02.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import "SettisngsViewBase.h"


@implementation SettisngsViewBase


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		
		CGFloat padding = 10., buttonW = 75.;
		CGFloat buttonX = frame.size.width / 2. - (buttonW * 2 + padding) / 2.;
		
		okButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		okButton.frame = CGRectMake(buttonX, frame.size.height - 35. - padding, buttonW, 35.0);
		[okButton setTitle:@"OK" forState:UIControlStateNormal];
		[okButton addTarget:self action:@selector(okButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:okButton];
		
		cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		cancelButton.frame = CGRectMake(buttonX + buttonW + padding, frame.size.height - 35. - padding, buttonW, 35.0);
		[cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
		[cancelButton addTarget:self action:@selector(cancelButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:cancelButton];
	}
    return self;
}


- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	CGFloat radius = 10;
	
    CGFloat minx = CGRectGetMinX(rect);
    CGFloat midx = CGRectGetMidX(rect);
    CGFloat maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect);
    CGFloat midy = CGRectGetMidY(rect);
    CGFloat maxy = CGRectGetMaxY(rect);
	
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    CGContextClosePath(context);
	
	CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:.0 alpha:.8] CGColor]);
	CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextSetLineWidth(context, 1.);
    CGContextDrawPath(context, kCGPathFill);
	
	CGContextRestoreGState(context);
}


- (void)dealloc {
    [super dealloc];
}

- (void)setTarget:(id)trg andAction:(SEL)act {
	target = trg;
	action = act;
}


- (NSMutableDictionary*)settingsDictionary {
	return [NSMutableDictionary dictionary];
}


- (void) dissapear {
	[UIView animateWithDuration:.3
					 animations:^(void) {
						 self.alpha = 0.;
					 } 
					 completion:^(BOOL finished) {
						 if (finished) {
							 [self removeFromSuperview];
						 }
					 }];	
}


- (void)okButtonTouched:(id)sender {
	if (target != nil) {
		[target performSelector:action withObject:[self settingsDictionary]];
	}
	[self dissapear];
}


- (void)cancelButtonTouched:(id)sender {
	[self dissapear];
}


@end
