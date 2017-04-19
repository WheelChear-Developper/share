//
//  Configuration.m
//
//  Created by MacServer on 2015/12/04.
//  Copyright © 2015年 Mobile Innovation, LLC. All rights reserved.
//

#import "Configuration.h"

@implementation Configuration

#pragma mark - Synchronize
+ (void)synchronize
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UrlSchemeStart
static NSString *CONFIGURATION_URLSCHMESTART = @"Configuration.UrlSchemeStart";
+ (BOOL)getUrlSchemeStart
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{CONFIGURATION_URLSCHMESTART : @(NO)}];
    return [userDefaults boolForKey:CONFIGURATION_URLSCHMESTART];
}
+ (void)setUrlSchemeStart:(BOOL)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:CONFIGURATION_URLSCHMESTART];
}

#pragma mark - FirstUpdateKeywordSetup
static NSString *CONFIGURATION_FIRSTUPDATEKEYWORDSETUP = @"Configuration.FirstUpdateKeywordSetup";
+ (BOOL)getFirstUpdateKeywordSetup
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{CONFIGURATION_FIRSTUPDATEKEYWORDSETUP : @(NO)}];
    return [userDefaults boolForKey:CONFIGURATION_FIRSTUPDATEKEYWORDSETUP];
}
+ (void)setFirstUpdateKeywordSetup:(BOOL)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:CONFIGURATION_FIRSTUPDATEKEYWORDSETUP];
}

#pragma mark - AuthenticationID
static NSString *CONFIGURATION_AUTHENTICATIONID = @"Configuration.AuthenticationID";
+ (NSString*)getAuthenticationID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{CONFIGURATION_AUTHENTICATIONID : @("")}];
    return [userDefaults stringForKey:CONFIGURATION_AUTHENTICATIONID];
}
+ (void)setAuthenticationID:(NSString*)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:CONFIGURATION_AUTHENTICATIONID];
}

#pragma mark - UpdateKeyword
static NSString *CONFIGURATION_UPDATEKEYWORD = @"Configuration.UpdateKeyword";
+ (NSString*)getUpdateKeyword
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{CONFIGURATION_UPDATEKEYWORD : @("")}];
    return [userDefaults stringForKey:CONFIGURATION_UPDATEKEYWORD];
}
+ (void)setUpdateKeyword:(NSString*)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:CONFIGURATION_UPDATEKEYWORD];
}

#pragma mark - CompanyCode
static NSString *CONFIGURATION_COMPANYCODE = @"Configuration.CompanyCode";
+ (NSString*)getCompanyCode
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{CONFIGURATION_COMPANYCODE : @("")}];
    return [userDefaults stringForKey:CONFIGURATION_COMPANYCODE];
}
+ (void)setCompanyCode:(NSString*)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:CONFIGURATION_COMPANYCODE];
}

#pragma mark - ShopCode
static NSString *CONFIGURATION_SHOPCODE = @"Configuration.ShopCode";
+ (NSString*)getShopCode
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{CONFIGURATION_SHOPCODE : @("")}];
    return [userDefaults stringForKey:CONFIGURATION_SHOPCODE];
}
+ (void)setShopCode:(NSString*)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:CONFIGURATION_SHOPCODE];
}

#pragma mark - ShopName
static NSString *CONFIGURATION_SHOPNAME = @"Configuration.ShopName";
+ (NSString*)getShopName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{CONFIGURATION_SHOPNAME : @("")}];
    return [userDefaults stringForKey:CONFIGURATION_SHOPNAME];
}
+ (void)setShopName:(NSString*)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:CONFIGURATION_SHOPNAME];
}

#pragma mark - PointGrantRate
static NSString *CONFIGURATION_POINTGRANTRATE = @"Configuration.PointGrantRate";
+ (float)getPointGrantRate
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{CONFIGURATION_POINTGRANTRATE : @(0)}];
    return [userDefaults floatForKey:CONFIGURATION_POINTGRANTRATE];
}
+ (void)setPointGrantRate:(float)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:value forKey:CONFIGURATION_POINTGRANTRATE];
}

#pragma mark - PointAdjustmentSetting
static NSString *CONFIGURATION_POINTADJUSTMENTSETTING = @"Configuration.PointAdjustmentSetting";
+ (BOOL)getPointAdjustmentSetting
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{CONFIGURATION_POINTADJUSTMENTSETTING : @(NO)}];
    return [userDefaults boolForKey:CONFIGURATION_POINTADJUSTMENTSETTING];
}
+ (void)setPointAdjustmentSetting:(BOOL)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:CONFIGURATION_POINTADJUSTMENTSETTING];
}
















#pragma mark - DeviceTokenKey
static NSString *CONFIGURATION_DEVICETOKENKEY = @"Configuration.DeviceTokenKey";
+ (NSString*)getDeviceTokenKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{CONFIGURATION_DEVICETOKENKEY : @("")}];
    return [userDefaults stringForKey:CONFIGURATION_DEVICETOKENKEY];
}
+ (void)setDeviceTokenKey:(NSString*)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:CONFIGURATION_DEVICETOKENKEY];
}

