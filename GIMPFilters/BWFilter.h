//
//  BWFilter.h
//  FiltersTest
//
//  Created by maxim on 01.02.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BWFilter : NSObject {
	BOOL preview;

}

+ (id)sharedFilter;
@end
