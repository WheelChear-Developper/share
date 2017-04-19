//
//  CustomUIAlertController.m
//  Satisfa
//
//  Created by M.Amatani on 2017/02/27.
//  Copyright © 2017年 Mobile Innovation. All rights reserved.
//

#import "CustomUIAlertController.h"

@implementation CustomUIAlertController

-(CustomUIAlertController*)init {

    self = [super init];
    if(self)
    {
        _messageAlign = NSTextAlignmentCenter;
        _messageColor = nil;
        _messageFont = nil;

        _titleAlign = NSTextAlignmentCenter;
        _titleColor = nil;
        _titleFont = nil;

        _tintColor = nil;
    }
    return self;
}

- (void)viewWillLayoutSubviews {

    [super viewWillLayoutSubviews];

    NSArray *viewArray = [self viewArrayWhichHasUILabel:[self view]];
    UILabel *alertTitle = viewArray[0];
    UILabel *alertMessage = viewArray[1];


    alertTitle.textAlignment = _titleAlign;
    if(_titleColor)
    {
        alertTitle.textColor = _titleColor;
    }
    if(_titleFont)
    {
        alertTitle.font = _titleFont;
    }



    alertMessage.textAlignment = _messageAlign;
    if(_messageColor)
    {
        alertMessage.textColor = _messageColor;
    }
    if(_messageFont)
    {
        alertMessage.font = _messageFont;
    }


    if(_tintColor)
    {
        self.view.tintColor = _tintColor;
    }
}

- (NSArray *)viewArrayWhichHasUILabel:(UIView *)root {
    
    NSLog(@"%@", root.subviews);
    NSArray *_subviews = nil;

    for (UIView *v in root.subviews) {
        if ([v isKindOfClass:[UILabel class]]) {
            _subviews = root.subviews;
            return _subviews;
        }
        _subviews = [self viewArrayWhichHasUILabel:v];
        if (_subviews) {
            break;
        }
    }
    return _subviews;
}

@end
