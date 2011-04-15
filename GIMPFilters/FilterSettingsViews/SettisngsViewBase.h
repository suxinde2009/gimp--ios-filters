//
//  SettisngsViewBase.h
//  FiltersTest
//
//  Created by maxim on 03.02.10.
//  Copyright 2010 smile2mobile. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettisngsViewBase : UIView {
	UIButton *okButton;
	UIButton *cancelButton;
	
	id target;
	SEL action;
}

- (void)setTarget:(id)trg andAction:(SEL)act;
- (void)dissapear;

- (NSMutableDictionary*)settingsDictionary;

@end
