//
//  RedEyeRemovalFilter.h
//  FiltersTest
//
//  Created by maxim on 14.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FilterImage;
@interface RedEyeRemovalFilter : NSObject {
	BOOL isCancel;
	BOOL preview;
}

@property BOOL isCancel;

+ (RedEyeRemovalFilter*)sharedFilter;

- (FilterImage*)remove_redeye:(FilterImage*)input;

@end
