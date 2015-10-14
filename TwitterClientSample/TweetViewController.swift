//
//  ViewController.swift
//  TwitterClientSample
//
//  Created by tajika on 2015/10/01.
//  Copyright (c) 2015年 Tajika. All rights reserved.
//

import UIKit
import Accounts
import Social

class TweetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var array:NSArray? = NSArray()
    @IBOutlet var timelineTableView: UITableView!
    
    /* tweet */
    @IBAction func tweet(sender: AnyObject) {
        let tweetPostVC:SLComposeViewController? = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        print(tweetPostVC)
        self.presentViewController(tweetPostVC!, animated: true, completion: nil)
    }

    @IBAction func reload(sender: AnyObject) {
        getTimeline()
    }

    /* timeline 取得 */
    func getTimeline() {
        
        let account:ACAccountStore? = ACAccountStore()
        var accountType:ACAccountType? = ACAccountType()
        accountType! = account!.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        let handler:ACAccountStoreRequestAccessCompletionHandler =
        {
            granted, error in
            if(!granted) {
                print("アクセス拒否")
            } else {
                print("アクセス許可")
                var accounts:NSArray? = NSArray()
                accounts! = account!.accountsWithAccountType(accountType)
                if accounts!.count > 0 {
                    let twitterAccount:ACAccount = accounts!.lastObject as! ACAccount
                    let requestAPI:NSURL! = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
                    // memo: enumについて詳しく調べる
                    let requestMethod: SLRequestMethod = .GET
                    
                    
                    // 引っかかり→ディクショナリの宣言
                    var params:[NSObject : AnyObject]! = [:]
                    
                    params["count"] = "1"
                    params["include_entities"] = "1"
                    
                    let posts:SLRequest? = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: requestMethod, URL: requestAPI, parameters: params)
                    
                    
                    posts!.account = twitterAccount
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                    
                    // json解析部分
                    // memo: エラーハンドリングの仕方が変わったっぽい？書き方の問題？
                    let pHandler:SLRequestHandler = { (response, urlResponse, error) in
                        do {
                            let jsonArray = try NSJSONSerialization.JSONObjectWithData(response, options: NSJSONReadingOptions.MutableLeaves) as? NSArray
                            self.array = jsonArray
                            
                            if self.array!.count != 0 {
                                dispatch_async(dispatch_get_main_queue(), {self.timelineTableView!.reloadData()})
                            }
                        } catch let err as NSError? {
                            print(err!.localizedDescription)
                        }
                    }
                    posts!.performRequestWithHandler(pHandler)
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                } else {
                    print(error.localizedDescription)
                }
            }
        }
        account!.requestAccessToAccountsWithType(accountType, options: nil, completion: handler)
    }
    
    // セクション数の追加
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // 行数を指定
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array!.count
    }
    
    // セルの中身を実装
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        print(array)
        
        // 上記 print(self.array) にてデータが取得されている
        // かつ、以下 print(cell) が表示されないため
        // let cell: ~ がうまくいっていない？
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell") as UITableViewCell!

        print(cell)

        let userLabel:UILabel = cell.viewWithTag(1) as! UILabel
        let userIDLabel:UILabel = cell.viewWithTag(2) as! UILabel
        let tweetTextView:UITextView = cell.viewWithTag(3) as! UITextView
        let userImgView:UIImageView = cell.viewWithTag(4) as! UIImageView
        
        let tweet:NSDictionary = array![indexPath.row] as! NSDictionary
        let userInfo:NSDictionary = tweet["user"]! as! NSDictionary
        
        print(tweet)
        
        tweetTextView.text = tweet["text"] as! String
        userLabel.text = userInfo["name"] as? String
        let userID = userInfo["screen_name"] as! NSString
        userIDLabel.text = "@\(userID)"
        let userImgPath:NSString = userInfo["profile_image_url"] as! String
        let userImgUrl:NSURL = NSURL(string: userImgPath as String)!
        let userImgPathData:NSData = NSData(contentsOfURL: userImgUrl)!
        userImgView.image = UIImage(data: userImgPathData)
        return cell
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getTimeline()

        // Cell名の登録をおこなう.
        //timelineTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // DataSourceの設定をする.
        //timelineTableView.dataSource = self
        
        // Delegateを設定する.
        //timelineTableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

