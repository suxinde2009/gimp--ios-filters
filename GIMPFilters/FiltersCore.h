//
//  FiltersCore.h
//  FiltersTest
//
//  Created by maxim on 17.02.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FiltersCore : NSObject {

}

+ (NSString*)getFilterNameById:(int)filterID;
+ (id)getFilterByID:(int)filterID;

@end
