//
//  InputCheck.h
//  Satisfa
//
//  Created by M.Amatani on 2017/02/21.
//  Copyright © 2017年 Mobile Innovation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InputCheck : NSObject

+ (BOOL) chkAlphabet:(NSString *)checkString;
+ (BOOL) chkAlphaNumeric:(NSString *)checkString;
+ (BOOL) chkNumeric:(NSString *)checkString;
+ (BOOL) chkAlphaNumericSymbol:(NSString *)checkString;
+ (BOOL) chkMultiByteChar:(NSString *)checkString;


@end
