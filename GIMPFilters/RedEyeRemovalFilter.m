//
//  RedEyeRemovalFilter.m
//  FiltersTest
//
//  Created by maxim on 14.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import "RedEyeRemovalFilter.h"
#import "FilterImage.h"
#import "Definitions.h"

@implementation RedEyeRemovalFilter

@synthesize isCancel;

#define RED_FACTOR    0.5133333
#define GREEN_FACTOR  1
#define BLUE_FACTOR   0.1933333

static int threshold = 50;

static RedEyeRemovalFilter *sharedFilter;

+ (RedEyeRemovalFilter*)sharedFilter {
	@synchronized (self) {
		if (sharedFilter == nil) {
			sharedFilter = [[self alloc] init];
		}
	}
	return sharedFilter;
}


/*
 * Red Eye Removal Algorithm, based on using a threshold to detect
 * red pixels. Having a user-made selection around the eyes will
 * prevent incorrect pixels from being selected.
 */
- (FilterImage*)remove_redeye:(FilterImage*)input {
	int		x, y;
	int		width, height;
	int		bpp;
	int		rowstride;
	
	uint8_t *src_rgn;
	uint8_t *dst_rgn;

	/* initialization */
	width = input.width;
	height = input.height;
		
	bpp = 4;
	rowstride = bpp * width;
	
	src_rgn = input.imageData;
	FilterImage *output = [[FilterImage alloc] initWithWidth:width andHeight:height];
	dst_rgn = output.imageData;
	
	for (y = 0; y < height; y++) {
		for (x = 0; x < width; x++) {
			uint8_t red = src_rgn[y * rowstride + x * bpp + 0];
			uint8_t green = src_rgn[y * rowstride + x * bpp + 1];
			uint8_t blue = src_rgn[y * rowstride + x * bpp + 2];
			uint8_t alpha = src_rgn[y * rowstride + x * bpp + 3];
			
			int adjusted_red       = red * RED_FACTOR;
			int adjusted_green     = green * GREEN_FACTOR;
			int adjusted_blue      = blue * BLUE_FACTOR;
			int adjusted_threshold = (threshold - 50) * 2;
			
			if (adjusted_red >= adjusted_green - adjusted_threshold &&
				adjusted_red >= adjusted_blue - adjusted_threshold) {
				*dst_rgn++ = CLAMP (((float) (adjusted_green + adjusted_blue) / (2.0  * RED_FACTOR)), 0, 255);
            } else {
				*dst_rgn++ = red;
            }
			
			*dst_rgn++ = green;
			*dst_rgn++ = blue;
			*dst_rgn++ = alpha;
        }
		
		if (isCancel) {
			[output release];
			isCancel = NO;
			return nil;
		}
		
		if (y % 10 == 0 && !preview) {
			NSString *value = [NSString stringWithFormat:@"%i%%", (int) (100 * y / height)];
			[[NSNotificationCenter defaultCenter] postNotificationName:FPSNotification
																object:nil
															  userInfo:[NSDictionary dictionaryWithObject:value
																								   forKey:@"value"]];			
		}
		
    }
	
	return [output autorelease];
}

- (void)run:(NSDictionary*)data {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	FilterImage *input = [data objectForKey:@"image"];
	NSIndexPath *indexPath = [data objectForKey:@"indexPath"];
	NSString *notificationName = [data objectForKey:@"notificationName"];
	preview = [[data objectForKey:@"preview"] boolValue];
	NSNumber *thresholdData = [data objectForKey:@"threshold"];
	if (thresholdData != nil) {
		threshold = [thresholdData intValue];
	} else { // set to default
		threshold = 50;
	}
	
	FilterImage *output = [self remove_redeye:input];
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:output, @"image", indexPath, @"indexPath", nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:info];
	
	self.isCancel = NO;
	
	[pool drain];
}

@end
