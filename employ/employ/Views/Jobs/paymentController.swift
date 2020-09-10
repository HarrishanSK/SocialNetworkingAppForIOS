//
//  paymentController.swift
//  employ
//
//  Created by Harrishan Sureshkumar on 09/04/2018.
//  Copyright © 2018 Harrishan Sureshkumar. All rights reserved.
//

import UIKit
import WebKit

class paymentController: UIViewController, WKUIDelegate {
    
  //  var webView: WKWebView!
    
    @IBOutlet weak var webView: WKWebView!
    var alertController: UIAlertController?
    
    //override func loadView() {
       // let webConfiguration = WKWebViewConfiguration()
       // webView = WKWebView(frame: .zero, configuration: webConfiguration)
       // self.webView.uiDelegate = self
       // view = webView
   // }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let myURL = URL(string: "https://www.paypal.com/myaccount/transfer/homepage/send")
        let myRequest = URLRequest(url: myURL!)
        self.webView.load(myRequest)
        
        
        self.alertController = UIAlertController(title: "Alert", message: "", preferredStyle: .alert)
       // self.alertController?.addAction(UIAlertAction(title: "Close", style: .default))
       // view.addSubview((alertController?.view)!)
    }
    
    @IBAction func backButtonClicked(_sender: AnyObject){// back button
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonClicked(_sender: AnyObject){// back button
       // showAlertBox()
    self.webView.isHidden = true
    }
    private func presentViewController(alert: UIAlertController, animated flag: Bool, completion: (() -> Void)?) -> Void {
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: flag, completion: completion)
    }
    
    func showAlertBox(){
        
      self.alertController = UIAlertController(title: "Payment", message: "Please make sure you have completed payment. By clicking 'Agree' you are confirming that you have paid the agreed amount to the correct employee. Failure to do so could result in an incomplete payment and further problems.", preferredStyle: UIAlertControllerStyle.alert)
        
        self.alertController?.addAction(UIAlertAction(title: "Agree", style: .default, handler: { (action: UIAlertAction!) in
            print("PAYMENT COMPLETE")
        }))
        
       self.alertController?.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("PAYMENT CANCELLED")
        }))
        present((self.alertController)! , animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
