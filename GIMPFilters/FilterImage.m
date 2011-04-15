//
//  FilterImage.m
//  PhotoLibrary
//
//  Created by maxim on 18.03.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import "FilterImage.h"

static inline double radians (double degrees) {return degrees * M_PI/180;}

@implementation FilterImage

@synthesize imageData;
@synthesize width;
@synthesize height;


- (FilterImage*)initWithWidth:(int)_width andHeight:(int)_height {
	self.imageData = (uint8_t*) malloc(_width * _height * sizeof(uint32_t));
	self.width = _width;
	self.height = _height;
	return self;
}

- (FilterImage*)initWithUIImage:(UIImage*)srcImage width:(int)_width andHeight:(int)_height {

	if (srcImage.imageOrientation == UIImageOrientationRight || srcImage.imageOrientation == UIImageOrientationLeft) {
		width = _height;
		height = _width;
	} else {
		width = _width;
		height = _height;
	}
	
	self.imageData = (uint8_t*) calloc(width * height * sizeof(uint32_t), 1);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

	CGContextRef context;

	context = CGBitmapContextCreate(self.imageData, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGImageAlphaNoneSkipLast);
	CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
	CGContextSetShouldAntialias(context, NO);
	
	if (srcImage.imageOrientation == UIImageOrientationLeft) {
		CGContextRotateCTM (context, radians(90));
		CGContextTranslateCTM (context, 0, -_height);
		
	}
    else if (srcImage.imageOrientation == UIImageOrientationRight) {
		CGContextRotateCTM (context, radians(-90));
		CGContextTranslateCTM (context, -_width, 0);
		
	}
    else if (srcImage.imageOrientation == UIImageOrientationUp) {
		
	}
    else if (srcImage.imageOrientation == UIImageOrientationDown) {
		CGContextTranslateCTM (context, _width, _height);
		CGContextRotateCTM (context, radians(-180.));
	}
	

	CGContextDrawImage(context, CGRectMake(0, 0, _width, _height), [srcImage CGImage]);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	
	return self;
}

- (UIImage*)UIImage {
	
	// create a UIImage
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context;
	context = CGBitmapContextCreate(imageData, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGImageAlphaNoneSkipLast);
	CGImageRef image = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	UIImage *resultUIImage = [UIImage imageWithCGImage:image];
	CGImageRelease(image);
	
	return resultUIImage;	
}

- (void)dealloc {
	free(self.imageData);
	[super dealloc];
}

@end
