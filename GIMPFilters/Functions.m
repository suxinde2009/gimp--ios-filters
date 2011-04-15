//
//  Functions.m
//  FiltersTest
//
//  Created by maxim on 20.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import "Functions.h"

//gimp_pixel_fetcher_get_pixel
/**
 * get_pixel:
 * @src:		a pointer to source.
 * @img_bpp:	bytes per pixel of the image.
 * @x:			the x coordinate of a pixel.
 * @y:			the y coordinage of a pixel.
 * @width:		width of src region.
 * @pixel:		pointer to store the pixel value.
 **/
void get_pixel(uint8_t *src, int img_bpp, int x, int y, int width, uint8_t *pixel) {
	int start = x * img_bpp + (y * width * img_bpp);
	memcpy(pixel, src += start, img_bpp);
}


//gimp_pixel_rgn_get_row
/** 
 * get_row:
 * @src:		a pointer to source.
 * @img_bpp:	bytes per pixel of the image.
 * @x:			the x coordinate of a first pixel.
 * @y:			the y coordinate of a first pixel.
 * @width:		the number of pixels to get.
 * @dest:		a pointer to desstination array.
 **/
void get_row(uint8_t *src, int img_bpp, int x, int y, int width, uint8_t *dest, int srcRegionWidth) {
	int start = x * img_bpp + (y * srcRegionWidth * img_bpp);
	memcpy(dest, src += start, width * img_bpp);
}


//gimp_pixel_rgn_set_row
/** 
 * set_row:
 * @src:		a pointer to source.
 * @img_bpp:	bytes per pixel of the image.
 * @x:			the x coordinate of a first pixel.
 * @y:			the y coordinate of a first pixel.
 * @width:		the number of pixels to set.
 * @dest:		a pointer to desstination array.
 **/
void set_row(uint8_t *src, int img_bpp, int x, int y, int width, uint8_t *dest, int destRegionWidth) {
	int start = x * img_bpp + (y * destRegionWidth * img_bpp);
	memcpy(dest += start, src, width * img_bpp);
}


//gimp_pixel_rgn_get_rect
/** 
 * get_rect:
 * @src:			a pointer to source.
 * @img_bpp:		bytes per pixel of the image.
 * @x:				the x coordinate of a first pixel.
 * @y:				the y coordinate of a first pixel.
 * @width:			width of the rectangle.
 * @height:			height of the recttangle.
 * @dest:			a pointer to desstination array.
 * @srcRegionWidth: a width of source region.
 **/
void get_rect(uint8_t *src, int img_bpp, int x, int y, int width, int height, uint8_t *dest, int srcRegionWidth) {
	for (int j = 0; j < height; j++) {
		int start = x * img_bpp + (y * srcRegionWidth * img_bpp) + (j * srcRegionWidth * img_bpp);
		for (int i = 0; i < width * img_bpp; i++) {
			dest[i + j * width * img_bpp] = src[start];
			start++;
		}
	}
}

void set_rect(uint8_t *src, int img_bpp, int x, int y, int width, int height, uint8_t *dest, int destRegionWidth) {
	for (int j = 0; j < height; j++) {
		int start = x * img_bpp + (y * destRegionWidth * img_bpp) + (j * destRegionWidth * img_bpp);
		for (int i = 0; i < width * img_bpp; i++) {
			dest[start] = src[i + j * width * img_bpp];
			start++;
		}
	}
}