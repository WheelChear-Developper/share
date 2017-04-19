 //
//  Api.m
//
//  Created by MacNote on 2014/09/04.
//  Copyright © 2015年 Mobile Innovation, LLC. All rights reserved.
//

#import "Soap_Api.h"
#import "CustomUIAlertController.h"
#import "XmlToDictionaly.h"

@interface Soap_Api ()
{
    long lng_Timeout;
}
@end

@implementation Soap_Api

- (id)init
{
    if(self = [super init]){
        
        //タイムアウト時間設定
        lng_Timeout = 100;
    }
    return self;
}

- (NSString*)getDomain {

    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ServiceURL"];
}

static NSString *Success = @"Success";
static NSString *NotErr = @"NotErr";
static NSString *Err_ = @"Err_";
static NSString *Err_401 = @"Err_401";
static NSString *Err_422 = @"Err_422";
static NSString *Err_Other = @"Err_Other";
static NSString *Err_Connection = @"Err_Connection";

- (void)setProgressHUD {
    
    //通信開始
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:@"通信中"];
}

- (void)unsetProgressHUD {
    
    //通信中解除
    [SVProgressHUD dismiss];
}

- (void)errorMessage:(NSString*)titleMessage errorMessage:(NSString*)errorMessage errorCode:(long)errorCode {

    CustomUIAlertController *alertController = [CustomUIAlertController alertControllerWithTitle:titleMessage
                                                                                         message:errorMessage
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
    // OK ボタンを表示する
    UIAlertAction *alertAction =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleCancel
                           handler:nil];
    [alertController addAction:alertAction];

    // タイトルの表示設定
    alertController.titleAlign = NSTextAlignmentCenter;
    alertController.titleFont = [UIFont systemFontOfSize:14];
    alertController.titleColor = [UIColor redColor];

    // 本文の表示設定
    alertController.messageAlign = NSTextAlignmentCenter;
    alertController.messageFont = [UIFont systemFontOfSize:14];
    alertController.messageColor = [UIColor redColor];

    // ボタン色設定
    alertController.tintColor = [UIColor blackColor];

    [_apidelegate Soap_Api_ErrAction:alertController errorcode:errorCode];

    [self unsetProgressHUD];
}

/////////////// ↓　通信用メソッド　↓　////////////////////
// 処理概要:認証が必要な場合に呼び出される
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
    //1度でも認証失敗している場合
    if ([challenge previousFailureCount] > 0) {
        //キャンセル処理
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
    else
    {
        //Basic認証
        if ( [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]
            || [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPDigest] )
        {
            NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:@"ユーザID"
                                                                       password:@"パスワード"
                                                                    persistence:NSURLCredentialPersistenceForSession];

            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }
        //SSL認証
        else if ( [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] )
        {
            NSURLProtectionSpace *protecitionSpace = [challenge protectionSpace];
            SecTrustRef trust                      = [protecitionSpace serverTrust];
            NSURLCredential *credential            = [NSURLCredential credentialForTrust:trust];

            NSArray *certs = [[NSArray alloc] initWithObjects:(id)[[self class] sslCertificate], nil];

            OSStatus status = SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef)certs);
            if ( status != errSecSuccess )
            {
                //キャンセル処理
                completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
                return;
            }
            SecTrustResultType trustResult = kSecTrustResultInvalid;
            status = SecTrustEvaluate(trust, &trustResult);
            if ( status != errSecSuccess )
            {
                //キャンセル処理
                completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
                return;
            }

            switch ( trustResult )
            {
                case kSecTrustResultProceed:        // valid and user has explicitly accepted it.
                case kSecTrustResultUnspecified:    // valid and user has not explicitly accepted or reject it. generally you accept it in this case.
                {
                    //認証送信
                    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
                    return;
                }
                    break;
                case kSecTrustResultRecoverableTrustFailure: // invalid, but in a way that may be acceptable, such as a name mismatch, expiration, or lack of trust (such as self-signed certificate)
                {
                    //認証送信
                    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
                    //キャンセル処理
                    //                    [challenge.sender cancelAuthenticationChallenge:challenge];
                }
                    break;
                default:
                    //キャンセル処理
                    [challenge.sender cancelAuthenticationChallenge:challenge];
                    break;
            }
        }
        //クライアント認証
        else if ( [challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate])
        {
            OSStatus status;
            CFArrayRef importedItems = NULL;

            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *documentsDirPath = [paths objectAtIndex:0];
            NSString *pkcs12Path = [documentsDirPath stringByAppendingPathComponent:@"testuser.test.com.pfx"];
            NSString *password = @"GJ0=9d,f";

            //認証データP12のファイルを読み込み
            NSData *PKCS12Data = [NSData dataWithContentsOfFile:pkcs12Path];

            status = SecPKCS12Import((__bridge CFDataRef)PKCS12Data,
                                     (__bridge CFDictionaryRef) [NSDictionary dictionaryWithObjectsAndKeys:password,
                                                                 kSecImportExportPassphrase,
                                                                 nil],
                                     &importedItems);

            if (status == errSecSuccess) {

                NSArray* items = (__bridge NSArray*)importedItems;
                NSLog(@"items:%@", items);
                SecIdentityRef identityRef = (__bridge SecIdentityRef)[[items objectAtIndex:0] objectForKey:(__bridge id)kSecImportItemIdentity];
                NSURLCredential* credential = [NSURLCredential credentialWithIdentity:identityRef
                                                                         certificates:nil
                                                                          persistence:NSURLCredentialPersistenceNone];

                //認証送信
                completionHandler(NSURLSessionAuthChallengeUseCredential, credential);

                if (importedItems != NULL)
                    CFRelease(importedItems);
            }else{

                //通信中解除
                [SVProgressHUD dismiss];

                // 通信エラーメッセージ表示
                [self errorMessage:@"サーバーエラーが発生しました" errorMessage:@"証明書の確認お願いします。" errorCode:0];
            }
        }
    }
}

static SecCertificateRef sslCertificate = NULL;
+ (SecCertificateRef)sslCertificate
{
    if (!sslCertificate){

        //サーバー証明書はder形式でないと処理できない？
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"testuser.test.com" ofType:@"der"];
        NSData *data   = [[NSData alloc] initWithContentsOfFile:filePath];
        sslCertificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)data);
    }
    
    return sslCertificate;
}

//通信開始時に呼ばれる
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {

    if(session == _session_test1_WSDLCheck){

        _initialiseData_test1_WSDLCheck = [NSMutableData data];

        //ステータスコード
        _statusCode_test1_WSDLCheck = ((NSHTTPURLResponse *)response).statusCode;
    }
    if(session == _session_test1){

        _initialiseData_test1 = [NSMutableData data];

        //ステータスコード
        _statusCode_test1 = ((NSHTTPURLResponse *)response).statusCode;
    }

    if(session == _session_Set_A901_KigyoSalonStoreCheck_WSDLCheck){

        _initialiseData_Set_A901_KigyoSalonStoreCheck_WSDLCheck = [NSMutableData data];

        //ステータスコード
        _statusCode_Set_A901_KigyoSalonStoreCheck_WSDLCheck = ((NSHTTPURLResponse *)response).statusCode;
    }
    if(session == _session_Set_A901_KigyoSalonStoreCheck){

        _initialiseData_Set_A901_KigyoSalonStoreCheck = [NSMutableData data];

        //ステータスコード
        _statusCode_Set_A901_KigyoSalonStoreCheck = ((NSHTTPURLResponse *)response).statusCode;
    }

    if(session == _session_Get_A902_PointRateCheck_WSDLCheck){

        _initialiseData_Get_A902_PointRateCheck_WSDLCheck = [NSMutableData data];

        //ステータスコード
        _statusCode_Get_A902_PointRateCheck_WSDLCheck = ((NSHTTPURLResponse *)response).statusCode;
    }
    if(session == _session_Get_A902_PointRateCheck){

        _initialiseData_Get_A902_PointRateCheck = [NSMutableData data];

        //ステータスコード
        _statusCode_Get_A902_PointRateCheck = ((NSHTTPURLResponse *)response).statusCode;
    }

    if(session == _session_Set_A902_PointRateSetting_WSDLCheck){

        _initialiseData_Set_A902_PointRateSetting_WSDLCheck = [NSMutableData data];

        //ステータスコード
        _statusCode_Set_A902_PointRateSetting_WSDLCheck = ((NSHTTPURLResponse *)response).statusCode;
    }
    if(session == _session_Set_A902_PointRateSetting){

        _initialiseData_Set_A902_PointRateSetting = [NSMutableData data];

        //ステータスコード
        _statusCode_Set_A902_PointRateSetting = ((NSHTTPURLResponse *)response).statusCode;
    }

    if(session == _session_Set_A100_MemberRegist_WSDLCheck){

        _initialiseData_Set_A100_MemberRegist_WSDLCheck = [NSMutableData data];

        //ステータスコード
        _statusCode_Set_A100_MemberRegist_WSDLCheck = ((NSHTTPURLResponse *)response).statusCode;
    }
    if(session == _session_Set_A100_MemberRegist){

        _initialiseData_Set_A100_MemberRegist = [NSMutableData data];

        //ステータスコード
        _statusCode_Set_A100_MemberRegist = ((NSHTTPURLResponse *)response).statusCode;
    }

    if(session == _session_Get_A200_PointHistorySearch_WSDLCheck){

        _initialiseData_Get_A200_PointHistorySearch_WSDLCheck = [NSMutableData data];

        //ステータスコード
        _statusCode_Get_A200_PointHistorySearch_WSDLCheck = ((NSHTTPURLResponse *)response).statusCode;
    }
    if(session == _session_Get_A200_PointHistorySearch){

        _initialiseData_Get_A200_PointHistorySearch = [NSMutableData data];

        //ステータスコード
        _statusCode_Get_A200_PointHistorySearch = ((NSHTTPURLResponse *)response).statusCode;
    }

    if(session == _session_Get_SearchMember_WSDLCheck){

        _initialiseData_Get_SearchMember_WSDLCheck = [NSMutableData data];

        //ステータスコード
        _statusCode_Get_SearchMember_WSDLCheck = ((NSHTTPURLResponse *)response).statusCode;
    }
    if(session == _session_Get_SearchMember){

        _initialiseData_Get_SearchMember = [NSMutableData data];

        //ステータスコード
        _statusCode_Get_SearchMember = ((NSHTTPURLResponse *)response).statusCode;
    }

    if(session == _session_Get_PointSearch_WSDLCheck){

        _initialiseData_Get_PointSearch_WSDLCheck = [NSMutableData data];

        //ステータスコード
        _statusCode_Get_PointSearch_WSDLCheck = ((NSHTTPURLResponse *)response).statusCode;
    }
    if(session == _session_Get_PointSearch){

        _initialiseData_Get_PointSearch = [NSMutableData data];

        //ステータスコード
        _statusCode_Get_PointSearch = ((NSHTTPURLResponse *)response).statusCode;
    }

    if(session == _session_Set_A300_ReceiveOrder_WSDLCheck){

        _initialiseData_Set_A300_ReceiveOrder_WSDLCheck = [NSMutableData data];

        //ステータスコード
        _statusCode_Set_A300_ReceiveOrder_WSDLCheck = ((NSHTTPURLResponse *)response).statusCode;
    }
    if(session == _session_Set_A300_ReceiveOrder){

        _initialiseData_Set_A300_ReceiveOrder = [NSMutableData data];

        //ステータスコード
        _statusCode_Set_A300_ReceiveOrder = ((NSHTTPURLResponse *)response).statusCode;
    }

    if(session == _session_Set_A300_OrderConfirm_WSDLCheck){

        _initialiseData_Set_A300_OrderConfirm_WSDLCheck = [NSMutableData data];

        //ステータスコード
        _statusCode_Set_A300_OrderConfirm_WSDLCheck = ((NSHTTPURLResponse *)response).statusCode;
    }
    if(session == _session_Set_A300_OrderConfirm){

        _initialiseData_Set_A300_OrderConfirm = [NSMutableData data];

        //ステータスコード
        _statusCode_Set_A300_OrderConfirm = ((NSHTTPURLResponse *)response).statusCode;
    }

    if(session == _session_Set_A400_PointUpdate_WSDLCheck){

        _initialiseData_Set_A400_PointUpdate_WSDLCheck = [NSMutableData data];

        //ステータスコード
        _statusCode_Set_A400_PointUpdate_WSDLCheck = ((NSHTTPURLResponse *)response).statusCode;
    }
    if(session == _session_Set_A400_PointUpdate){

        _initialiseData_Set_A400_PointUpdate = [NSMutableData data];

        //ステータスコード
        _statusCode_Set_A400_PointUpdate = ((NSHTTPURLResponse *)response).statusCode;
    }

    if(session == _session_Get_MailAddressCheck_WSDLCheck){

        _initialiseData_Get_MailAddressCheck_WSDLCheck = [NSMutableData data];

        //ステータスコード
        _statusCode_Get_MailAddressCheck_WSDLCheck = ((NSHTTPURLResponse *)response).statusCode;
    }
    if(session == _session_Get_MailAddressCheck){

        _initialiseData_Get_MailAddressCheck = [NSMutableData data];

        //ステータスコード
        _statusCode_Get_MailAddressCheck = ((NSHTTPURLResponse *)response).statusCode;
    }

    // didReceivedData と didCompleteWithError が呼ばれるように、通常継続の定数をハンドラーに渡す
    completionHandler(NSURLSessionResponseAllow);
}

