//
//  GlassTileFilter.h
//  FiltersTest
//
//  Created by maxim on 19.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FilterImage;
@interface GlassTileFilter : NSObject {
	BOOL isCancel;
	BOOL preview;
}

@property BOOL isCancel;

+ (GlassTileFilter*)sharedFilter;

- (FilterImage*)glasstile:(FilterImage*)input;

@end
