//
//  GlassTileFilterSettingsView.h
//  FiltersTest
//
//  Created by maxim on 28.01.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettisngsViewBase.h"

@interface GlassTileFilterSettingsView : SettisngsViewBase {
	int     xblock;
	int     yblock;

	UISlider *xblockSlider;
	UISlider *yblockSlider;
	
	UILabel *xblockLabel;
	UILabel *yblockLabel;
}

@end