//通信中常に呼ばれる
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {

    if(session == _session_test1_WSDLCheck){

        //データ格納
        [_initialiseData_test1_WSDLCheck appendData:data];
    }
    if(session == _session_test1){

        //データ格納
        [_initialiseData_test1 appendData:data];
    }

    if(session == _session_Set_A901_KigyoSalonStoreCheck_WSDLCheck){

        //データ格納
        [_initialiseData_Set_A901_KigyoSalonStoreCheck_WSDLCheck appendData:data];
    }
    if(session == _session_Set_A901_KigyoSalonStoreCheck){

        //データ格納
        [_initialiseData_Set_A901_KigyoSalonStoreCheck appendData:data];
    }

    if(session == _session_Get_A902_PointRateCheck_WSDLCheck){

        //データ格納
        [_initialiseData_Get_A902_PointRateCheck_WSDLCheck appendData:data];
    }
    if(session == _session_Get_A902_PointRateCheck){

        //データ格納
        [_initialiseData_Get_A902_PointRateCheck appendData:data];
    }

    if(session == _session_Set_A902_PointRateSetting_WSDLCheck){

        //データ格納
        [_initialiseData_Set_A902_PointRateSetting_WSDLCheck appendData:data];
    }
    if(session == _session_Set_A902_PointRateSetting){

        //データ格納
        [_initialiseData_Set_A902_PointRateSetting appendData:data];
    }

    if(session == _session_Set_A100_MemberRegist_WSDLCheck){

        //データ格納
        [_initialiseData_Set_A100_MemberRegist_WSDLCheck appendData:data];
    }
    if(session == _session_Set_A100_MemberRegist){

        //データ格納
        [_initialiseData_Set_A100_MemberRegist appendData:data];
    }

    if(session == _session_Get_A200_PointHistorySearch_WSDLCheck){

        //データ格納
        [_initialiseData_Get_A200_PointHistorySearch_WSDLCheck appendData:data];
    }
    if(session == _session_Get_A200_PointHistorySearch){

        //データ格納
        [_initialiseData_Get_A200_PointHistorySearch appendData:data];
    }

    if(session == _session_Get_SearchMember_WSDLCheck){

        //データ格納
        [_initialiseData_Get_SearchMember_WSDLCheck appendData:data];
    }
    if(session == _session_Get_SearchMember){

        //データ格納
        [_initialiseData_Get_SearchMember appendData:data];
    }

    if(session == _session_Get_PointSearch_WSDLCheck){

        //データ格納
        [_initialiseData_Get_PointSearch_WSDLCheck appendData:data];
    }
    if(session == _session_Get_PointSearch){

        //データ格納
        [_initialiseData_Get_PointSearch appendData:data];
    }

    if(session == _session_Set_A300_ReceiveOrder_WSDLCheck){

        //データ格納
        [_initialiseData_Set_A300_ReceiveOrder_WSDLCheck appendData:data];
    }
    if(session == _session_Set_A300_ReceiveOrder){

        //データ格納
        [_initialiseData_Set_A300_ReceiveOrder appendData:data];
    }

    if(session == _session_Set_A300_OrderConfirm_WSDLCheck){

        //データ格納
        [_initialiseData_Set_A300_OrderConfirm_WSDLCheck appendData:data];
    }
    if(session == _session_Set_A300_OrderConfirm){

        //データ格納
        [_initialiseData_Set_A300_OrderConfirm appendData:data];
    }

    if(session == _session_Set_A400_PointUpdate_WSDLCheck){

        //データ格納
        [_initialiseData_Set_A400_PointUpdate_WSDLCheck appendData:data];
    }
    if(session == _session_Set_A400_PointUpdate){

        //データ格納
        [_initialiseData_Set_A400_PointUpdate appendData:data];
    }

    if(session == _session_Get_MailAddressCheck_WSDLCheck){

        //データ格納
        [_initialiseData_Get_MailAddressCheck_WSDLCheck appendData:data];
    }
    if(session == _session_Get_MailAddressCheck){

        //データ格納
        [_initialiseData_Get_MailAddressCheck appendData:data];
    }
}

- (NSString*)get_baseName:(NSData*)initialiseData name:(NSString*)name errorcode:(long)errorcode {

    NSDictionary *dic_parse = [XmlToDictionaly dictionaryForXMLData:initialiseData error:nil];
    NSArray *dic_schema = [[[dic_parse objectForKey:@"wsdl:definitions"] objectForKey:@"wsdl:types"] objectForKey:@"xs:schema"];

    for(long d =0;d<dic_schema.count;d++){

        NSArray *dic_complexType = [[dic_schema objectAtIndex:d] objectForKey:@"xs:complexType"];

        @try {

            for (long c=0;c < dic_complexType.count;c++) {
                NSString *str_name = [[dic_complexType objectAtIndex:c] objectForKey:@"name"];
                if([str_name isEqualToString:name]){

                    NSDictionary *dic_extension = [[[dic_complexType objectAtIndex:c] objectForKey:@"xs:complexContent"] objectForKey:@"xs:extension"];
                    //            NSLog(@"%@",dic_extension);

                    NSString *str_base = [dic_extension objectForKey:@"base"];
                    //            NSLog(@"%@",str_base);
                    NSRange found = [str_base rangeOfString:@":" options:NSLiteralSearch];
                    NSString* str_baseName = [str_base substringToIndex:found.location];
                    //            NSLog(@"%@",str_baseName);

                    if([str_baseName length] > 0){

                        return str_baseName;
                    }else{

                        // 通信エラーメッセージ表示
                        [self errorMessage:@"サーバーエラーが発生しました" errorMessage:@"エラー：BaseName" errorCode:0];
                    }
                }
            }
        }
        @catch (NSException *exception) {

        }
    }

    // 通信エラーメッセージ表示
    [self errorMessage:@"サーバーエラーが発生しました" errorMessage:@"エラー：BaseName" errorCode:0];
    return @"";
}

- (NSString*)get_colom_baseName:(NSData*)initialiseData name:(NSString*)name errorcode:(long)errorcode {

    NSDictionary *dic_parse = [XmlToDictionaly dictionaryForXMLData:initialiseData error:nil];
    NSArray *dic_schema = [[[dic_parse objectForKey:@"wsdl:definitions"] objectForKey:@"wsdl:types"] objectForKey:@"xs:schema"];

    for(long d =0;d<dic_schema.count;d++){

        NSArray *dic_complexType = [[dic_schema objectAtIndex:d] objectForKey:@"xs:complexType"];

        @try {

            for (long c=0;c < dic_complexType.count;c++) {
                NSString *str_name = [[dic_complexType objectAtIndex:c] objectForKey:@"name"];
                if([str_name isEqualToString:name]){

                    NSDictionary *dic_extension = [[[dic_complexType objectAtIndex:c] objectForKey:@"xs:complexContent"] objectForKey:@"xs:extension"];
                    NSLog(@"%@",dic_extension);
                    NSDictionary *dic_element = [[dic_extension objectForKey:@"xs:sequence"] objectForKey:@"xs:element"];
                    NSLog(@"%@",dic_element);

                    NSString *str_type = [dic_element objectForKey:@"type"];
                    //            NSLog(@"%@",str_base);
                    NSRange rng_type = [str_type rangeOfString:@":" options:NSLiteralSearch];
                    NSString* str_typeName = [str_type substringToIndex:rng_type.location];
                    //            NSLog(@"%@",str_baseName);

                    return str_typeName;
                }
            }
        }
        @catch (NSException *exception) {

        }
    }
    return @"";
}

- (NSString*)get_endpointName:(NSData*)initialiseData name:(NSString*)name errorcode:(long)errorcode {

    NSDictionary *dic_parse = [XmlToDictionaly dictionaryForXMLData:initialiseData error:nil];
    NSArray *dic_port = [[[dic_parse objectForKey:@"wsdl:definitions"] objectForKey:@"wsdl:service"] objectForKey:@"wsdl:port"];

    for (long c=0;c < dic_port.count;c++) {
        NSString *str_name = [[dic_port objectAtIndex:c] objectForKey:@"name"];
        if([str_name isEqualToString:name]){

            NSString *str_lovation = [[[dic_port objectAtIndex:c] objectForKey:@"soap12:address"] objectForKey:@"location"];

            if([str_lovation length] > 0){

                return str_lovation;
            }else{

                // 通信エラーメッセージ表示
                [self errorMessage:@"サーバーエラーが発生しました" errorMessage:@"エラー：EndpointURL" errorCode:0];
            }
        }
    }

    // 通信エラーメッセージ表示
    [self errorMessage:@"サーバーエラーが発生しました" errorMessage:@"エラー：EndpointURL" errorCode:0];
    return @"";
}

