//
//  EmbossFilter.m
//  FiltersTest
//
//  Created by maxim on 15.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import "EmbossFilter.h"
#import "FilterImage.h"
#import "Definitions.h"
#import "Functions.h"


@implementation EmbossFilter

@synthesize isCancel;

enum
{
	FUNCTION_BUMPMAP = 0,
	FUNCTION_EMBOSS  = 1
};

typedef struct {
	double  azimuth;
	double  elevation;
	int   depth;
	int   embossp;
} piArgs;

static piArgs evals =
{
	30.0,    /* azimuth   */
	45.0,    /* elevation */
	20,      /* depth     */
	1        /* emboss    */
};

struct embossFilter {
	double Lx;
	double Ly;
	double Lz;
	double Nz;
	double Nz2;
	double NzLz;
	double bg;
} static Filter;


#define DtoR(d) ((d)*(G_PI/(double)180))

#define pixelScale 255.9

static void emboss_init (double azimuth, double elevation, unsigned short width45) {
	/*
	 * compute the light vector from the input parameters.
	 * normalize the length to pixelScale for fast shading calculation.
	 */
	Filter.Lx = cos (azimuth) * cos (elevation) * pixelScale;
	Filter.Ly = sin (azimuth) * cos (elevation) * pixelScale;
	Filter.Lz = sin (elevation) * pixelScale;
	
	/*
	 * constant z component of image surface normal - this depends on the
	 * image slope we wish to associate with an angle of 45 degrees, which
	 * depends on the width of the filter used to produce the source image.
	 */
	Filter.Nz = (6 * 255) / width45;
	Filter.Nz2 = Filter.Nz * Filter.Nz;
	Filter.NzLz = Filter.Nz * Filter.Lz;
	
	/* optimization for vertical normals: L.[0 0 1] */
	Filter.bg = Filter.Lz;
}


/*
 * ANSI C code from the article
 * "Fast Embossing Effects on Raster Image Data"
 * by John Schlag, jfs@kerner.com
 * in "Graphics Gems IV", Academic Press, 1994
 *
 *
 * Emboss - shade 24-bit pixels using a single distant light source.
 * Normals are obtained by differentiating a monochrome 'bump' image.
 * The unary case ('texture' == NULL) uses the shading result as output.
 * The binary case multiples the optional 'texture' image by the shade.
 * Images are in row major order with interleaved color components (rgbrgb...).
 * E.g., component c of pixel x,y of 'dst' is dst[3*(y*width + x) + c].
 *
 */

static void emboss_row (const uint8_t *src,
						const uint8_t *texture,
						uint8_t       *dst,
						uint          width,
						uint          bypp,
						bool          alpha)
{
	const uint8_t *s[3];
	double        M[3][3];
	int           x, bytes;
	
	/* mung pixels, avoiding edge pixels */
	s[0] = src;
	s[1] = s[0] + (width * bypp);
	s[2] = s[1] + (width * bypp);
	dst += bypp;
	
	bytes = (alpha) ? bypp - 1 : bypp;
	
	if (texture)
		texture += (width + 1) * bypp;
	
	for (x = 1; x < width - 1; x++) {
		double a;
		long   Nx, Ny, NdotL;
		int    shade, b;
		int    i, j;
		
		for (i = 0; i < 3; i++)
			for (j = 0; j < 3; j++)
				M[i][j] = 0.0;
		
		for (b = 0; b < bytes; b++) {
			for (i = 0; i < 3; i++)
				for (j = 0; j < 3; j++) {
					if (alpha)
						a = s[i][j * bypp + bytes] / 255.0;
					else
						a = 1.0;
					
					M[i][j] += a * s[i][j * bypp + b];
				}
        }
		
		Nx = M[0][0] + M[1][0] + M[2][0] - M[0][2] - M[1][2] - M[2][2];
		Ny = M[2][0] + M[2][1] + M[2][2] - M[0][0] - M[0][1] - M[0][2];
		
		/* shade with distant light source */
		if ( Nx == 0 && Ny == 0 )
			shade = Filter.bg;
		else if ( (NdotL = Nx * Filter.Lx + Ny * Filter.Ly + Filter.NzLz) < 0 )
			shade = 0;
		else
			shade = NdotL / sqrt(Nx*Nx + Ny*Ny + Filter.Nz2);
		
		/* do something with the shading result */
		if (texture) {
			for (b = 0; b < bytes; b++)
				*dst++ = (*texture++ * shade) >> 8;
			
			if (alpha) {
				*dst++ = s[1][bypp + bytes]; /* preserve the alpha */
				texture++;
            }
        } else {
			for (b = 0; b < bytes; b++)
				*dst++ = shade;
			
			if (alpha)
				*dst++ = s[1][bypp + bytes]; /* preserve the alpha */
        }
		
		for (i = 0; i < 3; i++)
			s[i] += bypp;
    }
	
	if (texture)
		texture += bypp;
}

static EmbossFilter *sharedFilter = nil;

