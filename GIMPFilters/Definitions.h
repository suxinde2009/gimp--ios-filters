/*
 *  Definitions.h
 *  FiltersTest
 *
 *  Created by maxim on 14.01.10.
 *  Copyright 2010 smile2mobile. All rights reserved.
 *
 */

/* Provide macros for easily allocating memory. The macros
 *  will cast the allocated memory to the specified type
 *  in order to avoid compiler warnings. (Makes the code neater).
 */

#  define g_new(type, count)	  \
((type *) malloc ((unsigned) sizeof (type) * (count)))
#  define g_new0(type, count)	  \
((type *) calloc ((unsigned) sizeof (type) * (count), 1))

#define CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))
#define CLAMP0255(a)  CLAMP(a,0,255)

#define SQR(x) ((x) * (x))

#define ROUND(x) ((int) ((x) + 0.5))

#define gimp_deg_to_rad(angle) ((angle) * (2.0 * G_PI) / 360.0)

#define G_PI    3.14159265358979323846E0
#define G_PI_2  1.57079632679489661923

#define SAFE_RELEASE(a) { if(a){ [(a) release]; (a) = nil; } }

enum Filters {
	FiltersBW,
	FiltersRedEyeRemoval,
	FiltersSharpen,
	FiltersEmboss,
	FiltersSoftGlow,
	FiltersGlassTile,
	FiltersMotionBlur,
	FiltersGaussSelectiveBlur,
	FiltersCount
};