//通信終了時に呼ばれる
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {

    if(session == _session_test1_WSDLCheck){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_test1_WSDLCheck];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_test1_WSDLCheck;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_test1_WSDLCheck];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                //basa名取得
                _basename_test1 = [self get_baseName:_initialiseData_test1_WSDLCheck name:@"OCardPoint" errorcode:_statusCode_test1_WSDLCheck];

                //colom basa名取得
                _colomBasename_test1 = [self get_colom_baseName:_initialiseData_test1_WSDLCheck name:@"OCardPoint" errorcode:_statusCode_test1_WSDLCheck];

                //colom base [ax]で始まらないbaseを設定
                if([_colomBasename_test1 length] > 0){
                    if(![[_colomBasename_test1 substringToIndex:2] isEqualToString:@"ax"]){

                        _colomBasename_test1 = _basename_test1;
                    }
                }else{
                    //colom basa名ない場合、basenameを設定する
                    _colomBasename_test1 = _basename_test1;
                }

                //endpoint取得
                _endpoint_test1 = [self get_endpointName:_initialiseData_test1_WSDLCheck name:@"PointSearchHttpsSoap12Endpoint" errorcode:_statusCode_test1_WSDLCheck];

                if([_basename_test1 length] > 0){
                    if([_colomBasename_test1 length] > 0){
                        if([_endpoint_test1 length] > 0){

                            [_apidelegate Soap_Api_WSDLCheck_BackAction:@"test1_WSDLCheck" basename:_basename_test1];
                        }
                    }
                }

            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }
    if(session == _session_test1){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_test1];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_test1;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_test1];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                NSDictionary *dic_parse = [XmlToDictionaly dictionaryForXMLData:_initialiseData_test1 error:nil];
                //NSLog(@"%@",dic_parse);

                NSDictionary *dic_body = [[dic_parse objectForKey:@"soapenv:Envelope"] objectForKey:@"soapenv:Body"];
                NSLog(@"%@",dic_body);

                NSDictionary *dic_getResponse = [[dic_body objectForKey:@"ns:getPointZndkResponse"] objectForKey:@"ns:return"];
                NSLog(@"%@",dic_getResponse);

                //APIエラーコード取得
                NSString *str_ErrCodeKey = [NSString stringWithFormat:@"%@:errCd",_basename_test1];
                NSString *str_ErrCode = [[dic_getResponse objectForKey:str_ErrCodeKey] objectForKey:@"text"];
                NSLog(@"ErrCode = %@",str_ErrCode);

                if(str_ErrCode.length == 0){

                    //Dictionaryからポイントキーからルートキー検索
                    NSString *str_key = [NSString stringWithFormat:@"%@:pointQt",_basename_test1];
                    NSString *str_point = [[dic_getResponse objectForKey:str_key] objectForKey:@"text"];
                    NSLog(@"%@ = %@",str_key,str_point);

                    [_apidelegate Soap_Api_BackAction:@"test1" dicData:dic_getResponse basename:_colomBasename_test1 errorcode:[[NSString stringWithFormat:@"%@", str_ErrCode] integerValue]];

                    [self unsetProgressHUD];

                } else {

                    NSString *str_ErrMsgKey = [NSString stringWithFormat:@"%@:errMes",_basename_test1];
                    NSString *str_ErrMsg = [[dic_getResponse objectForKey:str_ErrMsgKey] objectForKey:@"text"];
                    NSLog(@"ErrCode = %@",str_ErrCode);

                    // 通信エラーメッセージ表示
                    [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"\n%@\n\nエラーコード（%@）", str_ErrMsg, str_ErrCode] errorCode:[str_ErrCode integerValue]];
                }
                
            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }

    if(session == _session_Set_A901_KigyoSalonStoreCheck_WSDLCheck){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Set_A901_KigyoSalonStoreCheck_WSDLCheck];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Set_A901_KigyoSalonStoreCheck_WSDLCheck;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Set_A901_KigyoSalonStoreCheck_WSDLCheck];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                //basa名取得
                _basename_Set_A901_KigyoSalonStoreCheck = [self get_baseName:_initialiseData_Set_A901_KigyoSalonStoreCheck_WSDLCheck name:@"OKigyoSalonStoreCheck" errorcode:_statusCode_Set_A901_KigyoSalonStoreCheck_WSDLCheck];

                //colom basa名取得
                _colomBasename_Set_A901_KigyoSalonStoreCheck = [self get_colom_baseName:_initialiseData_Set_A901_KigyoSalonStoreCheck_WSDLCheck name:@"OKigyoSalonStoreCheck" errorcode:_statusCode_Set_A901_KigyoSalonStoreCheck_WSDLCheck];

                //colom base [ax]で始まらないbaseを設定
                if([_colomBasename_Set_A901_KigyoSalonStoreCheck length] > 0){
                    if(![[_colomBasename_Set_A901_KigyoSalonStoreCheck substringToIndex:2] isEqualToString:@"ax"]){

                        _colomBasename_Set_A901_KigyoSalonStoreCheck = _basename_Set_A901_KigyoSalonStoreCheck;
                    }
                }else{
                    //colom basa名ない場合、basenameを設定する
                    _colomBasename_Set_A901_KigyoSalonStoreCheck = _basename_Set_A901_KigyoSalonStoreCheck;
                }
                
                //endpoint取得
                _endpoint_Set_A901_KigyoSalonStoreCheck = [self get_endpointName:_initialiseData_Set_A901_KigyoSalonStoreCheck_WSDLCheck name:@"KigyoSalonStoreCheckHttpsSoap12Endpoint" errorcode:_statusCode_Set_A901_KigyoSalonStoreCheck_WSDLCheck];

                if([_basename_Set_A901_KigyoSalonStoreCheck length] > 0){
                    if([_colomBasename_Set_A901_KigyoSalonStoreCheck length] > 0){
                        if([_endpoint_Set_A901_KigyoSalonStoreCheck length] > 0){

                            [_apidelegate Soap_Api_WSDLCheck_BackAction:@"Set_A901_KigyoSalonStoreCheck_WSDLCheck" basename:_basename_Set_A901_KigyoSalonStoreCheck];
                        }
                    }
                }

            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }
    if(session == _session_Set_A901_KigyoSalonStoreCheck){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Set_A901_KigyoSalonStoreCheck];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Set_A901_KigyoSalonStoreCheck;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Set_A901_KigyoSalonStoreCheck];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                NSDictionary *dic_parse = [XmlToDictionaly dictionaryForXMLData:_initialiseData_Set_A901_KigyoSalonStoreCheck error:nil];
                //NSLog(@"%@",dic_parse);

                NSDictionary *dic_body = [[dic_parse objectForKey:@"soapenv:Envelope"] objectForKey:@"soapenv:Body"];
                NSLog(@"%@",dic_body);

                NSDictionary *dic_getResponse = [[dic_body objectForKey:@"ns:kigyoSalonStoreCheckResponse"] objectForKey:@"ns:return"];
                NSLog(@"%@",dic_getResponse);

                //APIエラーコード取得
                NSString *str_ErrCodeKey = [NSString stringWithFormat:@"%@:errCd",_basename_Set_A901_KigyoSalonStoreCheck];
                NSString *str_ErrCode = [[dic_getResponse objectForKey:str_ErrCodeKey] objectForKey:@"text"];
                NSLog(@"ErrCode = %@",str_ErrCode);

                if(str_ErrCode.length == 0){

                    [_apidelegate Soap_Api_BackAction:@"Set_A901_KigyoSalonStoreCheck" dicData:dic_getResponse basename:_colomBasename_Set_A901_KigyoSalonStoreCheck errorcode:[[NSString stringWithFormat:@"%@", str_ErrCode] integerValue]];

                    [self unsetProgressHUD];

                } else {

                    NSString *str_ErrMsgKey = [NSString stringWithFormat:@"%@:errMes",_basename_Set_A901_KigyoSalonStoreCheck];
                    NSString *str_ErrMsg = [[dic_getResponse objectForKey:str_ErrMsgKey] objectForKey:@"text"];
                    NSLog(@"ErrCode = %@",str_ErrCode);

                    // 通信エラーメッセージ表示
                    [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"\n%@\n\nエラーコード（%@）", str_ErrMsg, str_ErrCode] errorCode:[str_ErrCode integerValue]];
                }

            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }

    if(session == _session_Get_A902_PointRateCheck_WSDLCheck){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Get_A902_PointRateCheck_WSDLCheck];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Get_A902_PointRateCheck_WSDLCheck;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Get_A902_PointRateCheck_WSDLCheck];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                //basa名取得
                _basename_Get_A902_PointRateCheck = [self get_baseName:_initialiseData_Get_A902_PointRateCheck_WSDLCheck name:@"OPointRateCheck" errorcode:_statusCode_Get_A902_PointRateCheck_WSDLCheck];

                //colom basa名取得
                _colomBasename_Get_A902_PointRateCheck = [self get_colom_baseName:_initialiseData_Get_A902_PointRateCheck_WSDLCheck name:@"OPointRateCheck" errorcode:_statusCode_Get_A902_PointRateCheck_WSDLCheck];

                //colom base [ax]で始まらないbaseを設定
                if([_colomBasename_Get_A902_PointRateCheck length] > 0){
                    if(![[_colomBasename_Get_A902_PointRateCheck substringToIndex:2] isEqualToString:@"ax"]){

                        _colomBasename_Get_A902_PointRateCheck = _basename_Get_A902_PointRateCheck;
                    }
                }else{
                    //colom basa名ない場合、basenameを設定する
                    _colomBasename_Get_A902_PointRateCheck = _basename_Get_A902_PointRateCheck;
                }

                //endpoint取得
                _endpoint_Get_A902_PointRateCheck = [self get_endpointName:_initialiseData_Get_A902_PointRateCheck_WSDLCheck name:@"PointRateCheckHttpsSoap12Endpoint" errorcode:_statusCode_Get_A902_PointRateCheck_WSDLCheck];

                if([_basename_Get_A902_PointRateCheck length] > 0){
                    if([_colomBasename_Get_A902_PointRateCheck length] > 0){
                        if([_endpoint_Get_A902_PointRateCheck length] > 0){

                            [_apidelegate Soap_Api_WSDLCheck_BackAction:@"Get_A902_PointRateCheck_WSDLCheck" basename:_basename_Get_A902_PointRateCheck];
                        }
                    }
                }
                
            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }
    if(session == _session_Get_A902_PointRateCheck){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Get_A902_PointRateCheck];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Get_A902_PointRateCheck;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Get_A902_PointRateCheck];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                NSDictionary *dic_parse = [XmlToDictionaly dictionaryForXMLData:_initialiseData_Get_A902_PointRateCheck error:nil];
                //NSLog(@"%@",dic_parse);

                NSDictionary *dic_body = [[dic_parse objectForKey:@"soapenv:Envelope"] objectForKey:@"soapenv:Body"];
                NSLog(@"%@",dic_body);

                NSDictionary *dic_getResponse = [[dic_body objectForKey:@"ns:searchResponse"] objectForKey:@"ns:return"];
                NSLog(@"%@",dic_getResponse);

                //APIエラーコード取得
                NSString *str_ErrCodeKey = [NSString stringWithFormat:@"%@:errCd",_basename_Get_A902_PointRateCheck];
                NSString *str_ErrCode = [[dic_getResponse objectForKey:str_ErrCodeKey] objectForKey:@"text"];
                NSLog(@"ErrCode = %@",str_ErrCode);

                if(str_ErrCode.length == 0){

                    [_apidelegate Soap_Api_BackAction:@"Get_A902_PointRateCheck" dicData:dic_getResponse basename:_colomBasename_Get_A902_PointRateCheck errorcode:[[NSString stringWithFormat:@"%@", str_ErrCode] integerValue]];

                    [self unsetProgressHUD];

                } else {

                    NSString *str_ErrMsgKey = [NSString stringWithFormat:@"%@:errMes",_basename_Get_A902_PointRateCheck];
                    NSString *str_ErrMsg = [[dic_getResponse objectForKey:str_ErrMsgKey] objectForKey:@"text"];
                    NSLog(@"ErrCode = %@",str_ErrCode);

                    // 通信エラーメッセージ表示
                    [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"\n%@\n\nエラーコード（%@）", str_ErrMsg, str_ErrCode] errorCode:[str_ErrCode integerValue]];
                }

            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }

    if(session == _session_Set_A902_PointRateSetting_WSDLCheck){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Set_A902_PointRateSetting_WSDLCheck];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Set_A902_PointRateSetting_WSDLCheck;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Set_A902_PointRateSetting_WSDLCheck];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                //basa名取得
                _basename_Set_A902_PointRateSetting = [self get_baseName:_initialiseData_Set_A902_PointRateSetting_WSDLCheck name:@"OPointRateSetting" errorcode:_statusCode_Set_A902_PointRateSetting_WSDLCheck];

                //colom basa名取得
                _colomBasename_Set_A902_PointRateSetting = [self get_colom_baseName:_initialiseData_Set_A902_PointRateSetting_WSDLCheck name:@"OPointRateSetting" errorcode:_statusCode_Set_A902_PointRateSetting_WSDLCheck];

                //colom base [ax]で始まらないbaseを設定
                if([_colomBasename_Set_A902_PointRateSetting length] > 0){
                    if(![[_colomBasename_Set_A902_PointRateSetting substringToIndex:2] isEqualToString:@"ax"]){

                        _colomBasename_Set_A902_PointRateSetting = _basename_Set_A902_PointRateSetting;
                    }
                }else{
                    //colom basa名ない場合、basenameを設定する
                    _colomBasename_Set_A902_PointRateSetting = _basename_Set_A902_PointRateSetting;
                }

                //endpoint取得
                _endpoint_Set_A902_PointRateSetting = [self get_endpointName:_initialiseData_Set_A902_PointRateSetting_WSDLCheck name:@"PointRateSettingHttpsSoap12Endpoint" errorcode:_statusCode_Set_A902_PointRateSetting_WSDLCheck];

                if([_basename_Set_A902_PointRateSetting length] > 0){
                    if([_colomBasename_Set_A902_PointRateSetting length] > 0){
                        if([_endpoint_Set_A902_PointRateSetting length] > 0){

                            [_apidelegate Soap_Api_WSDLCheck_BackAction:@"Set_A902_PointRateSetting_WSDLCheck" basename:_basename_Set_A902_PointRateSetting];
                        }
                    }
                }

            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }
    if(session == _session_Set_A902_PointRateSetting){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Set_A902_PointRateSetting];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Set_A902_PointRateSetting;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Set_A902_PointRateSetting];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                NSDictionary *dic_parse = [XmlToDictionaly dictionaryForXMLData:_initialiseData_Set_A902_PointRateSetting error:nil];
                //NSLog(@"%@",dic_parse);

                NSDictionary *dic_body = [[dic_parse objectForKey:@"soapenv:Envelope"] objectForKey:@"soapenv:Body"];
                NSLog(@"%@",dic_body);

                NSDictionary *dic_getResponse = [[dic_body objectForKey:@"ns:registoryPointRateResponse"] objectForKey:@"ns:return"];
                NSLog(@"%@",dic_getResponse);

                //APIエラーコード取得
                NSString *str_ErrCodeKey = [NSString stringWithFormat:@"%@:errCd",_basename_Set_A902_PointRateSetting];
                NSString *str_ErrCode = [[dic_getResponse objectForKey:str_ErrCodeKey] objectForKey:@"text"];
                NSLog(@"ErrCode = %@",str_ErrCode);

                if(str_ErrCode.length == 0){

                    [_apidelegate Soap_Api_BackAction:@"Set_A902_PointRateSetting" dicData:dic_getResponse basename:_colomBasename_Set_A902_PointRateSetting errorcode:[[NSString stringWithFormat:@"%@", str_ErrCode] integerValue]];

                    [self unsetProgressHUD];

                } else {

                    NSString *str_ErrMsgKey = [NSString stringWithFormat:@"%@:errMes",_basename_Set_A902_PointRateSetting];
                    NSString *str_ErrMsg = [[dic_getResponse objectForKey:str_ErrMsgKey] objectForKey:@"text"];
                    NSLog(@"ErrCode = %@",str_ErrCode);

                    // 通信エラーメッセージ表示
                    [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"\n%@\n\nエラーコード（%@）", str_ErrMsg, str_ErrCode] errorCode:[str_ErrCode integerValue]];
                }

            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }

    if(session == _session_Set_A100_MemberRegist_WSDLCheck){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Set_A100_MemberRegist_WSDLCheck];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Set_A100_MemberRegist_WSDLCheck;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Set_A100_MemberRegist_WSDLCheck];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                //basa名取得
                _basename_Set_A100_MemberRegist = [self get_baseName:_initialiseData_Set_A100_MemberRegist_WSDLCheck name:@"ORegistCard" errorcode:_statusCode_Set_A100_MemberRegist_WSDLCheck];

                //colom basa名取得
                _colomBasename_Set_A100_MemberRegist = [self get_colom_baseName:_initialiseData_Set_A100_MemberRegist_WSDLCheck name:@"ORegistCard" errorcode:_statusCode_Set_A100_MemberRegist_WSDLCheck];

                //colom base [ax]で始まらないbaseを設定
                if([_colomBasename_Set_A100_MemberRegist length] > 0){
                    if(![[_colomBasename_Set_A100_MemberRegist substringToIndex:2] isEqualToString:@"ax"]){

                        _colomBasename_Set_A100_MemberRegist = _basename_Set_A100_MemberRegist;
                    }
                }else{
                    //colom basa名ない場合、basenameを設定する
                    _colomBasename_Set_A100_MemberRegist = _basename_Set_A100_MemberRegist;
                }

                //endpoint取得
                _endpoint_Set_A100_MemberRegist = [self get_endpointName:_initialiseData_Set_A100_MemberRegist_WSDLCheck name:@"MemberRegistHttpsSoap12Endpoint" errorcode:_statusCode_Set_A100_MemberRegist_WSDLCheck];

                if([_basename_Set_A100_MemberRegist length] > 0){
                    if([_colomBasename_Set_A100_MemberRegist length] > 0){
                        if([_endpoint_Set_A100_MemberRegist length] > 0){

                            [_apidelegate Soap_Api_WSDLCheck_BackAction:@"Set_A100_MemberRegist_WSDLCheck" basename:_basename_Set_A100_MemberRegist];
                        }
                    }
                }

            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }
    if(session == _session_Set_A100_MemberRegist){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Set_A100_MemberRegist];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Set_A100_MemberRegist;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Set_A100_MemberRegist];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                NSDictionary *dic_parse = [XmlToDictionaly dictionaryForXMLData:_initialiseData_Set_A100_MemberRegist error:nil];
                //NSLog(@"%@",dic_parse);

                NSDictionary *dic_body = [[dic_parse objectForKey:@"soapenv:Envelope"] objectForKey:@"soapenv:Body"];
                NSLog(@"%@",dic_body);

                NSDictionary *dic_getResponse = [[dic_body objectForKey:@"ns:mergeMemberInfoResponse"] objectForKey:@"ns:return"];
                NSLog(@"%@",dic_getResponse);

                //APIエラーコード取得
                NSString *str_ErrCodeKey = [NSString stringWithFormat:@"%@:errCd",_basename_Set_A100_MemberRegist];
                NSString *str_ErrCode = [[dic_getResponse objectForKey:str_ErrCodeKey] objectForKey:@"text"];
                NSLog(@"ErrCode = %@",str_ErrCode);

                if(str_ErrCode.length == 0){

                    [_apidelegate Soap_Api_BackAction:@"Set_A100_MemberRegist" dicData:dic_getResponse basename:_colomBasename_Set_A100_MemberRegist errorcode:[[NSString stringWithFormat:@"%@", str_ErrCode] integerValue]];

                    [self unsetProgressHUD];

                } else {

                    NSString *str_ErrMsgKey = [NSString stringWithFormat:@"%@:errMes",_basename_Set_A100_MemberRegist];
                    NSString *str_ErrMsg = [[dic_getResponse objectForKey:str_ErrMsgKey] objectForKey:@"text"];
                    NSLog(@"ErrCode = %@",str_ErrCode);

                    //バンドルIDによるストーリーボード変更
                    NSString *bundleIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];

                    if([bundleIdentifier isEqualToString:@"jp.co.dalia.satisfaapp"]){

                        if([str_ErrCode isEqualToString:@"518"]){

                            //重複エラー処理
                            [_apidelegate Soap_Api_BackAction:@"Set_A100_MemberRegist_Duplication" dicData:dic_getResponse basename:_colomBasename_Set_A100_MemberRegist errorcode:[[NSString stringWithFormat:@"%@", str_ErrCode] integerValue]];

                            [self unsetProgressHUD];
                        }else{

                            // 通信エラーメッセージ表示
                            [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"\n%@\n\nエラーコード（%@）", str_ErrMsg, str_ErrCode] errorCode:[str_ErrCode integerValue]];
                        }
                    }else if([bundleIdentifier isEqualToString:@"jp.co.dalia.satisfaappec"]){

                        // 通信エラーメッセージ表示
                        [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"\n%@\n\nエラーコード（%@）", str_ErrMsg, str_ErrCode] errorCode:[str_ErrCode integerValue]];

                    }else if([bundleIdentifier isEqualToString:@"jp.co.dalia.satisfaappstaging"]){

                        if([str_ErrCode isEqualToString:@"518"]){

                            //重複エラー処理
                            [_apidelegate Soap_Api_BackAction:@"Set_A100_MemberRegist_Duplication" dicData:dic_getResponse basename:_colomBasename_Set_A100_MemberRegist errorcode:[[NSString stringWithFormat:@"%@", str_ErrCode] integerValue]];

                            [self unsetProgressHUD];
                        }else{

                            // 通信エラーメッセージ表示
                            [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"\n%@\n\nエラーコード（%@）", str_ErrMsg, str_ErrCode] errorCode:[str_ErrCode integerValue]];
                        }
                    }else if([bundleIdentifier isEqualToString:@"jp.co.dalia.satisfaappecstaging"]){
                        
                        // 通信エラーメッセージ表示
                        [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"\n%@\n\nエラーコード（%@）", str_ErrMsg, str_ErrCode] errorCode:[str_ErrCode integerValue]];
                    }
                }

            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }

    if(session == _session_Get_A200_PointHistorySearch_WSDLCheck){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Get_A200_PointHistorySearch_WSDLCheck];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Get_A200_PointHistorySearch_WSDLCheck;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Get_A200_PointHistorySearch_WSDLCheck];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                //basa名取得
                _basename_Get_A200_PointHistorySearch = [self get_baseName:_initialiseData_Get_A200_PointHistorySearch_WSDLCheck name:@"OPointHistory" errorcode:_statusCode_Get_A200_PointHistorySearch_WSDLCheck];

                //colom basa名取得
                _colomBasename_Get_A200_PointHistorySearch = [self get_colom_baseName:_initialiseData_Get_A200_PointHistorySearch_WSDLCheck name:@"OPointHistory" errorcode:_statusCode_Get_A200_PointHistorySearch_WSDLCheck];

                //colom base [ax]で始まらないbaseを設定
                if([_colomBasename_Get_A200_PointHistorySearch length] > 0){
                    if(![[_colomBasename_Get_A200_PointHistorySearch substringToIndex:2] isEqualToString:@"ax"]){

                        _colomBasename_Get_A200_PointHistorySearch = _basename_Get_A200_PointHistorySearch;
                    }
                }else{
                    //colom basa名ない場合、basenameを設定する
                    _colomBasename_Get_A200_PointHistorySearch = _basename_Get_A200_PointHistorySearch;
                }

                //endpoint取得
                _endpoint_Get_A200_PointHistorySearch = [self get_endpointName:_initialiseData_Get_A200_PointHistorySearch_WSDLCheck name:@"PointHistorySearchHttpsSoap12Endpoint" errorcode:_statusCode_Get_A200_PointHistorySearch_WSDLCheck];

                if([_basename_Get_A200_PointHistorySearch length] > 0){
                    if([_colomBasename_Get_A200_PointHistorySearch length] > 0){
                        if([_endpoint_Get_A200_PointHistorySearch length] > 0){

                            [_apidelegate Soap_Api_WSDLCheck_BackAction:@"Get_A200_PointHistorySearch_WSDLCheck" basename:_basename_Get_A200_PointHistorySearch];
                        }
                    }
                }

            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }
    if(session == _session_Get_A200_PointHistorySearch){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Get_A200_PointHistorySearch];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Get_A200_PointHistorySearch;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Get_A200_PointHistorySearch];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                NSDictionary *dic_parse = [XmlToDictionaly dictionaryForXMLData:_initialiseData_Get_A200_PointHistorySearch error:nil];
                NSDictionary *dic_body = [[dic_parse objectForKey:@"soapenv:Envelope"] objectForKey:@"soapenv:Body"];
                NSDictionary *dic_getResponse = [[dic_body objectForKey:@"ns:getPointHistoryResponse"] objectForKey:@"ns:return"];

                NSDictionary *dic_beanList = [dic_getResponse objectForKey:[NSString stringWithFormat:@"%@:beanList",_basename_Get_A200_PointHistorySearch]];

                //APIエラーコード取得
                NSString *str_ErrCodeKey = [NSString stringWithFormat:@"%@:errCd",_basename_Get_A200_PointHistorySearch];
                NSString *str_ErrCode = [[dic_getResponse objectForKey:str_ErrCodeKey] objectForKey:@"text"];

                if(str_ErrCode.length == 0){

                    [_apidelegate Soap_Api_BackAction:@"Get_A200_PointHistorySearch" dicData:dic_beanList basename:_colomBasename_Get_A200_PointHistorySearch errorcode:[[NSString stringWithFormat:@"%@", str_ErrCode] integerValue]];

                    [self unsetProgressHUD];

                } else {

                    NSString *str_ErrMsgKey = [NSString stringWithFormat:@"%@:errMes",_basename_Get_A200_PointHistorySearch];
                    NSString *str_ErrMsg = [[dic_getResponse objectForKey:str_ErrMsgKey] objectForKey:@"text"];
                    NSLog(@"ErrCode = %@",str_ErrCode);

                    // 通信エラーメッセージ表示
                    [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"\n%@\n\nエラーコード（%@）", str_ErrMsg, str_ErrCode] errorCode:[str_ErrCode integerValue]];
                }

            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }

    if(session == _session_Get_SearchMember_WSDLCheck){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Get_SearchMember_WSDLCheck];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Get_SearchMember_WSDLCheck;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Get_SearchMember_WSDLCheck];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                //basa名取得
                _basename_Get_SearchMember = [self get_baseName:_initialiseData_Get_SearchMember_WSDLCheck name:@"OSearchMember" errorcode:_statusCode_Get_SearchMember_WSDLCheck];

                //colom basa名取得
                _colomBasename_Get_SearchMember = [self get_colom_baseName:_initialiseData_Get_SearchMember_WSDLCheck name:@"OSearchMember" errorcode:_statusCode_Get_SearchMember_WSDLCheck];

                //colom base [ax]で始まらないbaseを設定
                if([_colomBasename_Get_SearchMember length] > 0){
                    if(![[_colomBasename_Get_SearchMember substringToIndex:2] isEqualToString:@"ax"]){

                        _colomBasename_Get_SearchMember = _basename_Get_SearchMember;
                    }
                }else{
                    //colom basa名ない場合、basenameを設定する
                    _colomBasename_Get_SearchMember = _basename_Get_SearchMember;
                }

                //endpoint取得
                _endpoint_Get_SearchMember = [self get_endpointName:_initialiseData_Get_SearchMember_WSDLCheck name:@"SearchMemberHttpsSoap12Endpoint" errorcode:_statusCode_Get_SearchMember_WSDLCheck];

                if([_basename_Get_SearchMember length] > 0){
                    if([_colomBasename_Get_SearchMember length] > 0){
                        if([_endpoint_Get_SearchMember length] > 0){

                            [_apidelegate Soap_Api_WSDLCheck_BackAction:@"Get_SearchMember_WSDLCheck" basename:_basename_Get_SearchMember];
                        }
                    }
                }

            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }
    if(session == _session_Get_SearchMember){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Get_SearchMember];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Get_SearchMember;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Get_SearchMember];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                NSDictionary *dic_parse = [XmlToDictionaly dictionaryForXMLData:_initialiseData_Get_SearchMember error:nil];
                //NSLog(@"%@",dic_parse);

                NSDictionary *dic_body = [[dic_parse objectForKey:@"soapenv:Envelope"] objectForKey:@"soapenv:Body"];
                NSLog(@"%@",dic_body);

                NSDictionary *dic_getResponse = [[dic_body objectForKey:@"ns:searchResponse"] objectForKey:@"ns:return"];
                NSLog(@"%@",dic_getResponse);

                //APIエラーコード取得
                NSString *str_ErrCodeKey = [NSString stringWithFormat:@"%@:errCd",_basename_Get_SearchMember];
                NSString *str_ErrCode = [[dic_getResponse objectForKey:str_ErrCodeKey] objectForKey:@"text"];
                NSLog(@"ErrCode = %@",str_ErrCode);

                if(str_ErrCode.length == 0){

                    [_apidelegate Soap_Api_BackAction:@"Get_SearchMember" dicData:dic_getResponse basename:_colomBasename_Get_SearchMember errorcode:[[NSString stringWithFormat:@"%@", str_ErrCode] integerValue]];

                    [self unsetProgressHUD];

                } else {

                    NSString *str_ErrMsgKey = [NSString stringWithFormat:@"%@:errMes",_basename_Get_SearchMember];
                    NSString *str_ErrMsg = [[dic_getResponse objectForKey:str_ErrMsgKey] objectForKey:@"text"];
                    NSLog(@"ErrCode = %@",str_ErrCode);

                    // 通信エラーメッセージ表示
                    [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"\n%@\n\nエラーコード（%@）", str_ErrMsg, str_ErrCode] errorCode:[str_ErrCode integerValue]];
                }

            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }

    if(session == _session_Get_PointSearch_WSDLCheck){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Get_PointSearch_WSDLCheck];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Get_PointSearch_WSDLCheck;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Get_PointSearch_WSDLCheck];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                //basa名取得
                _basename_Get_PointSearch = [self get_baseName:_initialiseData_Get_PointSearch_WSDLCheck name:@"OCardPoint" errorcode:_statusCode_Get_PointSearch_WSDLCheck];

                //colom basa名取得
                _colomBasename_Get_PointSearch = [self get_colom_baseName:_initialiseData_Get_PointSearch_WSDLCheck name:@"OCardPoint" errorcode:_statusCode_Get_PointSearch_WSDLCheck];

                //colom base [ax]で始まらないbaseを設定
                if([_colomBasename_Get_PointSearch length] > 0){
                    if(![[_colomBasename_Get_PointSearch substringToIndex:2] isEqualToString:@"ax"]){

                        _colomBasename_Get_PointSearch = _basename_Get_PointSearch;
                    }
                }else{
                    //colom basa名ない場合、basenameを設定する
                    _colomBasename_Get_PointSearch = _basename_Get_PointSearch;
                }

                //endpoint取得
                _endpoint_Get_PointSearch = [self get_endpointName:_initialiseData_Get_PointSearch_WSDLCheck name:@"PointSearchHttpsSoap12Endpoint" errorcode:_statusCode_Get_PointSearch_WSDLCheck];

                if([_basename_Get_PointSearch length] > 0){
                    if([_colomBasename_Get_PointSearch length] > 0){
                        if([_endpoint_Get_PointSearch length] > 0){

                            [_apidelegate Soap_Api_WSDLCheck_BackAction:@"Get_PointSearch_WSDLCheck" basename:_basename_Get_PointSearch];
                        }
                    }
                }

            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }
    if(session == _session_Get_PointSearch){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Get_PointSearch];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Get_PointSearch;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Get_PointSearch];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                NSDictionary *dic_parse = [XmlToDictionaly dictionaryForXMLData:_initialiseData_Get_PointSearch error:nil];
                //NSLog(@"%@",dic_parse);

                NSDictionary *dic_body = [[dic_parse objectForKey:@"soapenv:Envelope"] objectForKey:@"soapenv:Body"];
                NSLog(@"%@",dic_body);

                NSDictionary *dic_getResponse = [[dic_body objectForKey:@"ns:getPointZndkResponse"] objectForKey:@"ns:return"];
                NSLog(@"%@",dic_getResponse);

                //APIエラーコード取得
                NSString *str_ErrCodeKey = [NSString stringWithFormat:@"%@:errCd",_basename_Get_PointSearch];
                NSString *str_ErrCode = [[dic_getResponse objectForKey:str_ErrCodeKey] objectForKey:@"text"];
                NSLog(@"ErrCode = %@",str_ErrCode);

                if(str_ErrCode.length == 0){

                    [_apidelegate Soap_Api_BackAction:@"Get_PointSearch" dicData:dic_getResponse basename:_colomBasename_Get_PointSearch errorcode:[[NSString stringWithFormat:@"%@", str_ErrCode] integerValue]];

                    [self unsetProgressHUD];

                } else {

                    NSString *str_ErrMsgKey = [NSString stringWithFormat:@"%@:errMes",_basename_Get_PointSearch];
                    NSString *str_ErrMsg = [[dic_getResponse objectForKey:str_ErrMsgKey] objectForKey:@"text"];
                    NSLog(@"ErrCode = %@",str_ErrCode);

                    // 通信エラーメッセージ表示
                    [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"\n%@\n\nエラーコード（%@）", str_ErrMsg, str_ErrCode] errorCode:[str_ErrCode integerValue]];
                }

            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }

    if(session == _session_Set_A300_ReceiveOrder_WSDLCheck){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Set_A300_ReceiveOrder_WSDLCheck];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Set_A300_ReceiveOrder_WSDLCheck;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Set_A300_ReceiveOrder_WSDLCheck];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                //basa名取得
                _basename_Set_A300_ReceiveOrder = [self get_baseName:_initialiseData_Set_A300_ReceiveOrder_WSDLCheck name:@"OReceiveOrder" errorcode:_statusCode_Set_A300_ReceiveOrder_WSDLCheck];

                //colom basa名取得
                _colomBasename_Set_A300_ReceiveOrder = [self get_colom_baseName:_initialiseData_Set_A300_ReceiveOrder_WSDLCheck name:@"OReceiveOrder" errorcode:_statusCode_Set_A300_ReceiveOrder_WSDLCheck];

                //colom base [ax]で始まらないbaseを設定
                if([_colomBasename_Set_A300_ReceiveOrder length] > 0){
                    if(![[_colomBasename_Set_A300_ReceiveOrder substringToIndex:2] isEqualToString:@"ax"]){

                        _colomBasename_Set_A300_ReceiveOrder = _basename_Set_A300_ReceiveOrder;
                    }
                }else{
                    //colom basa名ない場合、basenameを設定する
                    _colomBasename_Set_A300_ReceiveOrder = _basename_Set_A300_ReceiveOrder;
                }

                //endpoint取得
                _endpoint_Set_A300_ReceiveOrder = [self get_endpointName:_initialiseData_Set_A300_ReceiveOrder_WSDLCheck name:@"ReceiveOrderHttpsSoap12Endpoint" errorcode:_statusCode_Set_A300_ReceiveOrder_WSDLCheck];

                if([_basename_Set_A300_ReceiveOrder length] > 0){
                    if([_colomBasename_Set_A300_ReceiveOrder length] > 0){
                        if([_endpoint_Set_A300_ReceiveOrder length] > 0){

                            [_apidelegate Soap_Api_WSDLCheck_BackAction:@"Set_A300_ReceiveOrder_WSDLCheck" basename:_basename_Set_A300_ReceiveOrder];
                        }
                    }
                }

            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }
    if(session == _session_Set_A300_ReceiveOrder){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Set_A300_ReceiveOrder];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Set_A300_ReceiveOrder;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Set_A300_ReceiveOrder];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                NSDictionary *dic_parse = [XmlToDictionaly dictionaryForXMLData:_initialiseData_Set_A300_ReceiveOrder error:nil];
                //NSLog(@"%@",dic_parse);

                NSDictionary *dic_body = [[dic_parse objectForKey:@"soapenv:Envelope"] objectForKey:@"soapenv:Body"];
                NSLog(@"%@",dic_body);

                NSDictionary *dic_getResponse = [[dic_body objectForKey:@"ns:registroryOrderResponse"] objectForKey:@"ns:return"];
                NSLog(@"%@",dic_getResponse);

                //APIエラーコード取得
                NSString *str_ErrCodeKey = [NSString stringWithFormat:@"%@:errCd",_basename_Set_A300_ReceiveOrder];
                NSString *str_ErrCode = [[dic_getResponse objectForKey:str_ErrCodeKey] objectForKey:@"text"];
                NSLog(@"ErrCode = %@",str_ErrCode);

                if(str_ErrCode.length == 0){

                    [_apidelegate Soap_Api_BackAction:@"Set_A300_ReceiveOrder" dicData:dic_getResponse basename:_colomBasename_Set_A300_ReceiveOrder errorcode:[[NSString stringWithFormat:@"%@", str_ErrCode] integerValue]];

                    [self unsetProgressHUD];

                } else {

                    NSString *str_ErrMsgKey = [NSString stringWithFormat:@"%@:errMes",_basename_Set_A300_ReceiveOrder];
                    NSString *str_ErrMsg = [[dic_getResponse objectForKey:str_ErrMsgKey] objectForKey:@"text"];
                    NSLog(@"ErrCode = %@",str_ErrCode);

                    // 通信エラーメッセージ表示
                    [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"\n%@\n\nエラーコード（%@）", str_ErrMsg, str_ErrCode] errorCode:[str_ErrCode integerValue]];
                }

            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }

    if(session == _session_Set_A300_OrderConfirm_WSDLCheck){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Set_A300_OrderConfirm_WSDLCheck];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Set_A300_OrderConfirm_WSDLCheck;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Set_A300_OrderConfirm_WSDLCheck];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                //basa名取得
                _basename_Set_A300_OrderConfirm = [self get_baseName:_initialiseData_Set_A300_OrderConfirm_WSDLCheck name:@"OOrderConfirm" errorcode:_statusCode_Set_A300_OrderConfirm_WSDLCheck];

                //colom basa名取得
                _colomBasename_Set_A300_OrderConfirm = [self get_colom_baseName:_initialiseData_Set_A300_OrderConfirm_WSDLCheck name:@"OOrderConfirm" errorcode:_statusCode_Set_A300_OrderConfirm_WSDLCheck];

                //colom base [ax]で始まらないbaseを設定
                if([_colomBasename_Set_A300_OrderConfirm length] > 0){
                    if(![[_colomBasename_Set_A300_OrderConfirm substringToIndex:2] isEqualToString:@"ax"]){

                        _colomBasename_Set_A300_OrderConfirm = _basename_Set_A300_OrderConfirm;
                    }
                }else{
                    //colom basa名ない場合、basenameを設定する
                    _colomBasename_Set_A300_OrderConfirm = _basename_Set_A300_OrderConfirm;
                }

                //endpoint取得
                _endpoint_Set_A300_OrderConfirm = [self get_endpointName:_initialiseData_Set_A300_OrderConfirm_WSDLCheck name:@"OrderConfirmHttpsSoap12Endpoint" errorcode:_statusCode_Set_A300_OrderConfirm_WSDLCheck];

                if([_basename_Set_A300_OrderConfirm length] > 0){
                    if([_colomBasename_Set_A300_OrderConfirm length] > 0){
                        if([_endpoint_Set_A300_OrderConfirm length] > 0){

                            [_apidelegate Soap_Api_WSDLCheck_BackAction:@"Set_A300_OrderConfirm_WSDLCheck" basename:_basename_Set_A300_OrderConfirm];
                        }
                    }
                }

            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }
    if(session == _session_Set_A300_OrderConfirm){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Set_A300_OrderConfirm];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Set_A300_OrderConfirm;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Set_A300_OrderConfirm];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                NSDictionary *dic_parse = [XmlToDictionaly dictionaryForXMLData:_initialiseData_Set_A300_OrderConfirm error:nil];
                //NSLog(@"%@",dic_parse);

                NSDictionary *dic_body = [[dic_parse objectForKey:@"soapenv:Envelope"] objectForKey:@"soapenv:Body"];
                NSLog(@"%@",dic_body);

                NSDictionary *dic_getResponse = [[dic_body objectForKey:@"ns:shippingResponse"] objectForKey:@"ns:return"];
                NSLog(@"%@",dic_getResponse);

                //APIエラーコード取得
                NSString *str_ErrCodeKey = [NSString stringWithFormat:@"%@:errCd",_basename_Set_A300_OrderConfirm];
                NSString *str_ErrCode = [[dic_getResponse objectForKey:str_ErrCodeKey] objectForKey:@"text"];
                NSLog(@"ErrCode = %@",str_ErrCode);

                if(str_ErrCode.length == 0){

                    [_apidelegate Soap_Api_BackAction:@"Set_A300_OrderConfirm" dicData:dic_getResponse basename:_colomBasename_Set_A300_OrderConfirm errorcode:[[NSString stringWithFormat:@"%@", str_ErrCode] integerValue]];

                    [self unsetProgressHUD];

                } else {

                    NSString *str_ErrMsgKey = [NSString stringWithFormat:@"%@:errMes",_basename_Set_A300_OrderConfirm];
                    NSString *str_ErrMsg = [[dic_getResponse objectForKey:str_ErrMsgKey] objectForKey:@"text"];
                    NSLog(@"ErrCode = %@",str_ErrCode);

                    // 通信エラーメッセージ表示
                    [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"\n%@\n\nエラーコード（%@）", str_ErrMsg, str_ErrCode] errorCode:[str_ErrCode integerValue]];
                }

            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }

    if(session == _session_Set_A400_PointUpdate_WSDLCheck){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Set_A400_PointUpdate_WSDLCheck];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Set_A400_PointUpdate_WSDLCheck;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Set_A400_PointUpdate_WSDLCheck];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                //basa名取得
                _basename_Set_A400_PointUpdate = [self get_baseName:_initialiseData_Set_A400_PointUpdate_WSDLCheck name:@"OPointUpdate" errorcode:_statusCode_Set_A400_PointUpdate_WSDLCheck];

                //colom basa名取得
                _colomBasename_Set_A400_PointUpdate = [self get_colom_baseName:_initialiseData_Set_A400_PointUpdate_WSDLCheck name:@"OPointUpdate" errorcode:_statusCode_Set_A400_PointUpdate_WSDLCheck];

                //colom base [ax]で始まらないbaseを設定
                if([_colomBasename_Set_A400_PointUpdate length] > 0){
                    if(![[_colomBasename_Set_A400_PointUpdate substringToIndex:2] isEqualToString:@"ax"]){

                        _colomBasename_Set_A400_PointUpdate = _basename_Set_A400_PointUpdate;
                    }
                }else{
                    //colom basa名ない場合、basenameを設定する
                    _colomBasename_Set_A400_PointUpdate = _basename_Set_A400_PointUpdate;
                }

                //endpoint取得
                _endpoint_Set_A400_PointUpdate = [self get_endpointName:_initialiseData_Set_A400_PointUpdate_WSDLCheck name:@"PointUpdateHttpsSoap12Endpoint" errorcode:_statusCode_Set_A400_PointUpdate_WSDLCheck];

                if([_basename_Set_A400_PointUpdate length] > 0){
                    if([_colomBasename_Set_A400_PointUpdate length] > 0){
                        if([_endpoint_Set_A400_PointUpdate length] > 0){

                            [_apidelegate Soap_Api_WSDLCheck_BackAction:@"Set_A400_PointUpdate_WSDLCheck" basename:_basename_Set_A400_PointUpdate];
                        }
                    }
                }

            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }
    if(session == _session_Set_A400_PointUpdate){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Set_A400_PointUpdate];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Set_A400_PointUpdate;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Set_A400_PointUpdate];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                NSDictionary *dic_parse = [XmlToDictionaly dictionaryForXMLData:_initialiseData_Set_A400_PointUpdate error:nil];
                //NSLog(@"%@",dic_parse);

                NSDictionary *dic_body = [[dic_parse objectForKey:@"soapenv:Envelope"] objectForKey:@"soapenv:Body"];
                NSLog(@"%@",dic_body);

                NSDictionary *dic_getResponse = [[dic_body objectForKey:@"ns:updateResponse"] objectForKey:@"ns:return"];
                NSLog(@"%@",dic_getResponse);

                //APIエラーコード取得
                NSString *str_ErrCodeKey = [NSString stringWithFormat:@"%@:errCd",_basename_Set_A400_PointUpdate];
                NSString *str_ErrCode = [[dic_getResponse objectForKey:str_ErrCodeKey] objectForKey:@"text"];
                NSLog(@"ErrCode = %@",str_ErrCode);

                if(str_ErrCode.length == 0){

                    [_apidelegate Soap_Api_BackAction:@"Set_A400_PointUpdate" dicData:dic_getResponse basename:_colomBasename_Set_A400_PointUpdate errorcode:[[NSString stringWithFormat:@"%@", str_ErrCode] integerValue]];

                    [self unsetProgressHUD];

                } else {

                    NSString *str_ErrMsgKey = [NSString stringWithFormat:@"%@:errMes",_basename_Set_A400_PointUpdate];
                    NSString *str_ErrMsg = [[dic_getResponse objectForKey:str_ErrMsgKey] objectForKey:@"text"];
                    NSLog(@"ErrCode = %@",str_ErrCode);

                    // 通信エラーメッセージ表示
                    [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"\n%@\n\nエラーコード（%@）", str_ErrMsg, str_ErrCode] errorCode:[str_ErrCode integerValue]];
                }

            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }

    if(session == _session_Get_MailAddressCheck_WSDLCheck){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Get_MailAddressCheck_WSDLCheck];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Get_MailAddressCheck_WSDLCheck;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Get_MailAddressCheck_WSDLCheck];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                //basa名取得
                _basename_Get_MailAddressCheck = [self get_baseName:_initialiseData_Get_MailAddressCheck_WSDLCheck name:@"OMailAddressCheck" errorcode:_statusCode_Get_MailAddressCheck_WSDLCheck];

                //colom basa名取得
                _colomBasename_Get_MailAddressCheck = [self get_colom_baseName:_initialiseData_Get_MailAddressCheck_WSDLCheck name:@"OMailAddressCheck" errorcode:_statusCode_Get_MailAddressCheck_WSDLCheck];

                //colom base [ax]で始まらないbaseを設定
                if([_colomBasename_Get_MailAddressCheck length] > 0){
                    if(![[_colomBasename_Get_MailAddressCheck substringToIndex:2] isEqualToString:@"ax"]){

                        _colomBasename_Get_MailAddressCheck = _basename_Get_MailAddressCheck;
                    }
                }else{
                    //colom basa名ない場合、basenameを設定する
                    _colomBasename_Get_MailAddressCheck = _basename_Get_MailAddressCheck;
                }

                //endpoint取得
                _endpoint_Get_MailAddressCheck = [self get_endpointName:_initialiseData_Get_MailAddressCheck_WSDLCheck name:@"MailAddressCheckHttpsSoap12Endpoint" errorcode:_statusCode_Get_MailAddressCheck_WSDLCheck];

                if([_basename_Get_MailAddressCheck length] > 0){
                    if([_colomBasename_Get_MailAddressCheck length] > 0){
                        if([_endpoint_Get_MailAddressCheck length] > 0){

                            [_apidelegate Soap_Api_WSDLCheck_BackAction:@"Get_MailAddressCheck_WSDLCheck" basename:_basename_Get_MailAddressCheck];
                        }
                    }
                }

            } else {

                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }
    if(session == _session_Get_MailAddressCheck){

        if (error) {

            // 通信エラーメッセージ表示
            [self errorMessage:@"通信エラー" errorMessage:@"サーバーに接続出来ませんでした\n通信状態を確認してください" errorCode:_statusCode_Get_MailAddressCheck];

        } else {

            // HTTPリクエスト成功処理
            long statusCode = _statusCode_Get_MailAddressCheck;

            NSData* receivedData = [[NSData alloc] initWithData:_initialiseData_Get_MailAddressCheck];
            NSString *str_data= [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str_data);

            //正常読み込み時
            if(statusCode == 200){

                NSDictionary *dic_parse = [XmlToDictionaly dictionaryForXMLData:_initialiseData_Get_MailAddressCheck error:nil];
                //NSLog(@"%@",dic_parse);

                NSDictionary *dic_body = [[dic_parse objectForKey:@"soapenv:Envelope"] objectForKey:@"soapenv:Body"];
                NSLog(@"%@",dic_body);

                NSDictionary *dic_getResponse = [[dic_body objectForKey:@"ns:inspectionResponse"] objectForKey:@"ns:return"];
                NSLog(@"%@",dic_getResponse);

                //APIエラーコード取得
                NSString *str_ErrCodeKey = [NSString stringWithFormat:@"%@:errCd",_basename_Get_MailAddressCheck];
                NSString *str_ErrCode = [[dic_getResponse objectForKey:str_ErrCodeKey] objectForKey:@"text"];
                NSLog(@"ErrCode = %@",str_ErrCode);

                if(str_ErrCode.length == 0){

                    [_apidelegate Soap_Api_BackAction:@"Get_MailAddressCheck" dicData:dic_getResponse basename:_colomBasename_Get_MailAddressCheck errorcode:[[NSString stringWithFormat:@"%@", str_ErrCode] integerValue]];

                    [self unsetProgressHUD];

                } else {

                    NSString *str_ErrMsgKey = [NSString stringWithFormat:@"%@:errMes",_basename_Get_MailAddressCheck];
                    NSString *str_ErrMsg = [[dic_getResponse objectForKey:str_ErrMsgKey] objectForKey:@"text"];
                    NSLog(@"ErrCode = %@",str_ErrCode);
                    
                    // 通信エラーメッセージ表示
                    [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"\n%@\n\nエラーコード（%@）", str_ErrMsg, str_ErrCode] errorCode:[str_ErrCode integerValue]];
                }
                
            } else {
                
                // 通信エラーメッセージ表示
                [self errorMessage:@"alert" errorMessage:[NSString stringWithFormat:@"エラーコード（%lu）", statusCode] errorCode:statusCode];
            }
        }
    }
}

