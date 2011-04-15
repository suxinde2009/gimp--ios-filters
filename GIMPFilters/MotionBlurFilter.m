//
//  MotionBlurFilter.m
//  FiltersTest
//
//  Created by maxim on 20.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import "MotionBlurFilter.h"
#import "Definitions.h"
#import "Functions.h"


@implementation MotionBlurFilter

@synthesize isCancel;

#define MBLUR_LENGTH_MAX     256.0

static MotionBlurFilter *sharedFilter;

+ (MotionBlurFilter*)sharedFilter {
	@synchronized(self) {
		if (sharedFilter == nil) {
			sharedFilter = [[MotionBlurFilter alloc] init];
		}
	}
	return sharedFilter;
}

typedef enum {
	MBLUR_LINEAR,
	MBLUR_ZOOM,
	MBLUR_RADIAL,
} MBlurType;


typedef struct {
	int    mblur_type;
	int    length;
	int    angle;
	int    center_x;
	int    center_y;
	bool   blur_outward;
} mblur_vals_t;


static mblur_vals_t mbvals = {
	MBLUR_LINEAR, /* mblur_type   */
	5,            /* length       */
	10,           /* radius, angle*/
	-1,			  /* center_x     */
	-1,			  /* center_y     */
	TRUE          /* blur_outward */
};


