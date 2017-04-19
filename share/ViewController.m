//
//  ViewController.m
//  share
//
//  Created by M.Amatani on 2017/04/17.
//  Copyright © 2017年 Mobile Innovation. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    //api初期化
    _base_SoapApi = [[Soap_Api alloc]init];
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    //SoapApi Delegate設定
    _base_SoapApi.apidelegate = self;

    // 証明書のコピーと存在確認
    //コピー元のファイル取得
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *fileURL_rootFile = [fileManager
                       containerURLForSecurityApplicationGroupIdentifier:@"group.jp.mobile-innovation.share"];
    fileURL_rootFile = [fileURL_rootFile URLByAppendingPathComponent:@"testuser.test.com.pfx"];
    NSString *filePathKill_fileURL_rootFile = [fileURL_rootFile.absoluteString stringByReplacingOccurrencesOfString: @"file:///private" withString: @""];

    //コピー先指定
    NSArray *ary_path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *str_directory = [ary_path objectAtIndex:0];
    NSString *fileURL_outputFile = [str_directory stringByAppendingPathComponent:@"testuser.test.com.pfx"];

    NSString *filePathKill_fileURL_outputFile = [fileURL_outputFile stringByReplacingOccurrencesOfString: @"file:///private" withString: @""];

    //コピー元ファイル確認
    BOOL bln_rootFile = [fileManager fileExistsAtPath:filePathKill_fileURL_rootFile];

    if(bln_rootFile == true){

        //コピー前のファイル削除
        [fileManager removeItemAtPath:filePathKill_fileURL_outputFile error:NULL];

        //ファイルコピー
        [fileManager copyItemAtPath:filePathKill_fileURL_rootFile toPath:filePathKill_fileURL_outputFile error:NULL];
    }

    //コピー先ファイル確認
    BOOL bln_SetFile = [fileManager fileExistsAtPath:filePathKill_fileURL_outputFile];

    if(bln_SetFile == NO){

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"証明書がインストールされていません"
                                                                                 message:@""
                                                                          preferredStyle:UIAlertControllerStyleAlert];

        [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {

                                                              exit(0);
                                                          }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }else{

        //コピー元ファイル削除
        [fileManager removeItemAtPath:filePathKill_fileURL_rootFile error:NULL];

        //テスト確認用
        [_base_SoapApi Get_Test1_WSDLCheck];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//SoapAPi Action
- (void)Soap_Api_ErrAction:(UIAlertController*)alert errorcode:(long)erroecode {

    // 通信エラーメッセージ表示
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)Soap_Api_WSDLCheck_BackAction:(NSString*)actionCode basename:(NSString*)basename {

    if([actionCode isEqual:@"test1_WSDLCheck"]){

        NSLog(@"OK");
        [_base_SoapApi Get_Test1];
    }
}

- (void)Soap_Api_BackAction:(NSString*)actionCode dicData:(NSDictionary*)dicData basename:(NSString*)basename errorcode:(long)errorcode {

    if([actionCode isEqualToString:@"test1"]){

        //Dictionaryからポイントキーからルートキー検索
        NSString *str_key = [NSString stringWithFormat:@"%@:pointQt",basename];
        NSString *str_point = [[dicData objectForKey:str_key] objectForKey:@"text"];
        NSLog(@"%@ = %@",str_key,str_point);

        NSArray *ary_data = dicData.mutableCopy;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"通信が正常に実行されました"
                                                                                 message:@""
                                                                          preferredStyle:UIAlertControllerStyleAlert];

        [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {

                                                              exit(0);
                                                          }]];

        [self presentViewController:alertController animated:YES completion:nil];
    }
}


@end