/////////////// ↑　通信用メソッド　↑　////////////////////

- (void)Get_Test1_WSDLCheck {

    [self setProgressHUD];

    // GET通信
    NSString *str_URL = [NSString stringWithFormat:@"%@/PointSearch?wsdl",[self getDomain]];
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:lng_Timeout];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_test1_WSDLCheck = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                   delegate:self
                                              delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_test1_WSDLCheck dataTaskWithRequest:request];
    [task resume];
}
- (void)Get_Test1 {

    // POST通信
    NSString *str_URL = _endpoint_test1;
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    NSString *requestBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:act=\"http://action.webapi.hsp\" xmlns:xsd=\"http://inout.webapi.hsp/xsd\">"
                             "<soap:Header/>"
                             "<soap:Body>"
                             "<act:getPointZndk>"
                             "<!--Optional:-->"
                             "<act:in>"
                             "<!--Optional:-->"
                             "<xsd:cardNb>%@</xsd:cardNb>"
                             "</act:in>"
                             "</act:getPointZndk>"
                             "</soap:Body>"
                             "</soap:Envelope>", @"30000003176"];
    NSString *msgLength = [NSString stringWithFormat:@"%@", @(requestBody.length)];
    [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:lng_Timeout];
    [request setHTTPBody: [requestBody dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_test1 = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                   delegate:self
                                              delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_test1 dataTaskWithRequest:request];
    [task resume];
}

