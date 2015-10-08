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

class ViewController: UIViewController {
    
    var array:NSArray? = NSArray()
    @IBOutlet var timelineTableView:UITableView? = UITableView()
    
    /* tweet */
    @IBAction func tweet(sender: AnyObject) {
        let tweetPostVC:SLComposeViewController? = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        print(tweetPostVC)
        self.presentViewController(tweetPostVC!, animated: true, completion: nil)
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
                    let requestMethod: SLRequestMethod = .GET
                    let SLServiceTypeTwitter: String
                    
                    // ここの部分調べる
                    let params:[NSObject : AnyObject]!
                    params["count"] = "100"
                    params["include_entities"] = "1"
                    
                    let posts:SLRequest? = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: requestMethod, URL: requestAPI, parameters: params)
                    
                    posts!.account = twitterAccount
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                    
                    let pHandler:SLRequestHandler? = {
                        (response,urlResponse,error) in
                        let err: NSError?
                        if let jsonArray = NSJSONSerialization.JSONObjectWithData(response, options: NSJSONReadingOptions.MutableLeaves) as? NSArray {
                            self.array = jsonArray
                            
                            if self.array!.count != 0 {
                                dispatch_async(dispatch_get_main_queue(), {self.timelineTableView!.reloadData()})
                            }
                            
                            
                            
                        } else {
                            print(err!.localizedDescription)
                            
                        }
                    }
                    posts!.performRequestWithHandler(pHandler)
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }else{
                    print(error.localizedDescription)
                }
            }
        }
        account!.requestAccessToAccountsWithType(accountType, options: nil, completion: handler)

    }

    override func viewDidLoad() {
        print("hello")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

