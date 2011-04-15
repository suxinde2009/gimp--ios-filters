//
//  SoftGlowFilter.h
//  FiltersTest
//
//  Created by maxim on 18.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FilterImage;
@interface SoftGlowFilter : NSObject {
	BOOL isCancel;
	BOOL preview;
}

@property BOOL isCancel;

+ (SoftGlowFilter*)sharedFilter;

- (FilterImage*)softglow:(FilterImage*)input;

@end