- (void)Set_A901_KigyoSalonStoreCheck_WSDLCheck {

    [self setProgressHUD];

    // GET通信
    NSString *str_URL = [NSString stringWithFormat:@"%@/KigyoSalonStoreCheck?wsdl",[self getDomain]];
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:lng_Timeout];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Set_A901_KigyoSalonStoreCheck_WSDLCheck = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                             delegate:self
                                                        delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Set_A901_KigyoSalonStoreCheck_WSDLCheck dataTaskWithRequest:request];
    [task resume];
}
- (void)Set_A901_KigyoSalonStoreCheck:(NSString*)CompanyCode salonStoreCd:(NSString*)salonStoreCd {

    // POST通信
    NSString *str_URL = _endpoint_Set_A901_KigyoSalonStoreCheck;
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    NSString *requestBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:act=\"http://action.webapi.hsp\" xmlns:xsd=\"http://inout.webapi.hsp/xsd\">"
                             "<soap:Header/>"
                             "<soap:Body>"
                             "<act:kigyoSalonStoreCheck>"
                             "<!--Optional:-->"
                             "<act:in>"
                             "<!--Optional:-->"
                             "<xsd:companyCd>%@</xsd:companyCd>"
                             "<!--Optional:-->"
                             "<xsd:salonStoreCd>%@</xsd:salonStoreCd>"
                             "</act:in>"
                             "</act:kigyoSalonStoreCheck>"
                             "</soap:Body>"
                             "</soap:Envelope>", CompanyCode, salonStoreCd];
    NSString *msgLength = [NSString stringWithFormat:@"%@", @(requestBody.length)];
    [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:lng_Timeout];
    [request setHTTPBody: [requestBody dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Set_A901_KigyoSalonStoreCheck = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                   delegate:self
                                              delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Set_A901_KigyoSalonStoreCheck dataTaskWithRequest:request];
    [task resume];
}

