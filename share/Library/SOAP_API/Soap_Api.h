//
//  Soap_Api.h
//
//  Created by MacNote on 2014/09/04.
//  Copyright © 2015年 Mobile Innovation, LLC. All rights reserved.
//

 #import "SVProgressHUD.h"

@protocol Soap_ApiDelegate <NSObject>
- (void)Soap_Api_WSDLCheck_BackAction:(NSString*)actionCode basename:(NSString*)basename;
- (void)Soap_Api_BackAction:(NSString*)actionCode dicData:(NSDictionary*)dicData basename:(NSString*)basename errorcode:(long)errorcode;
- (void)Soap_Api_ErrAction:(UIAlertController*)alert errorcode:(long)erroecode;
@end

@interface Soap_Api : NSObject <NSURLConnectionDataDelegate, NSURLSessionDataDelegate>
{
    UIViewController* _CurrentView;

    //test1 WSDLCheck
    NSURLSession *_session_test1_WSDLCheck;
    long _statusCode_test1_WSDLCheck;
    NSMutableData *_initialiseData_test1_WSDLCheck;
    NSXMLParser *_parser_test1_WSDLCheck;
    NSMutableDictionary *_dic_test1_WSDLCheck;
    //test1 WSDL Name
    NSString *_basename_test1;
    NSString *_colomBasename_test1;
    NSString *_endpoint_test1;
    //test1
    NSURLSession *_session_test1;
    long _statusCode_test1;
    NSMutableData *_initialiseData_test1;
    NSXMLParser *_parser_test1;
    NSMutableDictionary *_dic_test1;

    //Set_A901_KigyoSalonStoreCheck WSDLCheck
    NSURLSession *_session_Set_A901_KigyoSalonStoreCheck_WSDLCheck;
    long _statusCode_Set_A901_KigyoSalonStoreCheck_WSDLCheck;
    NSMutableData *_initialiseData_Set_A901_KigyoSalonStoreCheck_WSDLCheck;
    NSXMLParser *_parser_Set_A901_KigyoSalonStoreCheck_WSDLCheck;
    NSMutableDictionary *_dic_Set_A901_KigyoSalonStoreCheck_WSDLCheck;
    //Set_A901_KigyoSalonStoreCheck WSDL Name
    NSString *_basename_Set_A901_KigyoSalonStoreCheck;
    NSString *_colomBasename_Set_A901_KigyoSalonStoreCheck;
    NSString *_endpoint_Set_A901_KigyoSalonStoreCheck;
    //Set_A901_KigyoSalonStoreCheck
    NSURLSession *_session_Set_A901_KigyoSalonStoreCheck;
    long _statusCode_Set_A901_KigyoSalonStoreCheck;
    NSMutableData *_initialiseData_Set_A901_KigyoSalonStoreCheck;
    NSXMLParser *_parser_Set_A901_KigyoSalonStoreCheck;
    NSMutableDictionary *_dic_Set_A901_KigyoSalonStoreCheck;

    //Get_A902_PointRateCheck WSDLCheck
    NSURLSession *_session_Get_A902_PointRateCheck_WSDLCheck;
    long _statusCode_Get_A902_PointRateCheck_WSDLCheck;
    NSMutableData *_initialiseData_Get_A902_PointRateCheck_WSDLCheck;
    NSXMLParser *_parser_Get_A902_PointRateCheck_WSDLCheck;
    NSMutableDictionary *_dic_Get_A902_PointRateCheck_WSDLCheck;
    //Get_A902_PointRateCheck WSDL Name
    NSString *_basename_Get_A902_PointRateCheck;
    NSString *_colomBasename_Get_A902_PointRateCheck;
    NSString *_endpoint_Get_A902_PointRateCheck;
    //Get_A902_PointRateCheck
    NSURLSession *_session_Get_A902_PointRateCheck;
    long _statusCode_Get_A902_PointRateCheck;
    NSMutableData *_initialiseData_Get_A902_PointRateCheck;
    NSXMLParser *_parser_Get_A902_PointRateCheck;
    NSMutableDictionary *_dic_Get_A902_PointRateCheck;