+ (EmbossFilter*)sharedFilter {
	@synchronized (self) {
		if (sharedFilter == nil) {
			sharedFilter = [[self alloc] init];
		}
	}
	return sharedFilter;
}



- (FilterImage*) emboss:(FilterImage*)input {
	int          y;
	int          x1, y1, x2, y2;
	int          width, height;
	int          bypp, rowsize;
	bool		 has_alpha;
	uint8_t      *srcbuf, *dstbuf;
	
	uint8_t *src;
	uint8_t *dst;

	if (preview) {
		x1 = input.width / 2;
		y1 = 0;
		
//		x2 = x1 + (input.width / 2);
		y2 = y1 + input.height;
		
		width = input.width / 2;
		height = input.height;
	}
    else {
		x1 = 0;
		y1 = 0;
		
		x2 = input.width;
		y2 = input.height;
		
		/* expand the bounds a little */
		x1 = MAX (0, x1 - evals.depth);
		y1 = MAX (0, y1 - evals.depth);
		x2 = MIN (input.width, x2 + evals.depth);
		y2 = MIN (input.height, y2 + evals.depth);
		
		width = x2 - x1;
		height = y2 - y1;		
	}

	src = input.imageData;
	FilterImage *output = [[FilterImage alloc] initWithWidth:input.width andHeight:input.height];
	dst = output.imageData;
	
	
	bypp = 4; // RGBA
	has_alpha = 1;

	rowsize = width * bypp;

	srcbuf = g_new0 (uint8_t, rowsize * 3);
	dstbuf = g_new0 (uint8_t, rowsize);
	
	emboss_init (DtoR(evals.azimuth), DtoR(evals.elevation), evals.depth);

	/* first row */
	get_rect(src, bypp, x1, y1, width, 3, srcbuf, input.width);
	
	memcpy (srcbuf, srcbuf + rowsize, rowsize);
	emboss_row (srcbuf, evals.embossp ? NULL : srcbuf, dstbuf, width, bypp, has_alpha);

	set_row(dstbuf, bypp, x1, y1, width, dst, output.width);
	
	/* middle rows */
	for (y = 0; y < height - 2; y++) {
		
		if (isCancel) {
			[output release];
			free(srcbuf);
			free(dstbuf);
			isCancel = NO;
			return nil;
		}
		
		if (!preview) {
			NSString *value = [NSString stringWithFormat:@"%i%%", (int) (100 * y / height)];
			[[NSNotificationCenter defaultCenter] postNotificationName:FPSNotification
																object:nil
															  userInfo:[NSDictionary dictionaryWithObject:value
																								   forKey:@"value"]];
		}
		
		get_rect(src, bypp, x1, y1 + y, width, 3, srcbuf, input.width);

		emboss_row (srcbuf, evals.embossp ? NULL : srcbuf, dstbuf, width, bypp, has_alpha);
		
		set_row(dstbuf, bypp, x1, y1 + y + 1, width, dst, output.width);
    }
	
	/* last row */
	get_rect(src, bypp, x1, y2 - 3, width, 3, srcbuf, input.width);
	
	memcpy (srcbuf + rowsize * 2, srcbuf + rowsize, rowsize);
	emboss_row (srcbuf, evals.embossp ? NULL : srcbuf, dstbuf, width, bypp, has_alpha);
	
	set_row(dstbuf, bypp, x1, y2 - 1, width, dst, output.width);
	
	free(srcbuf);
	free(dstbuf);
	
	if (preview) {
		uint8_t *srcrect = g_new0 (uint8_t, rowsize * height);
		get_rect(src, bypp, 0, 0, width, height, srcrect, input.width);
		set_rect(srcrect, bypp, 0, 0, width, height, dst, output.width);
		free(srcrect);
	}
	
	
	return [output autorelease];
}

- (void)run:(NSDictionary*)data {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	FilterImage *input = [data objectForKey:@"image"];
	NSIndexPath *indexPath = [data objectForKey:@"indexPath"];
	NSString *notificationName = [data objectForKey:@"notificationName"];
	
	NSNumber *azimuth = [data objectForKey:@"azimuth"];
	NSNumber *elevation = [data objectForKey:@"elevation"];
	NSNumber *depth = [data objectForKey:@"depth"];
	NSNumber *embossp = [data objectForKey:@"embossp"];
	preview = [[data objectForKey:@"preview"] boolValue];
	
	if (azimuth != nil && elevation != nil && depth != nil && embossp != nil) {
		evals.azimuth = [azimuth doubleValue];
		evals.elevation = [elevation doubleValue];
		evals.depth = [depth intValue];
		evals.embossp = [embossp intValue];
	}
    else { // default values
		evals.azimuth = 30.0;
		evals.elevation = 45.0;
		evals.depth = 20;
		evals.embossp = 1;
	}
	
	FilterImage *output = [self emboss:input];
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:output, @"image", indexPath, @"indexPath", nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:info];

	self.isCancel = NO;

	[pool release];
}

@end
