//
//  SharpenFilter.h
//  FiltersTest
//
//  Created by maxim on 12.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FilterImage;
@interface SharpenFilter : NSObject {
	BOOL isCancel;
	BOOL preview;
}

@property BOOL isCancel;

+ (SharpenFilter*)sharedFilter;

- (FilterImage*)sharpen:(FilterImage*)input;

@end
