//
//  MotionBlurFilter.h
//  FiltersTest
//
//  Created by maxim on 20.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FilterImage.h"

@interface MotionBlurFilter : NSObject {
	BOOL isCancel;
	BOOL preview;
}

@property BOOL isCancel;

+ (MotionBlurFilter*)sharedFilter;

- (FilterImage*)mblur_linear:(FilterImage*)input;
- (FilterImage*)mblur_radial:(FilterImage*)input;
- (FilterImage*)mblur_zoom:(FilterImage*)input;
@end