- (FilterImage*) mblur_linear:(FilterImage*)input {

	uint8_t *src_data;
	uint8_t *dest;
	uint8_t *d;
	uint8_t  pixel[4];
	int sum[4];
	int c;
	int x, y, i, xx, yy, n;
	int dx, dy, px, py, swapdir, err, e, s1, s2;
	int x1, y1;
	int width, height;
	int img_bpp = 4; // RGBA
	bool has_alpha = 0;
	
	if (preview) {
		x1 = input.width / 2;
		y1 = 0;
		
		width = input.width;
		height = input.height;
	} else {
		x1 = 0; y1 = 0;
		width = input.width;
		height = input.height;
	}
	
	
	n = mbvals.length;
	px = (double) n * cos (mbvals.angle / 180.0 * G_PI);
	py = (double) n * sin (mbvals.angle / 180.0 * G_PI);
	
	src_data = input.imageData;
	FilterImage *output = [[FilterImage alloc] initWithWidth:width andHeight:height];
	dest = output.imageData;
	
	/*
	 * Initialization for Bresenham algorithm:
	 * dx = abs(x2-x1), s1 = sign(x2-x1)
	 * dy = abs(y2-y1), s2 = sign(y2-y1)
	 */
	if ((dx = px) != 0) {
		if (dx < 0) {
			dx = -dx;
			s1 = -1;
        } else {
			s1 = 1;
		}
    } else {
		s1 = 0;
	}
	
	if ((dy = py) != 0) {
		if (dy < 0) {
			dy = -dy;
			s2 = -1;
        } else {
			s2 = 1;
		}
    } else {
		s2 = 0;
	}
	
	if (dy > dx) {
		swapdir = dx;
		dx = dy;
		dy = swapdir;
		swapdir = 1;
    } else {
		swapdir = 0;
	}
	
	dy *= 2;
	err = dy - dx;        /* Initial error term   */
	dx *= 2;
	
	for (y = 0; y < height; y++) {
		d = dest;
		
		for (x = 0; x < width; x++)	{
			xx = x; yy = y; e = err;
			for (c = 0; c < img_bpp; c++)
				sum[c]= 0;
			
			for (i = 0; i < n; ) {
				get_pixel(src_data, img_bpp, xx, yy, width, pixel);
				
				if (has_alpha) {
					int alpha = pixel[img_bpp - 1];
					
					sum[img_bpp - 1] += alpha;
					for (c = 0; c < img_bpp - 1; c++)
						sum[c] += pixel[c] * alpha;
				} else {
					for (c = 0; c < img_bpp; c++)
						sum[c] += pixel[c];
				}
				
				i++;
				
				while (e >= 0 && dx) {
					if (swapdir)
						xx += s1;
					else
						yy += s2;
					e -= dx;
				}
				
				if (swapdir)
					yy += s2;
				else
					xx += s1;
				
				e += dy;
				
				if ((xx < x1) || (xx >= x1 + width) || (yy < y1) || (yy >= y1 + height))
					break;
			}
			
			if (i == 0)	{
				get_pixel(src_data, img_bpp, xx, yy, width, d);
			} else {
				if (has_alpha) {
					int alpha = sum[img_bpp - 1];
					
					if ((d[img_bpp - 1] = alpha / i) != 0) {
						for (c = 0; c < img_bpp - 1; c++)
							d[c] = sum[c] / alpha;
					}
				} else {
					for (c = 0; c < img_bpp; c++)
						d[c] = sum[c] / i;
				}
			}
			
			d += img_bpp;
		}
		
		dest += width * img_bpp;
		
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


- (FilterImage*)mblur_radial:(FilterImage*)input {
	
	uint8_t *src_data;
	uint8_t *dest;
	uint8_t *d;
	uint8_t	pixel[4];
	uint8_t p1[4], p2[4], p3[4], p4[4];

	double angle, theta, r, xx, yy, xr, yr;
	double phi, phi_start, s_val, c_val;
	double dx, dy;
	double center_x;
	double center_y;

	int sum[4];
	int c;
	int x, y, i, n, count;
	int x1, y1;
	int width, height;
	int img_bpp = 4;
	
	bool has_alpha = 0;
	
	/* initialize */
	
	xx = 0.0;
	yy = 0.0;
	
	x1 = 0;
	y1 = 0;
	
	width = input.width;
	height = input.height;
	
	center_x = mbvals.center_x;
	center_y = mbvals.center_y;
	
	if (center_x == -1 || center_y == -1) {
		center_x = width / 2;
		center_y = height / 2;
	}
	
	src_data = input.imageData;
	FilterImage *output = [[FilterImage alloc] initWithWidth:width andHeight:height];
	dest = output.imageData;

	angle = gimp_deg_to_rad (mbvals.angle);
			
	for (y = 0; y < height; y++) {
		d = dest;
		
		for (x = 0; x < width; x++) {
			xr = (double) x - center_x;
			yr = (double) y - center_y;
			
			r = sqrt (SQR (xr) + SQR (yr));
			n = r * angle;
			
			if (angle == 0.0) {
				get_pixel(src_data, img_bpp, x, y, width, d);
				d += img_bpp;
				continue;
			}
			
			/* ensure quality with small angles */
			if (n < 3)
				n = 3;  /* always use at least 3 (interpolation) steps */
			
			/* limit loop count due to performanc reasons */
			if (n > 100)
				n = 100 + sqrt (n-100);
			
			if (xr != 0.0) {
				phi = atan(yr/xr);
				if (xr < 0.0)
					phi = G_PI + phi;
				
			} else {
				if (yr >= 0.0)
					phi = G_PI_2;
				else
					phi = -G_PI_2;
			}
			
			for (c = 0; c < img_bpp; c++)
				sum[c] = 0;
			
			if (n == 1)
				phi_start = phi;
			else
				phi_start = phi + angle/2.0;
			
			theta = angle / (double)n;
			count = 0;
			
			for (i = 0; i < n; i++) {
				s_val = sin (phi_start - (double) i * theta);
				c_val = cos (phi_start - (double) i * theta);
				
				xx = center_x + r * c_val;
				yy = center_y + r * s_val;
				
				if ((yy < y1) || (yy + 0.5 >= y1 + height) ||
					(xx < x1) || (xx + 0.5 >= x1 + width))
					continue;
				
				++count;
				if ((xx + 1 < x1 + width) && (yy + 1 < y1 + height)) {
					dx = xx - floor (xx);
					dy = yy - floor (yy);
					
					get_pixel(src_data, img_bpp, xx, yy, width, p1);
					get_pixel(src_data, img_bpp, xx + 1, yy, width, p2);
					get_pixel(src_data, img_bpp, xx, yy + 1, width, p3);
					get_pixel(src_data, img_bpp, xx + 1, yy + 1, width, p4);
					
					for (c = 0; c < img_bpp; c++) {
						pixel[c] = (((double) p1[c] * (1.0 - dx) +
									 (double) p2[c] * dx) * (1.0 - dy) +
									((double) p3[c] * (1.0 - dx) +
									 (double) p4[c] * dx) * dy);
					}
				} else {
					get_pixel(src_data, img_bpp, xx + .5, yy + .5, width, pixel);
				}
				
				if (has_alpha) {
					int alpha = pixel[img_bpp - 1];
					
					sum[img_bpp - 1] += alpha;
					
					for (c = 0; c < img_bpp - 1; c++)
						sum[c] += pixel[c] * alpha;
				} else {
					for (c = 0; c < img_bpp; c++)
						sum[c] += pixel[c];
				}
			}
			
			if (count == 0)	{
				get_pixel(src_data, img_bpp, xx, yy, width, d);
			} else {
				if (has_alpha) {
					int alpha = sum[img_bpp - 1];
					
					if ((d[img_bpp - 1] = alpha/count) != 0) {
						for (c = 0; c < img_bpp - 1; c++)
							d[c] = sum[c] / alpha;
					}
				} else {
					for (c = 0; c < img_bpp; c++)
						d[c] = sum[c] / count;
				}
			}
			
			d += img_bpp;
		}
		
		dest += width * img_bpp;
		
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

- (FilterImage*)mblur_zoom:(FilterImage*)input {
	
	uint8_t		*src_data;
	uint8_t		*dest, *d;
	uint8_t		pixel[4];
	uint8_t		p1[4], p2[4], p3[4], p4[4];
	int			sum[4];
	int			x, y, i, n, c;
	double		xx_start, xx_end, yy_start, yy_end;
	double		xx, yy;
	double		dxx, dyy;
	double		dx, dy;
	double		center_x;
	double		center_y;
	double		f, r;
	int			xy_len;
	int			drawable_x1, drawable_y1;
	int			drawable_x2, drawable_y2;
	int			x1, y1;
	int			width, height;
	int			img_bpp = 4; // RGB_
	bool		has_alpha = 0;

	/* initialize */
	
	x1 = 0;
	y1 = 0;
	
	width = input.width;
	height = input.height;

	center_x = mbvals.center_x;
	center_y = mbvals.center_y;
	
	if (center_x == -1 || center_y == -1) {
		center_x = width / 2;
		center_y = height / 2;
	}
	
	drawable_x1 = x1;
	drawable_y1 = y1;
	
	drawable_x2 = width;
	drawable_y2 = height;
		
	src_data = input.imageData;
	FilterImage *output = [[FilterImage alloc] initWithWidth:width andHeight:height];
	dest = output.imageData;
	
	n = mbvals.length;
	
	if (n == 0)
		n = 1;
	
	r = sqrt (SQR (width / 2) + SQR (height / 2));
	n = ((double) n * r / MBLUR_LENGTH_MAX);
	f = (r - n) / r;
	
	for (y = 0; y < height; y++) {
		d = dest;
		
		for (x = 0; x < width; x++) {
			for (c = 0; c < img_bpp; c++)
				sum[c] = 0;
			
			xx_start = x;
			yy_start = y;
			
			if (mbvals.blur_outward) {
				xx_end = center_x + ((double) x - center_x) * f;
				yy_end = center_y + ((double) y - center_y) * f;
			} else {
				xx_end = center_x + ((double) x - center_x) * (1.0 / f);
				yy_end = center_y + ((double) y - center_y) * (1.0 / f);
			}
			
			xy_len = sqrt (SQR (xx_end - xx_start) + SQR (yy_end - yy_start)) + 1;
			
			if (xy_len < 3)
				xy_len = 3;
			
			dxx = (xx_end - xx_start) / (double) xy_len;
			dyy = (yy_end - yy_start) / (double) xy_len;
			
			xx = xx_start;
			yy = yy_start;
			
			for (i = 0; i < xy_len; i++) {
				if ((yy < drawable_y1) || (yy >= drawable_y2) ||
					(xx < drawable_x1) || (xx >= drawable_x2))
					break;
				
				if ((xx + 1 < drawable_x2) && (yy + 1 < drawable_y2)) {
					dx = xx - floor (xx);
					dy = yy - floor (yy);
					
					get_pixel(src_data, img_bpp, xx, yy, width, p1);
					get_pixel(src_data, img_bpp, xx + 1, yy, width, p2);
					get_pixel(src_data, img_bpp, xx, yy + 1, width, p3);
					get_pixel(src_data, img_bpp, xx + 1, yy + 1, width, p4);
					
					for (c = 0; c < img_bpp; c++) {
						pixel[c] = (((double)p1[c] * (1.0 - dx) + (double)p2[c] * dx) * (1.0-dy) +
									((double)p3[c] * (1.0 - dx) + (double)p4[c] * dx) * dy);
					}
				} else {
					get_pixel(src_data, img_bpp, xx + .5, yy + .5, width, pixel);
				}
				
				if (has_alpha) {
					int alpha = pixel[img_bpp - 1];
					
					sum[img_bpp - 1] += alpha;
					
					for (c = 0; c < img_bpp - 1; c++)
						sum[c] += pixel[c] * alpha;
				} else {
					for (c = 0; c < img_bpp; c++)
						sum[c] += pixel[c];
				}
				
				xx += dxx;
				yy += dyy;
			}
			
			if (i == 0) {
				get_pixel(src_data, img_bpp, xx, yy, width, d);
			} else {
				if (has_alpha) {
					int alpha = sum[img_bpp - 1];
					
					if ((d[img_bpp - 1] = alpha / i) != 0) {
						for (c = 0; c < img_bpp - 1; c++)
							d[c] = sum[c] / alpha;
					}
				} else {
					for (c = 0; c < img_bpp; c++)
						d[c] = sum[c] / i;
				}
			}
			
			d += img_bpp;
		}
		
		dest += width * img_bpp;
		
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
	
	NSNumber *length = [data objectForKey:@"length"];
	NSNumber *angle = [data objectForKey:@"angle"];
	NSNumber *outward = [data objectForKey:@"outward"];
	NSNumber *motionType = [data objectForKey:@"motionType"];
	
	NSNumber *centerX = [data objectForKey:@"centerX"];
	NSNumber *centerY = [data objectForKey:@"centerY"];
	preview = [[data objectForKey:@"preview"] boolValue];
	
	if (length != nil && angle != nil && outward != nil && motionType != nil) {
		mbvals.length = [length intValue];
		mbvals.angle = [angle intValue];
		mbvals.blur_outward = [outward intValue];
		mbvals.mblur_type = [motionType intValue];
		mbvals.center_x = [centerX intValue];
		mbvals.center_y = [centerY intValue];
	} else { // set values to default
		mbvals.mblur_type = MBLUR_LINEAR;
		mbvals.length = 5;
		mbvals.angle = 10;
		mbvals.blur_outward = TRUE;
		mbvals.center_x = -1;
		mbvals.center_y = -1;
	}
	
	FilterImage *output;
	switch (mbvals.mblur_type) {
		case MBLUR_LINEAR:
			output = [self mblur_linear:input];
			break;
		case MBLUR_ZOOM:
			output = [self mblur_zoom:input];
			break;
		case MBLUR_RADIAL:
			output = [self mblur_radial:input];
			break;
		default:
			output = nil;
			break;
	}
	
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:output, @"image", indexPath, @"indexPath", nil];

	[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:info];
	
	self.isCancel = NO;
	
	[pool release];
}

@end
