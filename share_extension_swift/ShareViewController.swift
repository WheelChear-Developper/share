//
//  ShareViewController.swift
//  share_extension_swift
//
//  Created by M.Amatani on 2017/04/17.
//  Copyright © 2017年 Mobile Innovation. All rights reserved.
//

import UIKit
import Social

class ShareViewController: UIViewController {

    override func viewDidLoad() {

        super.viewDidLoad()

        // titleName
        self.title = "証明書インポート";

        // color
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = UIColor(red:1.0, green:0.75, blue:0.5, alpha:1.0)

        // postName
        let custom_view: UIViewController = self.navigationController!.viewControllers[0]
        custom_view.navigationItem.rightBarButtonItem!.title = "保存"
    }

    override func viewWillAppear(_ animated: Bool) {
        //super.viewDidDisappear(animated)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

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
//                self.textView.text = separatedArray[separatedArray.count - 1]
            })
        }
    }
/*
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {

        let inputItem: NSExtensionItem = self.extensionContext?.inputItems[0] as! NSExtensionItem
        let itemProvider = inputItem.attachments![0] as! NSItemProvider

        // クックパッドアプリ経由での shareExtension ではテキストの取得に特別な処理はない
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
                if binaryData.write(to: file_url!, atomically: false) {
                    print("保存しました。")
                }else {
                    print("保存失敗しました。")
                }
            })
        }

        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
*/
}