- (void)Get_A902_PointRateCheck_WSDLCheck {

    [self setProgressHUD];

    // GET通信
    NSString *str_URL = [NSString stringWithFormat:@"%@/PointRateCheck?wsdl",[self getDomain]];
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:lng_Timeout];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Get_A902_PointRateCheck_WSDLCheck = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                             delegate:self
                                                        delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Get_A902_PointRateCheck_WSDLCheck dataTaskWithRequest:request];
    [task resume];
}
- (void)Get_A902_PointRateCheck:(NSString*)CompanyCode kaiinKb:(NSString*)kaiinKb {

    // POST通信
    NSString *str_URL = _endpoint_Get_A902_PointRateCheck;
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    NSString *requestBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:act=\"http://action.webapi.hsp\" xmlns:xsd=\"http://inout.webapi.hsp/xsd\">"
                             "<soap:Header/>"
                             "<soap:Body>"
                             "<act:search>"
                             "<!--Optional:-->"
                             "<act:in>"
                             "<!--Optional:-->"
                             "<xsd:companyCd>%@</xsd:companyCd>"
                             "<!--Optional:-->"
                             "<xsd:memberKb>%@</xsd:memberKb>"
                             "</act:in>"
                             "</act:search>"
                             "</soap:Body>"
                             "</soap:Envelope>", CompanyCode, kaiinKb];
    NSString *msgLength = [NSString stringWithFormat:@"%@", @(requestBody.length)];
    [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:lng_Timeout];
    [request setHTTPBody: [requestBody dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Get_A902_PointRateCheck = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                                           delegate:self
                                                                      delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Get_A902_PointRateCheck dataTaskWithRequest:request];
    [task resume];
}

