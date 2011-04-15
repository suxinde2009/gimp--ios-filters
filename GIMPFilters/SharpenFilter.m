//
//  SharpenFilter.m
//  FiltersTest
//
//  Created by maxim on 12.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import "SharpenFilter.h"
#import "FilterImage.h"
#import "Definitions.h"
#import "Functions.h"

@implementation SharpenFilter

@synthesize isCancel;

static int neg_lut[256];   /* Negative coefficient LUT */
static int pos_lut[256];   /* Positive coefficient LUT */

static int sharpenPercent = 50;

static SharpenFilter *sharedFilter = nil;

+ (SharpenFilter*)sharedFilter {
	@synchronized (self) {
		if (sharedFilter == nil) {
			sharedFilter = [[self alloc] init];
		}
	}
	return sharedFilter;
}


static void compute_luts (void) {
	int i;       /* Looping var */
	int fact;    /* 1 - sharpness */
	
	fact = 100 - sharpenPercent;
	if (fact < 1)
		fact = 1;
	
	for (i = 0; i < 256; i ++) {
		pos_lut[i] = 800 * i / fact;
		neg_lut[i] = (4 + pos_lut[i] - (i << 3)) >> 3;
    }
}



/*
 * 'rgba_filter()' - Sharpen RGBA pixels.
 */

static void rgba_filter (int width,      /* I - Width of line in pixels */
             uint8_t *src,       /* I - Source line */
             uint8_t *dst,       /* O - Destination line */
             int *neg0,      /* I - Top negative coefficient line */
             int *neg1,      /* I - Middle negative coefficient line */
             int *neg2)      /* I - Bottom negative coefficient line */
{
	int pixel;         /* New pixel value */
	
	*dst++ = *src++;
	*dst++ = *src++;
	*dst++ = *src++;
	*dst++ = *src++;
	width -= 2;
	
	while (width > 0) {

		pixel = (pos_lut[*src++] - neg0[-4] - neg0[0] - neg0[4] - neg1[-4] - neg1[4] - neg2[-4] - neg2[0] - neg2[4]);
		pixel = (pixel + 4) >> 3;
		*dst++ = CLAMP0255 (pixel);
		
		pixel = (pos_lut[*src++] - neg0[-3] - neg0[1] - neg0[5] - neg1[-3] - neg1[5] - neg2[-3] - neg2[1] - neg2[5]);
		pixel = (pixel + 4) >> 3;
		*dst++ = CLAMP0255 (pixel);
		
		pixel = (pos_lut[*src++] - neg0[-2] - neg0[2] - neg0[6] - neg1[-2] - neg1[6] - neg2[-2] - neg2[2] - neg2[6]);
		pixel = (pixel + 4) >> 3;
		*dst++ = CLAMP0255 (pixel);

		*dst++ = *src++;		
		
		neg0 += 4;
		neg1 += 4;
		neg2 += 4;
		width --;
    }
	
	*dst++ = *src++;
	*dst++ = *src++;
	*dst++ = *src++;
	*dst++ = *src++;
}

