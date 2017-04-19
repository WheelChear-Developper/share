//
//  Configuration.h
//
//  Created by MacServer on 2015/12/04.
//  Copyright © 2015年 Mobile Innovation, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Configuration : NSObject

#pragma mark - Synchronize
+ (void)synchronize;

#pragma mark - UrlSchemeStart
+ (BOOL)getUrlSchemeStart;
+ (void)setUrlSchemeStart:(BOOL)value;

#pragma mark - FirstUpdateKeywordSetup
+ (BOOL)getFirstUpdateKeywordSetup;
+ (void)setFirstUpdateKeywordSetup:(BOOL)value;

#pragma mark - AuthenticationID
+ (NSString*)getAuthenticationID;
+ (void)setAuthenticationID:(NSString*)value;

#pragma mark - UpdateKeyword
+ (NSString*)getUpdateKeyword;
+ (void)setUpdateKeyword:(NSString*)value;

#pragma mark - CompanyCode
+ (NSString*)getCompanyCode;
+ (void)setCompanyCode:(NSString*)value;

#pragma mark - ShopCode
+ (NSString*)getShopCode;
+ (void)setShopCode:(NSString*)value;

#pragma mark - ShopName
+ (NSString*)getShopName;
+ (void)setShopName:(NSString*)value;

#pragma mark - PointGrantRate
+ (float)getPointGrantRate;
+ (void)setPointGrantRate:(float)value;

#pragma mark - PointAdjustmentSetting
+ (BOOL)getPointAdjustmentSetting;
+ (void)setPointAdjustmentSetting:(BOOL)value;















#pragma mark - DeviceTokenKey
+ (NSString*)getDeviceTokenKey;
+ (void)setDeviceTokenKey:(NSString*)value;

#pragma mark - SessionTokenKey
+ (NSString*)getSessionTokenKey;
+ (void)setSessionTokenKey:(NSString*)value;

#pragma mark - ScreenWidth
+ (long)getScreenWidth;
+ (void)setScreenWidth:(long)value;
#pragma mark - ScreenHeight
+ (long)getScreenHeight;
+ (void)setScreenHeight:(long)value;

#pragma mark - IDSave
+ (BOOL)getIDSave;
+ (void)setIDSave:(BOOL)value;

#pragma mark - ID
+ (NSString*)getID;
+ (void)setID:(NSString*)value;

#pragma mark - Password
+ (NSString*)getPassword;
+ (void)setPassword:(NSString*)value;

#pragma mark - PushSetting_before_attendance
+ (BOOL)getPushSetting_before_attendance;
+ (void)setPushSetting_before_attendance:(BOOL)value;

#pragma mark - PushSetting_empty
+ (BOOL)getPushSetting_empty;
+ (void)setPushSetting_empty:(BOOL)value;

#pragma mark - NormalNoticeCount
+ (long)getNormalNoticeCount;
+ (void)setNormalNoticeCount:(long)value;

#pragma mark - ImportantNoticeCount
+ (long)getImportantNoticeCount;
+ (void)setImportantNoticeCount:(long)value;

//定時、自由の設定フラグ
#pragma mark - ScheduleKind
+ (long)getScheduleKind;
+ (void)setScheduleKind:(long)value;













@end
