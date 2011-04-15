//
//  FiltersCore.m
//  FiltersTest
//
//  Created by maxim on 17.02.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import "FiltersCore.h"
#import "Definitions.h"

#import "BWFilter.h"
#import "EmbossFilter.h"
#import "SharpenFilter.h"
#import "SoftGlowFilter.h"
#import "GlassTileFilter.h"
#import "MotionBlurFilter.h"
#import "RedEyeRemovalFilter.h"
#import "GaussSelectiveBlurFilter.h"


@implementation FiltersCore

+ (NSString*)getFilterNameById:(int)filterID {
	NSString *filterName;
	switch (filterID) {
		case FiltersBW:
			filterName = @"Black & White";
			break;
		case FiltersRedEyeRemoval:
			filterName = @"Red Eye Removal";
			break;
		case FiltersSharpen:
			filterName = @"Sharpen";
			break;
		case FiltersEmboss:
			filterName = @"Emboss";
			break;
		case FiltersSoftGlow:
			filterName = @"Soft Glow";
			break;
		case FiltersGlassTile:
			filterName = @"Glass Tile";
			break;
		case FiltersMotionBlur:
			filterName = @"Motion Blur";
			break;
		case FiltersGaussSelectiveBlur:
			filterName = @"Gauss Selective Blur";
			break;
		default:
			filterName = @"";
			break;
	}
	return filterName;
}

+ (id)getFilterByID:(int)filterID {
//	id filter;
	switch (filterID) {
		case FiltersBW:
			return [BWFilter sharedFilter];
			break;
		case FiltersRedEyeRemoval:
			return [RedEyeRemovalFilter sharedFilter];
			break;
		case FiltersSharpen:
			return [SharpenFilter sharedFilter];
			break;
		case FiltersEmboss:
			return [EmbossFilter sharedFilter];
			break;
		case FiltersSoftGlow:
			return [SoftGlowFilter sharedFilter];
			break;
		case FiltersGlassTile:
			return [GlassTileFilter sharedFilter];
			break;
		case FiltersMotionBlur:
			return [MotionBlurFilter sharedFilter];
			break;
		case FiltersGaussSelectiveBlur:
			return [GaussSelectiveBlurFilter sharedFilter];
			break;
		default:
			return nil;
			break;
	}
//	return filter;
}
@end