    //Set_A902_PointRateSetting WSDLCheck
    NSURLSession *_session_Set_A902_PointRateSetting_WSDLCheck;
    long _statusCode_Set_A902_PointRateSetting_WSDLCheck;
    NSMutableData *_initialiseData_Set_A902_PointRateSetting_WSDLCheck;
    NSXMLParser *_parser_Set_A902_PointRateSetting_WSDLCheck;
    NSMutableDictionary *_dic_Set_A902_PointRateSetting_WSDLCheck;
    //test1 WSDL Name
    NSString *_basename_Set_A902_PointRateSetting;
    NSString *_colomBasename_Set_A902_PointRateSetting;
    NSString *_endpoint_Set_A902_PointRateSetting;
    //Set_A902_PointRateSetting
    NSURLSession *_session_Set_A902_PointRateSetting;
    long _statusCode_Set_A902_PointRateSetting;
    NSMutableData *_initialiseData_Set_A902_PointRateSetting;
    NSXMLParser *_parser_Set_A902_PointRateSetting;
    NSMutableDictionary *_dic_Set_A902_PointRateSetting;

    //Set_A100_MemberRegist WSDLCheck
    NSURLSession *_session_Set_A100_MemberRegist_WSDLCheck;
    long _statusCode_Set_A100_MemberRegist_WSDLCheck;
    NSMutableData *_initialiseData_Set_A100_MemberRegist_WSDLCheck;
    NSXMLParser *_parser_Set_A100_MemberRegist_WSDLCheck;
    NSMutableDictionary *_dic_Set_A100_MemberRegist_WSDLCheck;
    //test1 WSDL Name
    NSString *_basename_Set_A100_MemberRegist;
    NSString *_colomBasename_Set_A100_MemberRegist;
    NSString *_endpoint_Set_A100_MemberRegist;
    //Set_A100_MemberRegist
    NSURLSession *_session_Set_A100_MemberRegist;
    long _statusCode_Set_A100_MemberRegist;
    NSMutableData *_initialiseData_Set_A100_MemberRegist;
    NSXMLParser *_parser_Set_A100_MemberRegist;
    NSMutableDictionary *_dic_Set_A100_MemberRegist;

    //Get_A200_PointHistorySearch WSDLCheck
    NSURLSession *_session_Get_A200_PointHistorySearch_WSDLCheck;
    long _statusCode_Get_A200_PointHistorySearch_WSDLCheck;
    NSMutableData *_initialiseData_Get_A200_PointHistorySearch_WSDLCheck;
    NSXMLParser *_parser_Get_A200_PointHistorySearch_WSDLCheck;
    NSMutableDictionary *_dic_Get_A200_PointHistorySearch_WSDLCheck;
    //Get_A200_PointHistorySearch WSDL Name
    NSString *_basename_Get_A200_PointHistorySearch;
    NSString *_colomBasename_Get_A200_PointHistorySearch;
    NSString *_endpoint_Get_A200_PointHistorySearch;
    //Get_A200_PointHistorySearch
    NSURLSession *_session_Get_A200_PointHistorySearch;
    long _statusCode_Get_A200_PointHistorySearch;
    NSMutableData *_initialiseData_Get_A200_PointHistorySearch;
    NSXMLParser *_parser_Get_A200_PointHistorySearch;
    NSMutableDictionary *_dic_Get_A200_PointHistorySearch;

    //Get_SearchMember WSDLCheck
    NSURLSession *_session_Get_SearchMember_WSDLCheck;
    long _statusCode_Get_SearchMember_WSDLCheck;
    NSMutableData *_initialiseData_Get_SearchMember_WSDLCheck;
    NSXMLParser *_parser_Get_SearchMember_WSDLCheck;
    NSMutableDictionary *_dic_Get_SearchMember_WSDLCheck;
    //Get_SearchMember WSDL Name
    NSString *_basename_Get_SearchMember;
    NSString *_colomBasename_Get_SearchMember;
    NSString *_endpoint_Get_SearchMember;
    //Get_SearchMember
    NSURLSession *_session_Get_SearchMember;
    long _statusCode_Get_SearchMember;
    NSMutableData *_initialiseData_Get_SearchMember;
    NSXMLParser *_parser_Get_SearchMember;
    NSMutableDictionary *_dic_Get_SearchMember;

