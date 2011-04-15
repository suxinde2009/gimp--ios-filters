//
//  SoftGlowFilter.m
//  FiltersTest
//
//  Created by maxim on 18.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import "SoftGlowFilter.h"
#import "FilterImage.h"
#import "Definitions.h"
#import "Functions.h"


@implementation SoftGlowFilter

@synthesize isCancel;

#define TILE_CACHE_SIZE 48
#define SIGMOIDAL_BASE   2
#define SIGMOIDAL_RANGE 20

#define INT_MULT(a,b,t)  ((t) = (a) * (b) + 0x80, ((((t) >> 8) + (t)) >> 8))

typedef struct {
	double glow_radius;
	double brightness;
	double sharpness;
} SoftglowVals;

static SoftglowVals svals =
{
	10.0, /* glow_radius */
	0.75, /* brightness */
	0.85,  /* sharpness */
};


/**
 * gimp_rgb_to_l_int:
 * @red: Red channel
 * @green: Green channel
 * @blue: Blue channel
 *
 * Calculates the lightness value of an RGB triplet with the formula
 * L = (max(R, G, B) + min (R, G, B)) / 2
 *
 * Return value: Luminance vaue corresponding to the input RGB value
 **/
int gimp_rgb_to_l_int (int red, int green, int blue) {
	int min, max;
	
	if (red > green) {
		max = MAX (red,   blue);
		min = MIN (green, blue);
    } else {
		max = MAX (green, blue);
		min = MIN (red,   blue);
    }
	
	return ROUND ((max + min) / 2.0);
}

static inline int gimp_hsl_value_int (double n1, double n2, double hue) {
	double value;
	
	if (hue > 255)
		hue -= 255;
	else if (hue < 0)
		hue += 255;
	
	if (hue < 42.5)
		value = n1 + (n2 - n1) * (hue / 42.5);
	else if (hue < 127.5)
		value = n2;
	else if (hue < 170)
		value = n1 + (n2 - n1) * ((170 - hue) / 42.5);
	else
		value = n1;
	
	return ROUND (value * 255.0);
}



/*
 *  Gaussian blur helper functions
 */

static void transfer_pixels (double *src1, double *src2, uint8_t *dest, int jump, int width) {
	int    i;
	double sum;
	
	for (i = 0; i < width; i++) {
		sum = src1[i] + src2[i];
		
		sum = CLAMP0255 (sum);
		
		*dest = (uint8_t) sum;
		dest += jump;
    }
}

static void find_constants (double n_p[],
							double n_m[],
							double d_p[],
							double d_m[],
							double bd_p[],
							double bd_m[],
							double std_dev)
{
	int    i;
	double constants [8];
	double div;
	
	/*  The constants used in the implemenation of a casual sequence
	 *  using a 4th order approximation of the gaussian operator
	 */
	
	div = sqrt(2 * G_PI) * std_dev;
	
	constants [0] = -1.783  / std_dev;
	constants [1] = -1.723  / std_dev;
	constants [2] =  0.6318 / std_dev;
	constants [3] =  1.997  / std_dev;
	constants [4] =  1.6803 / div;
	constants [5] =  3.735  / div;
	constants [6] = -0.6803 / div;
	constants [7] = -0.2598 / div;
	
	n_p [0] = constants[4] + constants[6];
	n_p [1] = exp (constants[1]) *
    (constants[7] * sin (constants[3]) -
     (constants[6] + 2 * constants[4]) * cos (constants[3])) +
	exp (constants[0]) *
	(constants[5] * sin (constants[2]) -
	 (2 * constants[6] + constants[4]) * cos (constants[2]));
	n_p [2] = 2 * exp (constants[0] + constants[1]) *
    ((constants[4] + constants[6]) * cos (constants[3]) * cos (constants[2]) -
     constants[5] * cos (constants[3]) * sin (constants[2]) -
     constants[7] * cos (constants[2]) * sin (constants[3])) +
	constants[6] * exp (2 * constants[0]) +
	constants[4] * exp (2 * constants[1]);
	n_p [3] = exp (constants[1] + 2 * constants[0]) *
    (constants[7] * sin (constants[3]) - constants[6] * cos (constants[3])) +
	exp (constants[0] + 2 * constants[1]) *
	(constants[5] * sin (constants[2]) - constants[4] * cos (constants[2]));
	n_p [4] = 0.0;
	
	d_p [0] = 0.0;
	d_p [1] = -2 * exp (constants[1]) * cos (constants[3]) -
    2 * exp (constants[0]) * cos (constants[2]);
	d_p [2] = 4 * cos (constants[3]) * cos (constants[2]) * exp (constants[0] + constants[1]) +
    exp (2 * constants[1]) + exp (2 * constants[0]);
	d_p [3] = -2 * cos (constants[2]) * exp (constants[0] + 2 * constants[1]) -
    2 * cos (constants[3]) * exp (constants[1] + 2 * constants[0]);
	d_p [4] = exp (2 * constants[0] + 2 * constants[1]);
	
#ifndef ORIGINAL_READABLE_CODE
	memcpy(d_m, d_p, 5 * sizeof(double));
#else
	for (i = 0; i <= 4; i++)
		d_m [i] = d_p [i];
#endif
	
	n_m[0] = 0.0;
	for (i = 1; i <= 4; i++)
		n_m [i] = n_p[i] - d_p[i] * n_p[0];
	
	{
		double sum_n_p, sum_n_m, sum_d;
		double a, b;
		
		sum_n_p = 0.0;
		sum_n_m = 0.0;
		sum_d   = 0.0;
		
		for (i = 0; i <= 4; i++) {
			sum_n_p += n_p[i];
			sum_n_m += n_m[i];
			sum_d += d_p[i];
		}
		
#ifndef ORIGINAL_READABLE_CODE
		sum_d++;
		a = sum_n_p / sum_d;
		b = sum_n_m / sum_d;
#else
		a = sum_n_p / (1 + sum_d);
		b = sum_n_m / (1 + sum_d);
#endif
		
		for (i = 0; i <= 4; i++)
		{
			bd_p[i] = d_p[i] * a;
			bd_m[i] = d_m[i] * b;
		}
	}
}

