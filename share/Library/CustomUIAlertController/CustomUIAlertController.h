//
//  CustomUIAlertController.h
//  Satisfa
//
//  Created by M.Amatani on 2017/02/27.
//  Copyright © 2017年 Mobile Innovation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomUIAlertController : UIAlertController

@property (nonatomic) UIColor *messageColor;
@property (nonatomic) UIFont  *messageFont;
@property (nonatomic) NSTextAlignment messageAlign;

@property (nonatomic) UIColor *titleColor;
@property (nonatomic) UIFont  *titleFont;
@property (nonatomic) NSTextAlignment titleAlign;

@property (nonatomic) UIColor *tintColor;

@end
