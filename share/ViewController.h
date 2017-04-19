//
//  ViewController.h
//  share
//
//  Created by M.Amatani on 2017/04/17.
//  Copyright © 2017年 Mobile Innovation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Soap_Api.h"

@interface ViewController : UIViewController <Soap_ApiDelegate>
{
    //Soap_Api
    Soap_Api* _base_SoapApi;
}

@end

