//
//  GlassTileFilter.m
//  FiltersTest
//
//  Created by maxim on 19.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import "GlassTileFilter.h"
#import "FilterImage.h"
#import "Definitions.h"
#import "Functions.h"

@implementation GlassTileFilter

@synthesize isCancel;

/* --- Typedefs --- */
typedef struct {
	int     xblock;
	int     yblock;
	/* interface only */
	int     constrain;
} GlassValues;

static GlassValues gtvals = {
	20,    /* tile width  */
	20,    /* tile height */
	/* interface only */
	TRUE   /* constrained */
};


static GlassTileFilter *sharedFilter;

+ (GlassTileFilter*)sharedFilter {
	@synchronized(self) {
		if (sharedFilter == nil) {
			sharedFilter = [[self alloc] init];
		}
	}
	return sharedFilter;
}

/*  -  Filter function  -  I wish all filter functions had a pmode :) */
- (FilterImage*)glasstile:(FilterImage*)input {
	int          width, height;
	int          bytes;
	uint8_t      *dest, *d;
	uint8_t      *cur_row;
	int          row, col, i;
	int          x1, y1, x2, y2;
	
	uint8_t *src_base;
	uint8_t *dest_ptr;
	
	/* Translations of variable names from Maswan
	 * rutbredd = grid width
	 * ruthojd = grid height
	 * ymitt = y middle
	 * xmitt = x middle
	 */
	
	int rutbredd, xpixel1, xpixel2;
	int ruthojd , ypixel2;
	int xhalv, xoffs, xmitt, xplus;
	int yhalv, yoffs, ymitt, yplus;
	
	if (preview) {
		x1 = input.width / 2;
		y1 = 0;
		
		x2 = input.width;
		y2 = input.height;
	} else {
		x1 = 0;
		y1 = 0;
		
		x2 = input.width;
		y2 = input.height;
	}
	
	width  = x2 - x1;
	height = y2 - y1;

	bytes = 4;
	
	cur_row = g_new (uint8_t, width * bytes);
	dest    = g_new (uint8_t, width * bytes);
	
	src_base = input.imageData;
	FilterImage *output = [[FilterImage alloc] initWithWidth:input.width andHeight:input.height];
	dest_ptr = output.imageData;
	
	rutbredd = gtvals.xblock;
	ruthojd  = gtvals.yblock;
	
	xhalv = rutbredd / 2;
	yhalv = ruthojd  / 2;
	
	xplus = rutbredd % 2;
	yplus = ruthojd  % 2;
	
	ymitt = y1;
	yoffs = 0;
	
	/*  Loop through the rows */
	for (row = y1; row < y2; row++) {
		d = dest;
		
		ypixel2 = ymitt + yoffs * 2;
		ypixel2 = CLAMP (ypixel2, 0, y2 - 1);

		get_row(src_base, bytes, x1, ypixel2, width, cur_row, input.width);		
		
		yoffs++;
		
		/* if current offset = half, do a displacement next time around */
		if (yoffs == yhalv) {
			ymitt += ruthojd;
			yoffs = - (yhalv + yplus);
        }
		
		xmitt = 0;
		xoffs = 0;
		
		for (col = 0; col < x2 - x1; col++) { /* one pixel */
			xpixel1 = (xmitt + xoffs) * bytes;
			xpixel2 = (xmitt + xoffs * 2) * bytes;
			
			if (xpixel2 < (x2 - x1) * bytes) {
				if (xpixel2 < 0)
					xpixel2 = 0;
				for (i = 0; i < bytes; i++)
					d[xpixel1 + i] = cur_row[xpixel2 + i];
            } else {
				for (i = 0; i < bytes; i++)
					d[xpixel1 + i] = cur_row[xpixel1 + i];
            }
			
			xoffs++;
			
			if (xoffs == xhalv) {
				xmitt += rutbredd;
				xoffs = - (xhalv + xplus);
            }
        }
		
		/*  Store the dest  */
		set_row(dest, bytes, x1, row, width, dest_ptr, output.width);
		
		if (isCancel) {
			[output release];
			
			free (cur_row);
			free (dest);
			
			isCancel = NO;
			return nil;
		}
		
		// NSLog(@"Glass Tile Progress: %f", (float) row / height);
		if (!preview) {
			NSString *value = [NSString stringWithFormat:@"%i%%", (int) (100 * row / height)];
			[[NSNotificationCenter defaultCenter] postNotificationName:FPSNotification
																object:nil
															  userInfo:[NSDictionary dictionaryWithObject:value
																								   forKey:@"value"]];
		}
    }
	
	free (cur_row);
	free (dest);
	
	if (preview) {
		uint8_t *srcrect = g_new0 (uint8_t, width * bytes * height);
		get_rect(src_base, bytes, 0, 0, width, height, srcrect, input.width);
		set_rect(srcrect, bytes, 0, 0, width, height, dest_ptr, output.width);
		free(srcrect);
	}
	

	return [output autorelease];
}

- (void)run:(NSDictionary*)data {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	FilterImage *input = [data objectForKey:@"image"];
	NSIndexPath *indexPath = [data objectForKey:@"indexPath"];
	NSString *notificationName = [data objectForKey:@"notificationName"];
	preview = [[data objectForKey:@"preview"] boolValue];
	
	NSNumber *xblock = [data objectForKey:@"xblock"];
	NSNumber *yblock = [data objectForKey:@"yblock"];
	
	if (xblock != nil && yblock != nil) {
		gtvals.xblock = [xblock intValue];
		gtvals.yblock = [yblock intValue];
	}
    else { // set to default
		gtvals.xblock = 20;
		gtvals.yblock = 20;
	}
	
	FilterImage *output = [self glasstile:input];
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:output, @"image", indexPath, @"indexPath", nil];

	[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:info];

	self.isCancel = NO;
	
	[pool release];
}

@end
