//
//  FilterImage.h
//  PhotoLibrary
//
//  Created by maxim on 18.03.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface FilterImage : NSObject {

	uint8_t *imageData;
	int width;
	int height;
}

@property uint8_t *imageData;
@property int width;
@property int height;

- (FilterImage*)initWithWidth:(int)_width andHeight:(int)_height;
- (FilterImage*)initWithUIImage:(UIImage*)srcImage width:(int)_width andHeight:(int)_height;

- (UIImage*)UIImage;

@end
