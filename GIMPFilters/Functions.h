//
//  Functions.h
//  FiltersTest
//
//  Created by maxim on 20.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

void get_pixel(uint8_t *src, int img_bpp, int x, int y, int width, uint8_t *pixel);

void get_row(uint8_t *src, int img_bpp, int x, int y, int width, uint8_t *dest, int srcRegionWidth);

void set_row(uint8_t *src, int img_bpp, int x, int y, int width, uint8_t *dest, int destRegionWidth);

void get_rect(uint8_t *src, int img_bpp, int x, int y, int width, int height, uint8_t *dest, int srcRegionWidth);

void set_rect(uint8_t *src, int img_bpp, int x, int y, int width, int height, uint8_t *dest, int destRegionWidth);