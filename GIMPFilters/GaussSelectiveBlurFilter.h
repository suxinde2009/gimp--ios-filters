//
//  GaussSelectiveBlurFilter.h
//  FiltersTest
//
//  Created by maxim on 02.02.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FilterImage;
@interface GaussSelectiveBlurFilter : NSObject {
	BOOL isCancel;
	BOOL preview;
}

@property BOOL isCancel;

+ (GaussSelectiveBlurFilter*)sharedFilter;

- (FilterImage*)selectiveGaussBlurWithImage:(FilterImage*)input;
@end
