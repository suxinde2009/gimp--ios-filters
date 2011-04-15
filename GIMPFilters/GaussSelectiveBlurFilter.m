//
//  GaussSelectiveBlurFilter.m
//  FiltersTest
//
//  Created by maxim on 02.02.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import "GaussSelectiveBlurFilter.h"
#import "Definitions.h"
#import "FilterImage.h"
#import "Functions.h"


@implementation GaussSelectiveBlurFilter

static float radius;
static int maxDelta;
static int cancel = 0;

static GaussSelectiveBlurFilter *sharedFilter;

+ (GaussSelectiveBlurFilter*)sharedFilter {
	@synchronized(self) {
		if (sharedFilter == nil) {
			sharedFilter = [[GaussSelectiveBlurFilter alloc] init];
		}
	}
	return sharedFilter;
}

static void matrixmult (uint8_t *src,
						uint8_t *dest,
						int     width,
						int     height,
						float	**mat,
						int     numrad,
						int     bytes,
						bool	has_alpha,
						int     maxdelta,
						bool	preview_mode)
{
	int     i, j, b, nb, x, y;
	int     six, dix, tmp;
	int     rowstride;
	float	sum, fact, d, alpha = 1.0;
	uint8_t *src_b, *src_db;
	float	*m;
	int     offset;
	
	nb = bytes - (has_alpha ? 1 : 0);
	rowstride = width * bytes;
	
	for (y = 0; y < height; y++) {
		for (x = 0; x < width; x++) {
			dix = bytes * (width * y + x);
			if (has_alpha)
				dest[dix + nb] = src[dix + nb];
			
			for (b = 0; b < nb; b++) {
				sum = 0.0;
				fact = 0.0;
				src_db = src + dix + b;
				
				offset = rowstride * (y - numrad) + bytes * (x - numrad);
				
				for (i = 1 - numrad; i < numrad; i++) {
					offset += bytes;
					if (x + i < 0 || x + i >= width)
						continue;
					
					six = offset;
					m = mat[ABS(i)];
					
					src_b = src + six + b;
					
					for (j = 1 - numrad; j < numrad; j++) {
						src_b += rowstride;
						six += rowstride;
						
						if (y + j < 0 || y + j >= height)
							continue;
						
						tmp = *src_db - *src_b;
						if (tmp > maxdelta || tmp < -maxdelta)
							continue;
						
						d = m[ABS(j)];
						if (has_alpha) {
							if (!src[six + nb])
								continue;
							alpha = (double) src[six + nb] / 255.0;
							d *= alpha;
                        }
						sum += d * *src_b;
						fact += d;
                    }
                }
				if (fact == 0.0)
					dest[dix + b] = *src_db;
				else
					dest[dix + b] = sum / fact;
            }
        }
		
		if (cancel) {
			return;
		}
		
		if ((y % 5) == 0 && !preview_mode) {
			// NSLog(@"GaussSelectiveBlur Progress: %f", (float) y / height);
			NSString *value = [NSString stringWithFormat:@"%i%%", (int) (100 * y / height)];
			[[NSNotificationCenter defaultCenter] postNotificationName:FPSNotification
																object:nil
															  userInfo:[NSDictionary dictionaryWithObject:value
																								   forKey:@"value"]];			
		}
    }
}


static void init_matrix (float radius, float **mat, int num) {
	int dx, dy;
	float sd, c1, c2;
	
	/* This formula isn't really correct, but it'll do */
	sd = radius / 3.329042969;
	c1 = 1.0 / sqrt (2.0 * G_PI * sd);
	c2 = -2.0 * (sd * sd);
	
	for (dy = 0; dy < num; dy++) {
		for (dx = dy; dx < num; dx++) {
			mat[dx][dy] = c1 * exp ((dx * dx + dy * dy)/ c2);
			mat[dy][dx] = mat[dx][dy];
        }
    }
}

- (FilterImage*)selectiveGaussBlurWithImage:(FilterImage*)input {

	uint8_t *src_base;
	uint8_t *dest;
	
	int width, height;
	int bytes;
	int i;
	int numrad;
	float **mat;
	bool has_alpha;	
	
	width = input.width;
	height = input.height;
		
	bytes = 4; //RGB_
	has_alpha = 1;
	
	src_base = input.imageData;
	FilterImage *output = [[FilterImage alloc] initWithWidth:width andHeight:height];
	dest = output.imageData;
	
	numrad = (int) (radius + 1.0);
	
	mat = g_new (float *, numrad);
	for (i = 0; i < numrad; i++)
		mat[i] = g_new (float, numrad);

	init_matrix(radius, mat, numrad);

	matrixmult (src_base, dest, width, height, mat, numrad, bytes, has_alpha, maxDelta, preview);

	/* free up buffers */
	for (i = 0; i < numrad; i++)
		free (mat[i]);
	free (mat);
	
	if (isCancel) {
		[output release];
		self.isCancel = NO;
		return nil;
	}
	
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
	NSIndexPath *indexPath = [data	objectForKey:@"indexPath"];
	NSString *notificationName = [data objectForKey:@"notificationName"];
	
	NSNumber *radius_ = [data objectForKey:@"radius"];
	NSNumber *maxDelta_ = [data objectForKey:@"maxDelta"];
	preview = [[data objectForKey:@"preview"] boolValue];
	
	if (radius_ != nil && maxDelta_ != nil) {
		radius = [radius_ floatValue];
		maxDelta = [maxDelta_ intValue];
	} else {
		radius = 5.0;
		maxDelta = 50;
	}

	FilterImage *output = [self selectiveGaussBlurWithImage:input];
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:output, @"image", indexPath, @"indexPath", nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:info];

	self.isCancel = NO;
	
	[pool release];	
}

- (void)setIsCancel:(BOOL)val {
	isCancel = val;
	cancel = val;
}

- (BOOL)isCancel {
    return isCancel;
}


@end
