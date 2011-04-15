//
//  EmbossFilter.h
//  FiltersTest
//
//  Created by maxim on 15.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FilterImage;
@interface EmbossFilter : NSObject {
	BOOL isCancel;
	BOOL preview;
}

@property BOOL isCancel;

+ (EmbossFilter*)sharedFilter;

- (FilterImage*)emboss:(FilterImage*)input;

@end