static SoftGlowFilter *sharedFilter;

+ (SoftGlowFilter*)sharedFilter {
	@synchronized(self) {
		if (sharedFilter == nil) {
			sharedFilter = [[self alloc] init];
		}
	}
	return sharedFilter;
}

- (FilterImage*)softglow:(FilterImage*)input {
	int          width, height;
	int          bytes;
	bool		 has_alpha;
	uint8_t      *dest;
	uint8_t      *src, *sp_p, *sp_m;
	double       n_p[5], n_m[5];
	double       d_p[5], d_m[5];
	double       bd_p[5], bd_m[5];
	double		 *val_p, *val_m, *vp, *vm;
	int          x1, y1, x2, y2;
	int          i, j;
	int          row, col, b;
	int          terms;
	int          progress, max_progress;
	int          initial_p[4];
	int          initial_m[4];
	int          tmp;
	double       radius;
	double       std_dev;
	double       val;
	
	uint8_t *src_ptr;
	uint8_t *dest_ptr;
	
	x1 = 0;
	y1 = 0;
	
	x2 = input.width;
	y2 = input.height;
	
	width = input.width;
	height = input.height;

	bytes = 4; // RGB_
	has_alpha = 1;

	val_p = g_new (double, MAX (width, height));
	val_m = g_new (double, MAX (width, height));
	
	dest = g_new0 (unsigned char, width * height);
	
	src_ptr = input.imageData;
	FilterImage *output = [[FilterImage alloc] initWithWidth:width andHeight:height];
	dest_ptr = dest;
		
	progress = 0;
	max_progress = width * height * 3;
		
	for (row = 0; row < height; row++) {
		for (col = 0; col < width; col++) {
			/* desaturate */
			if (bytes > 2)
				dest_ptr[col] = (uint8_t) gimp_rgb_to_l_int (src_ptr[col * bytes + 0], src_ptr[col * bytes + 1], src_ptr[col * bytes + 2]);
			else
				dest_ptr[col] = (uint8_t) src_ptr[col * bytes];
			
			/* compute sigmoidal transfer */
			val = dest_ptr[col] / 255.0;
			val = 255.0 / (1 + exp (-(SIGMOIDAL_BASE + (svals.sharpness * SIGMOIDAL_RANGE)) * (val - 0.5)));
			val = val * svals.brightness;
			dest_ptr[col] = (uint8_t) CLAMP (val, 0, 255);
		}
		
		src_ptr += bytes * width;
		dest_ptr += width;
	}
	
	progress += width * height;
	
	/*  Calculate the standard deviations  */
	radius  = fabs (svals.glow_radius) + 1.0;
	std_dev = sqrt (-(radius * radius) / (2 * log (1.0 / 255.0)));
	
	/*  derive the constants for calculating the gaussian from the std dev  */
	find_constants (n_p, n_m, d_p, d_m, bd_p, bd_m, std_dev);
	
	/*  First the vertical pass  */
	for (col = 0; col < width; col++) {
		memset (val_p, 0, height * sizeof (double));
		memset (val_m, 0, height * sizeof (double));
		
		src  = dest + col;
		sp_p = src;
		sp_m = src + width * (height - 1);
		vp   = val_p;
		vm   = val_m + (height - 1);
		
		/*  Set up the first vals  */
		initial_p[0] = sp_p[0];
		initial_m[0] = sp_m[0];
		
		for (row = 0; row < height; row++) {
			double *vpptr, *vmptr;
			
			terms = (row < 4) ? row : 4;
			
			vpptr = vp; vmptr = vm;
			for (i = 0; i <= terms; i++) {
				*vpptr += n_p[i] * sp_p[-i * width] - d_p[i] * vp[-i];
				*vmptr += n_m[i] * sp_m[i * width] - d_m[i] * vm[i];
            }
			for (j = i; j <= 4; j++) {
				*vpptr += (n_p[j] - bd_p[j]) * initial_p[0];
				*vmptr += (n_m[j] - bd_m[j]) * initial_m[0];
            }
			
			sp_p += width;
			sp_m -= width;
			vp ++;
			vm --;
        }
		
		transfer_pixels (val_p, val_m, dest + col, width, height);
		
		progress += height;
		
		if (isCancel) {
			[output release];
			
			free (val_p);
			free (val_m);
			free (dest);
			
			isCancel = NO;
			return nil;
		}
		if ((col % 5) == 0 && !preview) {
			// NSLog(@"SoftGlow: - Progress: %f", (float) progress / max_progress);
			NSString *value = [NSString stringWithFormat:@"%i%%", (int) (100 * progress / max_progress)];
			[[NSNotificationCenter defaultCenter] postNotificationName:FPSNotification
																object:nil
															  userInfo:[NSDictionary dictionaryWithObject:value
																								   forKey:@"value"]];									
		}
    }
	
	for (row = 0; row < height; row++) {
		memset (val_p, 0, width * sizeof (double));
		memset (val_m, 0, width * sizeof (double));
		
		src = dest + row * width;
		
		sp_p = src;
		sp_m = src + width - 1;
		vp = val_p;
		vm = val_m + width - 1;
		
		/*  Set up the first vals  */
		initial_p[0] = sp_p[0];
		initial_m[0] = sp_m[0];
		
		for (col = 0; col < width; col++) {
			double *vpptr, *vmptr;
			
			terms = (col < 4) ? col : 4;
			
			vpptr = vp; vmptr = vm;
			
			for (i = 0; i <= terms; i++) {
				*vpptr += n_p[i] * sp_p[-i] - d_p[i] * vp[-i];
				*vmptr += n_m[i] * sp_m[i] - d_m[i] * vm[i];
            }
			
			for (j = i; j <= 4; j++) {
				*vpptr += (n_p[j] - bd_p[j]) * initial_p[0];
				*vmptr += (n_m[j] - bd_m[j]) * initial_m[0];
            }
			
			sp_p ++;
			sp_m --;
			vp ++;
			vm --;
        }
		
		transfer_pixels (val_p, val_m, dest + row * width, 1, width);
		
		progress += width;
		
		if (isCancel) {
			[output release];
			
			free (val_p);
			free (val_m);
			free (dest);
			
			isCancel = NO;
			return nil;
		}
		
		if ((row % 5) == 0 && !preview) {
			NSString *value = [NSString stringWithFormat:@"%i%%", (int) (100 * progress / max_progress)];
			[[NSNotificationCenter defaultCenter] postNotificationName:FPSNotification
																object:nil
															  userInfo:[NSDictionary dictionaryWithObject:value
																								   forKey:@"value"]];			
		}
    }
	
	src_ptr  = input.imageData;
	dest_ptr = output.imageData;
	uint8_t *blur_ptr = dest;
	
	for (row = 0; row < height; row++) {
		for (col = 0; col < width; col++) {
				/* screen op */
				for (b = 0; b < (has_alpha ? (bytes - 1) : bytes); b++)
					dest_ptr[col * bytes + b] = 255 - INT_MULT((255 - src_ptr[col * bytes + b]), (255 - blur_ptr[col]), tmp);
				if (has_alpha)
					dest_ptr[col * bytes + b] = src_ptr[col * bytes + b];
		}
		
		src_ptr += bytes * width;
		dest_ptr += bytes * width;
		
		blur_ptr += width;
	}
	
	/*  free up buffers  */
	free (val_p);
	free (val_m);
	free (dest);
	
	if (preview) {
		uint8_t *srcrect = g_new0 (uint8_t, width * bytes * height);
		uint8_t *src = input.imageData;
		uint8_t *dest = output.imageData;
		get_rect(src, bytes, 0, 0, width / 2, height, srcrect, input.width);
		set_rect(srcrect, bytes, 0, 0, width / 2, height, dest, output.width);
		free(srcrect);
	}
	
	return [output autorelease];
}

- (void)run:(NSDictionary*)data {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	FilterImage *input = [data objectForKey:@"image"];
	NSIndexPath *indexPath = [data objectForKey:@"indexPath"];
	NSString *notificationName = [data objectForKey:@"notificationName"];
	
	NSNumber *glowRadius = [data objectForKey:@"glowRadius"];
	NSNumber *brightness = [data objectForKey:@"brightness"];
	NSNumber *sharpness = [data objectForKey:@"sharpness"];
	preview = [[data objectForKey:@"preview"] boolValue];
	
	if (glowRadius != nil && brightness != nil && sharpness != nil) {
		svals.glow_radius = [glowRadius doubleValue];
		svals.brightness = [brightness doubleValue];
		svals.sharpness = [sharpness doubleValue];
	} else { // set values to default
		svals.glow_radius = 10.0;
		svals.brightness = 0.75;
		svals.sharpness = 0.85;
	}
	
	FilterImage *output = [self softglow:input];
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:output, @"image", indexPath, @"indexPath", nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:info];
	
	self.isCancel = NO;
	
	[pool release];
}

@end
