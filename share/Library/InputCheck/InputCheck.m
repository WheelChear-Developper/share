//
//  InputCheck.m
//  Satisfa
//
//  Created by M.Amatani on 2017/02/21.
//  Copyright © 2017年 Mobile Innovation. All rights reserved.
//

#import "InputCheck.h"

@implementation InputCheck

// アルファベットのみか
+ (BOOL)chkAlphabet:(NSString *)checkString
{
    @autoreleasepool
    {
        // アルファベットのみで構成されるキャラクタセット
        // 範囲を指定する方法でキャラクタセットに文字を追加している
        NSMutableCharacterSet *alCharSet;
        alCharSet = [[NSMutableCharacterSet alloc] init];
        // 'a'から'z'を追加する
        [alCharSet addCharactersInRange:NSMakeRange('a', 26)];
        // 'A'から'Z'を追加する
        [alCharSet addCharactersInRange:NSMakeRange('A', 26)];

        //alCharSet = [[NSCharacterSet alphanumericCharacterSet] mutableCopy]; // 英数字;
        //NSCharacterSet *digitCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        bool ret = [self chkCompareString:checkString baseString:alCharSet];
        return ret;

    }
}

// アルファベットと数字のみか
+ (BOOL)chkAlphaNumeric:(NSString *)checkString
{
    @autoreleasepool
    {
        // アルファベットと数字のみで構成されるキャラクタセット
        NSCharacterSet *alnumCharSet = [NSCharacterSet alphanumericCharacterSet]; // 英数字;
        bool ret = [self chkCompareString:checkString baseString:alnumCharSet];
        return ret;
    }
}

// アルファベットと数字と記号のみか
+ (BOOL)chkAlphaNumericSymbol:(NSString *)checkString
{
    @autoreleasepool
    {
        // アルファベットと数字のみで構成されるキャラクタセット
        NSMutableCharacterSet *muCharSet = [[NSCharacterSet alphanumericCharacterSet] mutableCopy]; // 英数字;
        // 'A'から'Z'を追加する
        [muCharSet addCharactersInString:@"$\"!~&=#[]._-+`|{}?%^*/'@-/:;(),"];

        bool ret = [self chkCompareString:checkString baseString:muCharSet];
        return ret;
    }
}

// 全角文字が存在するか
+ (BOOL)chkMultiByteChar:(NSString *)checkString
{
    if([checkString canBeConvertedToEncoding:NSASCIIStringEncoding]) {
        return YES;
    }
    //NSLog(@"全角文字が含まれています。");
    return NO;
}

// 数字のみか （引数は文字列なので注意）
+ (BOOL)chkNumeric:(NSString *)checkString
{
    @autoreleasepool
    {
        NSCharacterSet *digitCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        bool ret = [self chkCompareString:checkString baseString:digitCharSet];
        return ret;
    }
}
+ (BOOL)chkCompareString:(NSString *)checkString baseString:(NSCharacterSet *)baseString
{
    @autoreleasepool
    {
        NSScanner *aScanner = [NSScanner localizedScannerWithString:checkString];
        // NSScannerはﾃﾞﾌｫﾙﾄでは前後のｽﾍﾟｰｽなどを読み飛ばしてくれるのだが､あえて-setCharactersToBeSkipped:でnilを渡して抑制している｡
        [aScanner setCharactersToBeSkipped:nil];

        [aScanner scanCharactersFromSet:baseString intoString:NULL];
        return [aScanner isAtEnd];
    }
}

@end