#pragma mark - SessionTokenKey
static NSString *CONFIGURATION_SESSIONTOKENKEY = @"Configuration.SessionTokenKey";
+ (NSString*)getSessionTokenKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{CONFIGURATION_SESSIONTOKENKEY : @("")}];
    return [userDefaults stringForKey:CONFIGURATION_SESSIONTOKENKEY];
}
+ (void)setSessionTokenKey:(NSString*)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:CONFIGURATION_SESSIONTOKENKEY];
}

#pragma mark - ScreenWidth
static NSString *CONFIGURATION_SCREENWIDTH = @"Configuration.ScreenWidth";
+ (long)getScreenWidth
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{CONFIGURATION_SCREENWIDTH : @(0)}];
    return [userDefaults integerForKey:CONFIGURATION_SCREENWIDTH];
}
+ (void)setScreenWidth:(long)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:value forKey:CONFIGURATION_SCREENWIDTH];
}

#pragma mark - ScreenHeight
static NSString *CONFIGURATION_SCREENHEIGHT = @"Configuration.ScreenHeight";
+ (long)getScreenHeight
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{CONFIGURATION_SCREENHEIGHT : @(0)}];
    return [userDefaults integerForKey:CONFIGURATION_SCREENHEIGHT];
}
+ (void)setScreenHeight:(long)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:value forKey:CONFIGURATION_SCREENHEIGHT];
}

#pragma mark - IDSave
static NSString *CONFIGURATION_IDSAVE = @"Configuration.IDSave";
+ (BOOL)getIDSave
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{CONFIGURATION_IDSAVE : @(NO)}];
    return [userDefaults boolForKey:CONFIGURATION_IDSAVE];
}
+ (void)setIDSave:(BOOL)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:CONFIGURATION_IDSAVE];
}

#pragma mark - ID
static NSString *CONFIGURATION_ID = @"Configuration.ID";
+ (NSString*)getID
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{CONFIGURATION_ID : @("")}];
    return [userDefaults stringForKey:CONFIGURATION_ID];
}
+ (void)setID:(NSString*)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:CONFIGURATION_ID];
}

#pragma mark - Password
static NSString *CONFIGURATION_PASSWORD = @"Configuration.Password";
+ (NSString*)getPassword
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{CONFIGURATION_PASSWORD : @("")}];
    return [userDefaults stringForKey:CONFIGURATION_PASSWORD];
}
+ (void)setPassword:(NSString*)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:CONFIGURATION_PASSWORD];
}

#pragma mark - PushSetting_before_attendance
static NSString *CONFIGURATION_PUSHSETTING_BEFORE_ATTENDANCE = @"Configuration.PushSetting_before_attendance";
+ (BOOL)getPushSetting_before_attendance
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{CONFIGURATION_PUSHSETTING_BEFORE_ATTENDANCE : @(NO)}];
    return [userDefaults boolForKey:CONFIGURATION_PUSHSETTING_BEFORE_ATTENDANCE];
}
+ (void)setPushSetting_before_attendance:(BOOL)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:CONFIGURATION_PUSHSETTING_BEFORE_ATTENDANCE];
}

#pragma mark - PushSetting_empty
static NSString *CONFIGURATION_PUSHSETTING_EMPTY = @"Configuration.PushSetting_empty";
+ (BOOL)getPushSetting_empty
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{CONFIGURATION_PUSHSETTING_EMPTY : @(NO)}];
    return [userDefaults boolForKey:CONFIGURATION_PUSHSETTING_EMPTY];
}
+ (void)setPushSetting_empty:(BOOL)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:CONFIGURATION_PUSHSETTING_EMPTY];
}

#pragma mark - NormalNoticeCount
static NSString *CONFIGURATION_NORMALNOTIFICECOUNT = @"Configuration.NormalNoticeCount";
+ (long)getNormalNoticeCount
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{CONFIGURATION_NORMALNOTIFICECOUNT : @(0)}];
    return [userDefaults integerForKey:CONFIGURATION_NORMALNOTIFICECOUNT];
}
+ (void)setNormalNoticeCount:(long)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:value forKey:CONFIGURATION_NORMALNOTIFICECOUNT];
}
#pragma mark - ImportantNoticeCount
static NSString *CONFIGURATION_IMPORTANTNOTIFICECOUNT = @"Configuration.ImportantNoticeCount";
+ (long)getImportantNoticeCount
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{CONFIGURATION_IMPORTANTNOTIFICECOUNT : @(0)}];
    return [userDefaults integerForKey:CONFIGURATION_IMPORTANTNOTIFICECOUNT];
}
+ (void)setImportantNoticeCount:(long)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:value forKey:CONFIGURATION_IMPORTANTNOTIFICECOUNT];
}

#pragma mark - ScheduleKind
static NSString *CONFIGURATION_SCHEDULEKIND = @"Configuration.ScheduleKind";
+ (long)getScheduleKind
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{CONFIGURATION_SCHEDULEKIND : @(0)}];
    return [userDefaults integerForKey:CONFIGURATION_SCHEDULEKIND];
}
+ (void)setScheduleKind:(long)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:value forKey:CONFIGURATION_SCHEDULEKIND];
}
















@end
