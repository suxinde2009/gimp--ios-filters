//
//  BWFilter.m
//  FiltersTest
//
//  Created by maxim on 01.02.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import "BWFilter.h"
#import "FilterImage.h"
#import "Definitions.h"
#import "Functions.h"

@implementation BWFilter

static BWFilter *sharedFilter;

+ (id)sharedFilter {
	@synchronized(self) {
		if (sharedFilter == nil) {
			sharedFilter = [[BWFilter alloc] init];
		}
	}
	return sharedFilter;
}

- (FilterImage*)bw_image:(FilterImage*)input {
	uint8_t *src = input.imageData;
	FilterImage *output = [[FilterImage alloc] initWithWidth:input.width andHeight:input.height];
	uint8_t *dst = output.imageData;
	
	for (int y = 0; y < input.height; y++) {
		for (int x = 0; x < input.width; x++) {
			if (preview) {
				if (x < input.width / 2) {
					*dst++ = *src++;
					*dst++ = *src++;
					*dst++ = *src++;
					*dst++ = *src++;
					continue;
				}
			}
			
			int grayScale = *src++ * .3 + *src++ * .59 + *src++ * .11;
			*dst++ = grayScale; // R
			*dst++ = grayScale; // G
			*dst++ = grayScale; // B
			*dst++ = *src++; // A
		}
	}
	
	return [output autorelease];
}

- (void)run:(NSDictionary*)data {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	FilterImage *input = [data objectForKey:@"image"];
	NSIndexPath *indexPath = [data	objectForKey:@"indexPath"];
	NSString *notificationName = [data objectForKey:@"notificationName"];
	preview = [[data objectForKey:@"preview"] boolValue];
	
	FilterImage *output = [self bw_image:input];
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:output, @"image", indexPath, @"indexPath", nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:info];
	
	[pool release];
}

@end