    //Get_PointSearch WSDLCheck
    NSURLSession *_session_Get_PointSearch_WSDLCheck;
    long _statusCode_Get_PointSearch_WSDLCheck;
    NSMutableData *_initialiseData_Get_PointSearch_WSDLCheck;
    NSXMLParser *_parser_Get_PointSearch_WSDLCheck;
    NSMutableDictionary *_dic_Get_PointSearch_WSDLCheck;
    //Get_PointSearch WSDL Name
    NSString *_basename_Get_PointSearch;
    NSString *_colomBasename_Get_PointSearch;
    NSString *_endpoint_Get_PointSearch;
    //Get_PointSearch
    NSURLSession *_session_Get_PointSearch;
    long _statusCode_Get_PointSearch;
    NSMutableData *_initialiseData_Get_PointSearch;
    NSXMLParser *_parser_Get_PointSearch;
    NSMutableDictionary *_dic_Get_PointSearch;

    //Set_A300_ReceiveOrder WSDLCheck
    NSURLSession *_session_Set_A300_ReceiveOrder_WSDLCheck;
    long _statusCode_Set_A300_ReceiveOrder_WSDLCheck;
    NSMutableData *_initialiseData_Set_A300_ReceiveOrder_WSDLCheck;
    NSXMLParser *_parser_Set_A300_ReceiveOrder_WSDLCheck;
    NSMutableDictionary *_dic_Set_A300_ReceiveOrder_WSDLCheck;
    //Set_A300_ReceiveOrder WSDL Name
    NSString *_basename_Set_A300_ReceiveOrder;
    NSString *_colomBasename_Set_A300_ReceiveOrder;
    NSString *_endpoint_Set_A300_ReceiveOrder;
    //Set_A300_ReceiveOrder
    NSURLSession *_session_Set_A300_ReceiveOrder;
    long _statusCode_Set_A300_ReceiveOrder;
    NSMutableData *_initialiseData_Set_A300_ReceiveOrder;
    NSXMLParser *_parser_Set_A300_ReceiveOrder;
    NSMutableDictionary *_dic_Set_A300_ReceiveOrder;

    //Set_A300_OrderConfirm WSDLCheck
    NSURLSession *_session_Set_A300_OrderConfirm_WSDLCheck;
    long _statusCode_Set_A300_OrderConfirm_WSDLCheck;
    NSMutableData *_initialiseData_Set_A300_OrderConfirm_WSDLCheck;
    NSXMLParser *_parser_Set_A300_OrderConfirm_WSDLCheck;
    NSMutableDictionary *_dic_Set_A300_OrderConfirm_WSDLCheck;
    //Set_A300_OrderConfirm WSDL Name
    NSString *_basename_Set_A300_OrderConfirm;
    NSString *_colomBasename_Set_A300_OrderConfirm;
    NSString *_endpoint_Set_A300_OrderConfirm;
    //Set_A300_OrderConfirm
    NSURLSession *_session_Set_A300_OrderConfirm;
    long _statusCode_Set_A300_OrderConfirm;
    NSMutableData *_initialiseData_Set_A300_OrderConfirm;
    NSXMLParser *_parser_Set_A300_OrderConfirm;
    NSMutableDictionary *_dic_Set_A300_OrderConfirm;

    //Set_A400_PointUpdate WSDLCheck
    NSURLSession *_session_Set_A400_PointUpdate_WSDLCheck;
    long _statusCode_Set_A400_PointUpdate_WSDLCheck;
    NSMutableData *_initialiseData_Set_A400_PointUpdate_WSDLCheck;
    NSXMLParser *_parser_Set_A400_PointUpdate_WSDLCheck;
    NSMutableDictionary *_dic_Set_A400_PointUpdate_WSDLCheck;
    //Set_A400_PointUpdate WSDL Name
    NSString *_basename_Set_A400_PointUpdate;
    NSString *_colomBasename_Set_A400_PointUpdate;
    NSString *_endpoint_Set_A400_PointUpdate;
    //Set_A400_PointUpdate
    NSURLSession *_session_Set_A400_PointUpdate;
    long _statusCode_Set_A400_PointUpdate;
    NSMutableData *_initialiseData_Set_A400_PointUpdate;
    NSXMLParser *_parser_Set_A400_PointUpdate;
    NSMutableDictionary *_dic_Set_A400_PointUpdate;

