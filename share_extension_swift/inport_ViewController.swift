//
//  inport_ViewController.swift
//  share
//
//  Created by M.Amatani on 2017/04/19.
//  Copyright © 2017年 Mobile Innovation. All rights reserved.
//

import UIKit

class inport_ViewController: UIViewController {

    @IBOutlet weak var view_areart: UIView!
    @IBOutlet weak var lbl_fileName: UILabel!
    @IBOutlet weak var btn_inport: UIButton!

    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red:0.0,green:0.0,blue:0.0,alpha:0.4)

        let inputItem: NSExtensionItem = self.extensionContext?.inputItems[0] as! NSExtensionItem
        let itemProvider = inputItem.attachments![0] as! NSItemProvider

        // クックパッドアプリ経由での shareExtension ではテキストの取得に特別な処理はない
        if (itemProvider.hasItemConformingToTypeIdentifier("public.file-url")) {
            itemProvider.loadItem(forTypeIdentifier: "public.file-url", options: nil, completionHandler: {
                (item, error) in

                // ファイルのURLを取得。
                let dataURL = item as! NSURL

                let str_fullfileName : String = dataURL.absoluteString!
                let separatedArray = str_fullfileName.components(separatedBy: "/")
                self.lbl_fileName.text = separatedArray[separatedArray.count - 1]

                let str_fileInfo = separatedArray[separatedArray.count - 1].components(separatedBy: ".")
                let str_fileFinalInfo = str_fileInfo[str_fileInfo.count - 1]

                if str_fileFinalInfo != "satisfa" {

                    self.btn_inport.setTitle("キャンセル", for: .normal)
                }
            })
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    @IBAction func btn_save(_ sender: Any) {

        //ダイアログ非表示設定
        self.view_areart.isHidden = true

        if self.btn_inport.titleLabel?.text == "キャンセル" {

            //終了処理
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)

        }else{

            //ファイルインポート
            let inputItem: NSExtensionItem = self.extensionContext?.inputItems[0] as! NSExtensionItem
            let itemProvider = inputItem.attachments![0] as! NSItemProvider

            if (itemProvider.hasItemConformingToTypeIdentifier("public.file-url")) {
                itemProvider.loadItem(forTypeIdentifier: "public.file-url", options: nil, completionHandler: {
                    (item, error) in

                    // ファイルのURLを取得。
                    let dataURL = item as! NSURL
                    var binaryData:NSData = NSData()

                    // ファイルの読み込み
                    do{
                        binaryData = try NSData(contentsOf: dataURL as URL,options: NSData.ReadingOptions.mappedIfSafe)
                    } catch {
                        print("Failed to read the file.")
                    }

                    //                do {
                    // ファイル読み込み
                    //                    binaryData = try NSData(contentsOf: item as! URL, options: [])
                    //                } catch {
                    //                    print("Failed to read the file.")
                    //                }
                    // ドキュメントのパス
                    //let docDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as String

                    // 共有用フォルダへのファイル保存
                    let fileManager = FileManager.default
                    let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier:"group.jp.mobile-innovation.share")
                    let inport_filePath:String = (containerURL?.path)!

                    // 保存先のパス
                    let filePath = "file://" + inport_filePath + "/testuser.test.com.pfx"
                    let file_url = URL(string: filePath)

                    //ファイル書き込み
                    if binaryData.write(to: file_url!, atomically: true) {

                        let ac = UIAlertController(title: "証明書保存しました", message: "", preferredStyle: .alert)

                        let okAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in

                            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                        }
                        ac.addAction(okAction)

                        self.present(ac, animated: true, completion: nil)
                    }else {

                        let ac = UIAlertController(title: "保存エラー", message: "証明書保存出来ませんでした", preferredStyle: .alert)

                        let okAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
                            
                            //終了処理
                            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                        }
                        ac.addAction(okAction)
                        
                        self.present(ac, animated: true, completion: nil)
                    }
                })
            }
        }
    }
}