- (void)Set_A902_PointRateSetting_WSDLCheck {

    [self setProgressHUD];

    // GET通信
    NSString *str_URL = [NSString stringWithFormat:@"%@/PointRateSetting?wsdl",[self getDomain]];
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:lng_Timeout];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Set_A902_PointRateSetting_WSDLCheck = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                                               delegate:self
                                                                          delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Set_A902_PointRateSetting_WSDLCheck dataTaskWithRequest:request];
    [task resume];
}
- (void)Set_A902_PointRateSetting:(NSString*)CompanyCode kaiinKb:(NSString*)kaiinKb pointGrantRate:(NSString*)pointGrantRate {

    // POST通信
    NSString *str_URL = _endpoint_Set_A902_PointRateSetting;
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    NSString *requestBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:act=\"http://action.webapi.hsp\" xmlns:xsd=\"http://inout.webapi.hsp/xsd\">"
                             "<soap:Header/>"
                             "<soap:Body>"
                             "<act:registoryPointRate>"
                             "<!--Optional:-->"
                             "<act:in>"
                             "<!--Optional:-->"
                             "<xsd:companyCd>%@</xsd:companyCd>"
                             "<!--Optional:-->"
                             "<xsd:memberKb>%@</xsd:memberKb>"
                             "<!--Optional:-->"
                             "<xsd:minAddPointVl>%@</xsd:minAddPointVl>"
                             "<!--Optional:-->"
                             "<xsd:point>%@</xsd:point>"
                             "<!--Optional:-->"
                             "<xsd:rateVl>%@</xsd:rateVl>"
                             "</act:in>"
                             "</act:registoryPointRate>"
                             "</soap:Body>"
                             "</soap:Envelope>", CompanyCode, kaiinKb, pointGrantRate, @"1", pointGrantRate];
    NSString *msgLength = [NSString stringWithFormat:@"%@", @(requestBody.length)];
    [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:lng_Timeout];
    [request setHTTPBody: [requestBody dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Set_A902_PointRateSetting = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                                     delegate:self
                                                                delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Set_A902_PointRateSetting dataTaskWithRequest:request];
    [task resume];
}

- (void)Set_A100_MemberRegist_WSDLCheck {

    [self setProgressHUD];

    // GET通信
    NSString *str_URL = [NSString stringWithFormat:@"%@/MemberRegist?wsdl",[self getDomain]];
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:lng_Timeout];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Set_A100_MemberRegist_WSDLCheck = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                             delegate:self
                                                        delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Set_A100_MemberRegist_WSDLCheck dataTaskWithRequest:request];
    [task resume];
}
- (void)Set_A100_MemberRegist:(NSString*)torokuKoushinKb
                   nyutenpoCd:(NSString*)nyutenpoCd
                      emailAd:(NSString*)emailAd
                     simeisNa:(NSString*)simeisNa
                     simeimNa:(NSString*)simeimNa
                 salonStoreCd:(NSString*)salonStoreCd
                      sigaiNb:(NSString*)sigaiNb
                      sinaiNb:(NSString*)sinaiNb
                   kanyusyaNb:(NSString*)kanyusyaNb
                      yubinNb:(NSString*)yubinNb
                     jusyoNa1:(NSString*)jusyoNa1
                     jusyoNa2:(NSString*)jusyoNa2
                     jusyoNa3:(NSString*)jusyoNa3
                otherSystemCd:(NSString*)otherSystemCd {

    // POST通信
    NSString *str_URL = _endpoint_Set_A100_MemberRegist;
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    NSString *requestBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:act=\"http://action.webapi.hsp\" xmlns:xsd=\"http://inout.webapi.hsp/xsd\">"
                             "<soap:Header/>"
                             "<soap:Body>"
                             "<act:mergeMemberInfo>"
                             "<!--Optional:-->"
                             "<act:in>"
                             "<!--Optional:-->"
                             "<xsd:affiliationStore></xsd:affiliationStore>"
                             "<!--Optional:-->"
                             "<xsd:applying></xsd:applying>"
                             "<!--Optional:-->"
                             "<xsd:birthDt></xsd:birthDt>"
                             "<!--Optional:-->"
                             "<xsd:cardKb></xsd:cardKb>"
                             "<!--Optional:-->"
                             "<xsd:cardNb></xsd:cardNb>"
                             "<!--Optional:-->"
                             "<xsd:edaNb></xsd:edaNb>"
                             "<!--Optional:-->"
                             "<xsd:emailAd>%@</xsd:emailAd>"
                             "<!--Optional:-->"
                             "<xsd:emailDeliHope></xsd:emailDeliHope>"
                             "<!--Optional:-->"
                             "<xsd:emailbanFg></xsd:emailbanFg>"
                             "<!--Optional:-->"
                             "<xsd:freeSetting1></xsd:freeSetting1>"
                             "<!--Optional:-->"
                             "<xsd:freeSetting2></xsd:freeSetting2>"
                             "<!--Optional:-->"
                             "<xsd:freeSetting3></xsd:freeSetting3>"
                             "<!--Optional:-->"
                             "<xsd:freeSetting4></xsd:freeSetting4>"
                             "<!--Optional:-->"
                             "<xsd:freeSetting5></xsd:freeSetting5>"
                             "<!--Optional:-->"
                             "<xsd:hakkouDt></xsd:hakkouDt>"
                             "<!--Optional:-->"
                             "<xsd:hakkoukaiCd></xsd:hakkoukaiCd>"
                             "<!--Optional:-->"
                             "<xsd:hakkoutenCd></xsd:hakkoutenCd>"
                             "<!--Optional:-->"
                             "<xsd:hansokuKb></xsd:hansokuKb>"
                             "<!--Optional:-->"
                             "<xsd:jusyoKa1></xsd:jusyoKa1>"
                             "<!--Optional:-->"
                             "<xsd:jusyoKa2></xsd:jusyoKa2>"
                             "<!--Optional:-->"
                             "<xsd:jusyoNa1>%@</xsd:jusyoNa1>"
                             "<!--Optional:-->"
                             "<xsd:jusyoNa2>%@</xsd:jusyoNa2>"
                             "<!--Optional:-->"
                             "<xsd:jusyoNa3>%@</xsd:jusyoNa3>"
                             "<!--Optional:-->"
                             "<xsd:jusyoNa4></xsd:jusyoNa4>"
                             "<!--Optional:-->"
                             "<xsd:kanyusyaNb>%@</xsd:kanyusyaNb>"
                             "<!--Optional:-->"
                             "<xsd:keitaiAd></xsd:keitaiAd>"
                             "<!--Optional:-->"
                             "<xsd:keitaiKb></xsd:keitaiKb>"
                             "<!--Optional:-->"
                             "<xsd:keitaibanFg></xsd:keitaibanFg>"
                             "<!--Optional:-->"
                             "<xsd:keiyakuDt></xsd:keiyakuDt>"
                             "<!--Optional:-->"
                             "<xsd:licenseTestType></xsd:licenseTestType>"
                             "<!--Optional:-->"
                             "<xsd:mailSendKb></xsd:mailSendKb>"
                             "<!--Optional:-->"
                             "<xsd:memberKb></xsd:memberKb>"
                             "<!--Optional:-->"
                             "<xsd:nyukaisyaCd></xsd:nyukaisyaCd>"
                             "<!--Optional:-->"
                             "<xsd:nyutenpoCd>%@</xsd:nyutenpoCd>"
                             "<!--Optional:-->"
                             "<xsd:otherSystemCd>%@</xsd:otherSystemCd>"
                             "<!--Optional:-->"
                             "<xsd:password></xsd:password>"
                             "<!--Optional:-->"
                             "<xsd:postbanFg></xsd:postbanFg>"
                             "<!--Optional:-->"
                             "<xsd:salonStoreCd>%@</xsd:salonStoreCd>"
                             "<!--Optional:-->"
                             "<xsd:schoolCustCd></xsd:schoolCustCd>"
                             "<!--Optional:-->"
                             "<xsd:schoolName></xsd:schoolName>"
                             "<!--Optional:-->"
                             "<xsd:sexKb></xsd:sexKb>"
                             "<!--Optional:-->"
                             "<xsd:sigaiNb>%@</xsd:sigaiNb>"
                             "<!--Optional:-->"
                             "<xsd:simeimKa></xsd:simeimKa>"
                             "<!--Optional:-->"
                             "<xsd:simeimNa>%@</xsd:simeimNa>"
                             "<!--Optional:-->"
                             "<xsd:simeisKa></xsd:simeisKa>"
                             "<!--Optional:-->"
                             "<xsd:simeisNa>%@</xsd:simeisNa>"
                             "<!--Optional:-->"
                             "<xsd:sinaiNb>%@</xsd:sinaiNb>"
                             "<!--Optional:-->"
                             "<xsd:torokuKoushinKb>%@</xsd:torokuKoushinKb>"
                             "<!--Optional:-->"
                             "<xsd:yubinNb>%@</xsd:yubinNb>"
                             "<!--Optional:-->"
                             "<xsd:yukoYm></xsd:yukoYm>"
                             "</act:in>"
                             "</act:mergeMemberInfo>"
                             "</soap:Body>"
                             "</soap:Envelope>",
                             emailAd,
                             jusyoNa1,
                             jusyoNa2,
                             jusyoNa3,
                             kanyusyaNb,
                             nyutenpoCd,
                             otherSystemCd,
                             salonStoreCd,
                             sigaiNb,
                             simeimNa,
                             simeisNa,
                             sinaiNb,
                             torokuKoushinKb,
                             yubinNb];
    NSString *msgLength = [NSString stringWithFormat:@"%@", @(requestBody.length)];
    [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:lng_Timeout];
    [request setHTTPBody: [requestBody dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Set_A100_MemberRegist = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                                       delegate:self
                                                                  delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Set_A100_MemberRegist dataTaskWithRequest:request];
    [task resume];
}

- (void)Get_A200_PointHistorySearch_WSDLCheck {

    [self setProgressHUD];

    // GET通信
    NSString *str_URL = [NSString stringWithFormat:@"%@/PointHistorySearch?wsdl",[self getDomain]];
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:lng_Timeout];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Get_A200_PointHistorySearch_WSDLCheck = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                             delegate:self
                                                        delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Get_A200_PointHistorySearch_WSDLCheck dataTaskWithRequest:request];
    [task resume];
}
- (void)Get_A200_PointHistorySearch:(NSString*)cardNo companyCd:(NSString*)companyCd {

    // POST通信
    NSString *str_URL = _endpoint_Get_A200_PointHistorySearch;
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    NSString *requestBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:act=\"http://action.webapi.hsp\" xmlns:xsd=\"http://inout.webapi.hsp/xsd\">"
                             "<soap:Header/>"
                             "<soap:Body>"
                             "<act:getPointHistory>"
                             "<!--Optional:-->"
                             "<act:in>"
                             "<!--Optional:-->"
                             "<xsd:cardNb>%@</xsd:cardNb>"
                             "<!--Optional:-->"
                             "<xsd:companyCd>%@</xsd:companyCd>"
                             "<!--Optional:-->"
                             "<xsd:dispCnt></xsd:dispCnt>"
                             "<!--Optional:-->"
                             "<xsd:searchPeriodFrom></xsd:searchPeriodFrom>"
                             "<!--Optional:-->"
                             "<xsd:searchPeriodTo></xsd:searchPeriodTo>"
                             "<!--Optional:-->"
                             "<xsd:startColumn></xsd:startColumn>"
                             "</act:in>"
                             "</act:getPointHistory>"
                             "</soap:Body>"
                             "</soap:Envelope>", cardNo, companyCd];
    NSString *msgLength = [NSString stringWithFormat:@"%@", @(requestBody.length)];
    [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:lng_Timeout];
    [request setHTTPBody: [requestBody dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Get_A200_PointHistorySearch = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                   delegate:self
                                              delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Get_A200_PointHistorySearch dataTaskWithRequest:request];
    [task resume];
}

- (void)Get_SearchMember_WSDLCheck {

    [self setProgressHUD];

    // GET通信
    NSString *str_URL = [NSString stringWithFormat:@"%@/SearchMember?wsdl",[self getDomain]];
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:lng_Timeout];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Get_SearchMember_WSDLCheck = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                                                   delegate:self
                                                                              delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Get_SearchMember_WSDLCheck dataTaskWithRequest:request];
    [task resume];
}
- (void)Get_SearchMember:(NSString*)cardNo
               companyCd:(NSString*)companyCd
               emailAd:(NSString*)emailAd
               phoneNumber:(NSString*)phoneNumber {

    // POST通信
    NSString *str_URL = _endpoint_Get_SearchMember;
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    NSString *requestBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:act=\"http://action.webapi.hsp\" xmlns:xsd=\"http://inout.webapi.hsp/xsd\">"
                             "<soap:Header/>"
                             "<soap:Body>"
                             "<act:search>"
                             "<!--Optional:-->"
                             "<act:in>"
                             "<!--Optional:-->"
                             "<xsd:cardNb>%@</xsd:cardNb>"
                             "<!--Optional:-->"
                             "<xsd:companyCd>%@</xsd:companyCd>"
                             "<!--Optional:-->"
                             "<xsd:emailAd>%@</xsd:emailAd>"
                             "<!--Optional:-->"
                             "<xsd:phoneNumber>%@</xsd:phoneNumber>"
                             "</act:in>"
                             "</act:search>"
                             "</soap:Body>"
                             "</soap:Envelope>", cardNo, companyCd ,emailAd, phoneNumber];
    NSString *msgLength = [NSString stringWithFormat:@"%@", @(requestBody.length)];
    [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:lng_Timeout];
    [request setHTTPBody: [requestBody dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Get_SearchMember = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                                         delegate:self
                                                                    delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Get_SearchMember dataTaskWithRequest:request];
    [task resume];
}