    //Get_MailAddressCheck WSDLCheck
    NSURLSession *_session_Get_MailAddressCheck_WSDLCheck;
    long _statusCode_Get_MailAddressCheck_WSDLCheck;
    NSMutableData *_initialiseData_Get_MailAddressCheck_WSDLCheck;
    NSXMLParser *_parser_Get_MailAddressCheck_WSDLCheck;
    NSMutableDictionary *_dic_Get_MailAddressCheck_WSDLCheck;
    //Get_MailAddressCheck WSDL Name
    NSString *_basename_Get_MailAddressCheck;
    NSString *_colomBasename_Get_MailAddressCheck;
    NSString *_endpoint_Get_MailAddressCheck;
    //Get_MailAddressCheck
    NSURLSession *_session_Get_MailAddressCheck;
    long _statusCode_Get_MailAddressCheck;
    NSMutableData *_initialiseData_Get_MailAddressCheck;
    NSXMLParser *_parser_Get_MailAddressCheck;
    NSMutableDictionary *_dic_Get_MailAddressCheck;
}
@property (nonatomic, assign) id<Soap_ApiDelegate> apidelegate;

//呼び出しメソッド
- (void)Get_Test1_WSDLCheck;
- (void)Get_Test1;

- (void)Set_A901_KigyoSalonStoreCheck_WSDLCheck;
- (void)Set_A901_KigyoSalonStoreCheck:(NSString*)CompanyCode salonStoreCd:(NSString*)salonStoreCd;

- (void)Get_A902_PointRateCheck_WSDLCheck;
- (void)Get_A902_PointRateCheck:(NSString*)CompanyCode kaiinKb:(NSString*)kaiinKb;

- (void)Set_A902_PointRateSetting_WSDLCheck;
- (void)Set_A902_PointRateSetting:(NSString*)CompanyCode kaiinKb:(NSString*)kaiinKb pointGrantRate:(NSString*)pointGrantRate;

- (void)Set_A100_MemberRegist_WSDLCheck;
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
                otherSystemCd:(NSString*)otherSystemCd;

- (void)Get_A200_PointHistorySearch_WSDLCheck;
- (void)Get_A200_PointHistorySearch:(NSString*)cardNo companyCd:(NSString*)companyCd;

- (void)Get_SearchMember_WSDLCheck;
- (void)Get_SearchMember:(NSString*)cardNo
               companyCd:(NSString*)companyCd
                 emailAd:(NSString*)emailAd
             phoneNumber:(NSString*)phoneNumbe;

- (void)Get_PointSearch_WSDLCheck;
- (void)Get_PointSearch:(NSString*)cardNo;

- (void)Set_A300_ReceiveOrder_WSDLCheck;
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
                   paypointQt:(NSString*)paypointQt;

- (void)Set_A300_OrderConfirm_WSDLCheck;
- (void)Set_A300_OrderConfirm:(NSString*)cardNb
                    companyCd:(NSString*)companyCd
                     kaiageDt:(NSString*)kaiageDt
                     kaiageTm:(NSString*)kaiageTm
                     systemKb:(NSString*)systemKb
                   torihikiNb:(NSString*)torihikiNb;

- (void)Set_A400_PointUpdate_WSDLCheck;
- (void)Set_A400_PointUpdate:(NSString*)cardNb
                   companyCd:(NSString*)companyCd
                    kaiageDt:(NSString*)kaiageDt
                    kaiageTm:(NSString*)kaiageTm
                  kaikinttVl:(NSString*)kaikinttVl
                   koushinKb:(NSString*)koushinKb
                       point:(NSString*)point
                      reason:(NSString*)reason
                    systemKb:(NSString*)systemKb
                  torihikiNb:(NSString*)torihikiNb;

- (void)Get_MailAddressCheck_WSDLCheck;
- (void)Get_MailAddressCheck:(NSString*)companyCd
                     emailAd:(NSString*)emailAd;
@end