- (FilterImage*)sharpen:(FilterImage*)input {
	uint8_t       *src_rows[4];    /* Source pixel rows */
	uint8_t       *src_ptr;        /* Current source pixel */
	uint8_t       *dst_row;        /* Destination pixel row */
	int           *neg_rows[4];    /* Negative coefficient rows */
	int           *neg_ptr;        /* Current negative coefficient */
	int           i;              /* Looping vars */
	int           y;              /* Current location in image */
	int           row;            /* Current row in src_rows */
	int           count;          /* Current number of filled src_rows */
	int           width;          /* Byte width of the image */
	int           x1;             /* Selection bounds */
	int           y1;
	int           x2;
	int           y2;
	int           sel_width;      /* Selection width */
	int           sel_height;     /* Selection height */
	int           img_bpp;        /* Bytes-per-pixel in image */
	
	uint8_t *src_base;			  /* Source Image Data */
	uint8_t *dest;				  /* Destination Image Data */
	
	void          (*filter)(int, uint8_t *, uint8_t *, int *, int *, int *);
	
	/* initialization */
	filter = NULL;
	if (preview) {
		x1 = input.width / 2;
		y1 = 0;
		
		x2 = input.width;
		y2 = input.height;
		
		sel_width = x2 - x1;
		sel_height = y2 - y1;
	} else {
		x1 = 0;
		y1 = 0;
		
		sel_width = input.width;
		sel_height = y2 = input.height;
	}
	
	img_bpp = 4; // 4 channels (RGB_)
	
	src_base = input.imageData;
	FilterImage * output = [[FilterImage alloc] initWithWidth:input.width andHeight:input.height];
	dest = output.imageData;
	
	compute_luts ();

	width = sel_width * img_bpp;
	
	for (row = 0; row < 4; row ++) {
		src_rows[row] = g_new (uint8_t, width);
		neg_rows[row] = g_new (int, width);
    }
	
	dst_row = g_new (uint8_t, width);

	/*
	 * Pre-load the first row for the filter...
	 */

	get_row(src_base, img_bpp, x1, y1, sel_width, src_rows[0], input.width);
	
	for (i = width, src_ptr = src_rows[0], neg_ptr = neg_rows[0]; i > 0; i --, src_ptr ++, neg_ptr ++)
		*neg_ptr = neg_lut[*src_ptr];
	
	row   = 1;
	count = 1;
	
	/*
	 * Select the filter...
	 */
	
	switch (img_bpp)
    {
//		case 1 :
//			filter = gray_filter;
//			break;
//		case 2 :
//			filter = graya_filter;
//			break;
//		case 3 :
//			filter = rgb_filter;
//			break;
		case 4 :
			filter = rgba_filter;
			break;
    };
	
	/*
	 * Sharpen...
	 */
	
	for (y = y1; y < y2; y ++) {
		/*
		 * Load the next pixel row...
		 */
		
		if ((y + 1) < y2) {
			/*
			 * Check to see if our src_rows[] array is overflowing yet...
			 */
			
			if (count >= 3)
				count --;
			
			/*
			 * Grab the next row...
			 */
			
			get_row(src_base, img_bpp, x1, y + 1, sel_width, src_rows[row], input.width);
			
			
			for (i = width, src_ptr = src_rows[row], neg_ptr = neg_rows[row]; i > 0; i --, src_ptr ++, neg_ptr ++)
				*neg_ptr = neg_lut[*src_ptr];
			
			count ++;
			row = (row + 1) & 3;
        } else {
			/*
			 * No more pixels at the bottom...  Drop the oldest samples...
			 */
			
			count --;
        }
		
		/*
		 * Now sharpen pixels and save the results...
		 */
		
		if (count == 3) {
			(* filter) (sel_width, src_rows[(row + 2) & 3], dst_row,
						neg_rows[(row + 1) & 3] + img_bpp,
						neg_rows[(row + 2) & 3] + img_bpp,
						neg_rows[(row + 3) & 3] + img_bpp);
			
			/*
			 * Set the row...
			 */
			
			set_row(dst_row, img_bpp, x1, y, sel_width, dest, output.width);
			
        } else if (count == 2) {
			if (y == y1) {		/* first row */
				set_row(src_rows[0], img_bpp, x1, y, sel_width, dest, output.width);
			} else {			/* last row  */
				set_row(src_rows[(sel_height - 1) & 3], img_bpp, x1, y, sel_width, dest, output.width);
			}
        }
		
		if (isCancel) {
			[output release];
			for (row = 0; row < 4; row ++) {
				free (src_rows[row]);
				free (neg_rows[row]);
			}
			free (dst_row);
			
			isCancel = NO;
			return nil;
		}
		
		if ((y & 15) == 0 && !preview) {
			NSString *value = [NSString stringWithFormat:@"%i%%", (int) (100 * (y - y1) / sel_height)];
			[[NSNotificationCenter defaultCenter] postNotificationName:FPSNotification
																object:nil
															  userInfo:[NSDictionary dictionaryWithObject:value
																								   forKey:@"value"]];						
		}
    }
	
	/*
	 * OK, we're done.  Free all memory used...
	 */
	
	for (row = 0; row < 4; row ++) {
		free (src_rows[row]);
		free (neg_rows[row]);
    }
	
	free (dst_row);
	
	if (preview) {
		uint8_t *srcrect = g_new0 (uint8_t, width * sel_height);
		get_rect(src_base, img_bpp, 0, 0, sel_width, sel_height, srcrect, input.width);
		set_rect(srcrect, img_bpp, 0, 0, sel_width, sel_height, dest, output.width);
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
	
	NSNumber *sharpenPerc = [data objectForKey:@"sharpenPercent"];
	if (sharpenPerc != nil) {
		sharpenPercent = [sharpenPerc intValue];
	} else { // set to default
		sharpenPercent = 10;
	}
	
	FilterImage *output = [self sharpen:input];
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:output, @"image", indexPath, @"indexPath", nil];
		
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:info];
	
	self.isCancel = NO;
	
	[pool release];
}

@end