- (void)Get_PointSearch_WSDLCheck {

    [self setProgressHUD];

    // GET通信
    NSString *str_URL = [NSString stringWithFormat:@"%@/PointSearch?wsdl",[self getDomain]];
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:lng_Timeout];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Get_PointSearch_WSDLCheck = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                             delegate:self
                                                        delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Get_PointSearch_WSDLCheck dataTaskWithRequest:request];
    [task resume];
}
- (void)Get_PointSearch:(NSString*)cardNo {

    // POST通信
    NSString *str_URL = _endpoint_Get_PointSearch;
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    NSString *requestBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:act=\"http://action.webapi.hsp\" xmlns:xsd=\"http://inout.webapi.hsp/xsd\">"
                             "<soap:Header/>"
                             "<soap:Body>"
                             "<act:getPointZndk>"
                             "<!--Optional:-->"
                             "<act:in>"
                             "<!--Optional:-->"
                             "<xsd:cardNb>%@</xsd:cardNb>"
                             "</act:in>"
                             "</act:getPointZndk>"
                             "</soap:Body>"
                             "</soap:Envelope>", cardNo];
    NSString *msgLength = [NSString stringWithFormat:@"%@", @(requestBody.length)];
    [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:lng_Timeout];
    [request setHTTPBody: [requestBody dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Get_PointSearch = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                   delegate:self
                                              delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Get_PointSearch dataTaskWithRequest:request];
    [task resume];
}

- (void)Set_A300_ReceiveOrder_WSDLCheck {

    [self setProgressHUD];

    // GET通信
    NSString *str_URL = [NSString stringWithFormat:@"%@/ReceiveOrder?wsdl",[self getDomain]];
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:lng_Timeout];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Set_A300_ReceiveOrder_WSDLCheck = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                                       delegate:self
                                                                  delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Set_A300_ReceiveOrder_WSDLCheck dataTaskWithRequest:request];
    [task resume];
}
- (void)Set_A300_ReceiveOrder:(NSString*)syoriKb
                   torihikiNb:(NSString*)torihikiNb
                   torihikiKb:(NSString*)torihikiKb
                    companyCd:(NSString*)companyCd
                       cardNb:(NSString*)cardNb
                     kaiageDt:(NSString*)kaiageDt
                     kaiageTm:(NSString*)kaiageTm
                     systemKb:(NSString*)systemKb
                   kaikinttVl:(NSString*)kaikinttVl
                    ptkinttVl:(NSString*)ptkinttVl
                   paypointQt:(NSString*)paypointQt {

    // POST通信
    NSString *str_URL = _endpoint_Set_A300_ReceiveOrder;
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    NSString *requestBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:act=\"http://action.webapi.hsp\" xmlns:xsd=\"http://inout.webapi.hsp/xsd\">"
                             "<soap:Header/>"
                             "<soap:Body>"
                             "<act:registroryOrder>"
                             "<!--Optional:-->"
                             "<act:in>"
                             "<!--Optional:-->"
                             "<xsd:errCd></xsd:errCd>"
                             "<!--Optional:-->"
                             "<xsd:errMes></xsd:errMes>"
                             "<!--Optional:-->"
                             "<xsd:notify></xsd:notify>"
                             "<!--Optional:-->"
                             "<xsd:rownum></xsd:rownum>"
                             "<!--Optional:-->"
                             "<xsd:cardNb>%@</xsd:cardNb>"
                             "<!--Optional:-->"
                             "<xsd:companyCd>%@</xsd:companyCd>"
                             "<!--Optional:-->"
                             "<xsd:kaiageDt>%@</xsd:kaiageDt>"
                             "<!--Optional:-->"
                             "<xsd:kaiageTm>%@</xsd:kaiageTm>"
                             "<!--Optional:-->"
                             "<xsd:kaikinttVl>%@</xsd:kaikinttVl>"
                             "<!--Optional:-->"
                             "<xsd:paypointQt>%@</xsd:paypointQt>"
                             "<!--Optional:-->"
                             "<xsd:ptkinttVl>%@</xsd:ptkinttVl>"
                             "<!--Optional:-->"
                             "<xsd:syoriKb>%@</xsd:syoriKb>"
                             "<!--Optional:-->"
                             "<xsd:systemKb>%@</xsd:systemKb>"
                             "<!--Optional:-->"
                             "<xsd:torihikiKb>%@</xsd:torihikiKb>"
                             "<!--Optional:-->"
                             "<xsd:torihikiNb>%@</xsd:torihikiNb>"
                             "</act:in>"
                             "</act:registroryOrder>"
                             "</soap:Body>"
                             "</soap:Envelope>", cardNb, companyCd, kaiageDt, kaiageTm, kaikinttVl, paypointQt, ptkinttVl, syoriKb, systemKb, torihikiKb, torihikiNb];
    NSString *msgLength = [NSString stringWithFormat:@"%@", @(requestBody.length)];
    [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:lng_Timeout];
    [request setHTTPBody: [requestBody dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Set_A300_ReceiveOrder = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                             delegate:self
                                                        delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Set_A300_ReceiveOrder dataTaskWithRequest:request];
    [task resume];
}

- (void)Set_A300_OrderConfirm_WSDLCheck {

    [self setProgressHUD];

    // GET通信
    NSString *str_URL = [NSString stringWithFormat:@"%@/OrderConfirm?wsdl",[self getDomain]];
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:lng_Timeout];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Set_A300_OrderConfirm_WSDLCheck = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                             delegate:self
                                                        delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Set_A300_OrderConfirm_WSDLCheck dataTaskWithRequest:request];
    [task resume];
}
- (void)Set_A300_OrderConfirm:(NSString*)cardNb
                    companyCd:(NSString*)companyCd
                     kaiageDt:(NSString*)kaiageDt
                     kaiageTm:(NSString*)kaiageTm
                     systemKb:(NSString*)systemKb
                   torihikiNb:(NSString*)torihikiNb {

    // POST通信
    NSString *str_URL = _endpoint_Set_A300_OrderConfirm;
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    NSString *requestBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:act=\"http://action.webapi.hsp\" xmlns:xsd=\"http://inout.webapi.hsp/xsd\">"
                             "<soap:Header/>"
                             "<soap:Body>"
                             "<act:shipping>"
                             "<!--Optional:-->"
                             "<act:in>"
                             "<!--Optional:-->"
                             "<xsd:cardNb>%@</xsd:cardNb>"
                             "<!--Optional:-->"
                             "<xsd:companyCd>%@</xsd:companyCd>"
                             "<!--Optional:-->"
                             "<xsd:kaiageDt>%@</xsd:kaiageDt>"
                             "<!--Optional:-->"
                             "<xsd:kaiageTm>%@</xsd:kaiageTm>"
                             "<!--Optional:-->"
                             "<xsd:shippingDt>%@</xsd:shippingDt>"
                             "<!--Optional:-->"
                             "<xsd:shippingTm>%@</xsd:shippingTm>"
                             "<!--Optional:-->"
                             "<xsd:systemKb>%@</xsd:systemKb>"
                             "<!--Optional:-->"
                             "<xsd:torihikiNb>%@</xsd:torihikiNb>"
                             "</act:in>"
                             "</act:shipping>"
                             "</soap:Body>"
                             "</soap:Envelope>", cardNb, companyCd, kaiageDt, kaiageTm, kaiageDt, kaiageTm, systemKb, torihikiNb];
    NSString *msgLength = [NSString stringWithFormat:@"%@", @(requestBody.length)];
    [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:lng_Timeout];
    [request setHTTPBody: [requestBody dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Set_A300_OrderConfirm = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                   delegate:self
                                              delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Set_A300_OrderConfirm dataTaskWithRequest:request];
    [task resume];
}

- (void)Set_A400_PointUpdate_WSDLCheck {

    [self setProgressHUD];

    // GET通信
    NSString *str_URL = [NSString stringWithFormat:@"%@/PointUpdate?wsdl",[self getDomain]];
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:lng_Timeout];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Set_A400_PointUpdate_WSDLCheck = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                             delegate:self
                                                        delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Set_A400_PointUpdate_WSDLCheck dataTaskWithRequest:request];
    [task resume];
}
- (void)Set_A400_PointUpdate:(NSString*)cardNb
                   companyCd:(NSString*)companyCd
                    kaiageDt:(NSString*)kaiageDt
                    kaiageTm:(NSString*)kaiageTm
                  kaikinttVl:(NSString*)kaikinttVl
                   koushinKb:(NSString*)koushinKb
                       point:(NSString*)point
                      reason:(NSString*)reason
                    systemKb:(NSString*)systemKb
                  torihikiNb:(NSString*)torihikiNb {

    // POST通信
    NSString *str_URL = _endpoint_Set_A400_PointUpdate;
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    NSString *requestBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:act=\"http://action.webapi.hsp\" xmlns:xsd=\"http://inout.webapi.hsp/xsd\">"
                             "<soap:Header/>"
                             "<soap:Body>"
                             "<act:update>"
                             "<!--Optional:-->"
                             "<act:in>"
                             "<!--Optional:-->"
                             "<xsd:cardNb>%@</xsd:cardNb>"
                             "<!--Optional:-->"
                             "<xsd:companyCd>%@</xsd:companyCd>"
                             "<!--Optional:-->"
                             "<xsd:kaiageDt>%@</xsd:kaiageDt>"
                             "<!--Optional:-->"
                             "<xsd:kaiageTm>%@</xsd:kaiageTm>"
                             "<!--Optional:-->"
                             "<xsd:kaikinttVl>%@</xsd:kaikinttVl>"
                             "<!--Optional:-->"
                             "<xsd:koushinKb>%@</xsd:koushinKb>"
                             "<!--Optional:-->"
                             "<xsd:point>%@</xsd:point>"
                             "<!--Optional:-->"
                             "<xsd:reason>%@</xsd:reason>"
                             "<!--Optional:-->"
                             "<xsd:systemKb>%@</xsd:systemKb>"
                             "<!--Optional:-->"
                             "<xsd:torihikiNb>%@</xsd:torihikiNb>"
                             "</act:in>"
                             "</act:update>"
                             "</soap:Body>"
                             "</soap:Envelope>", cardNb, companyCd, kaiageDt, kaiageTm, kaikinttVl, koushinKb, point, reason, systemKb, torihikiNb];
    NSString *msgLength = [NSString stringWithFormat:@"%@", @(requestBody.length)];
    [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:lng_Timeout];
    [request setHTTPBody: [requestBody dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Set_A400_PointUpdate = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                   delegate:self
                                              delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Set_A400_PointUpdate dataTaskWithRequest:request];
    [task resume];
}

- (void)Get_MailAddressCheck_WSDLCheck {

    [self setProgressHUD];

    // GET通信
    NSString *str_URL = [NSString stringWithFormat:@"%@/MailAddressCheck?wsdl",[self getDomain]];
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:lng_Timeout];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Get_MailAddressCheck_WSDLCheck = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                             delegate:self
                                                        delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Get_MailAddressCheck_WSDLCheck dataTaskWithRequest:request];
    [task resume];
}
- (void)Get_MailAddressCheck:(NSString*)companyCd
                     emailAd:(NSString*)emailAd {

    // POST通信
    NSString *str_URL = _endpoint_Get_MailAddressCheck;
    NSURL *URL_STRING = [NSURL URLWithString:str_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL_STRING];
    NSString *requestBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap:Envelope xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:act=\"http://action.webapi.hsp\" xmlns:xsd=\"http://inout.webapi.hsp/xsd\">"
                             "<soap:Header/>"
                             "<soap:Body>"
                             "<act:inspection>"
                             "<!--Optional:-->"
                             "<act:in>"
                             "<!--Optional:-->"
                             "<xsd:companyCd>%@</xsd:companyCd>"
                             "<!--Optional:-->"
                             "<xsd:emailAd>%@</xsd:emailAd>"
                             "</act:in>"
                             "</act:inspection>"
                             "</soap:Body>"
                             "</soap:Envelope>", companyCd, emailAd];
    NSString *msgLength = [NSString stringWithFormat:@"%@", @(requestBody.length)];
    [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/soap xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:lng_Timeout];
    [request setHTTPBody: [requestBody dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session_Get_MailAddressCheck = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                   delegate:self
                                              delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [_session_Get_MailAddressCheck dataTaskWithRequest:request];
    [task resume];
}

@end
