//
//  jobRequestController.swift
//  employ
//
//  Created by Harrishan Sureshkumar on 05/04/2018.
//  Copyright © 2018 Harrishan Sureshkumar. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase
//THIS PAGE SHOULD ONLY BE USED BY EMPLOYERS
class jobRequestController: UIViewController, UITextViewDelegate{
    
    var childID : String?
    @IBOutlet weak var jobTitleView: UITextView!
 //   @IBOutlet weak var jobTitleField: UITextField!
    @IBOutlet weak var jobDescriptionView: UITextView!
    @IBOutlet weak var termsView: UITextView!
    @IBOutlet weak var priceQuoteView: UITextView!
    
    var jobTitle : String?
    var jobDescription : String?
    var terms: String?
    var priceQuote: String?
    var employerID : String?
    var employeeID : String?
    
    var type = "pending"
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(childID)
        
       // scrollView.delegate = self
        //scrollView.isScrollEnabled = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkForEmptyBoxes() -> Int
    {
        //var ret = 0
        var allFilledFlag = 0
        var checkStr = ""
        //BOX1
        if (self.jobTitleView.text == nil){
            allFilledFlag = 1
        }
        else{
            checkStr = self.jobTitleView.text
                .replacingOccurrences(of: " ", with: "", options: .literal, range: nil)//remove spaces for first box text
            if (checkStr == "") { allFilledFlag = 1 }
        }
        //BOX2
        if (self.jobDescriptionView.text == nil){
            allFilledFlag = 1
        }
        else{
            checkStr = self.jobDescriptionView.text
                .replacingOccurrences(of: " ", with: "", options: .literal, range: nil)//remove spaces for first box text
            if (checkStr == "") { allFilledFlag = 1 }
        }
        
        //BOX3
        if (self.termsView.text == nil){
            allFilledFlag = 1
        }
        else{
            checkStr = self.termsView.text
                .replacingOccurrences(of: " ", with: "", options: .literal, range: nil)//remove spaces for first box text
            if (checkStr == "") { allFilledFlag = 1 }
        }
        
        //BOX4
        if (self.priceQuoteView.text == nil){
            allFilledFlag = 1
        }
        else{
            checkStr = self.priceQuoteView.text
                .replacingOccurrences(of: " ", with: "", options: .literal, range: nil)//remove spaces for first box text
            if (checkStr == "") { allFilledFlag = 1 }
        }
        
        return allFilledFlag
    
    }
    
    @IBAction func sendRequestClicked(_sender: AnyObject){
        
        //check if all boxes are filled
        let allFilledFlag = checkForEmptyBoxes()

        if allFilledFlag == 0
        {
        let userID = KeychainWrapper.standard.string(forKey: "uid")
        self.employerID = userID
        self.employeeID = childID
        
        let timestamp = Date().timeIntervalSince1970
        let ts = String(timestamp)
        
        let requestData = [
            "employerId": employerID!,
            "employeeId": employeeID!,
            "jobTitle": jobTitleView.text!,
            "jobDescription": jobDescriptionView.text!,
            "employeeTerms": termsView.text!,
            "employeePriceQuote" : priceQuoteView.text!,
            "lastTimestamp" : ts,
            "status": "pending"
            ] as [String: Any] //
        /*
        var postRef = ref.childByAutoId()
        postRef.setValue(post)
        
        var postID = postRef.key
        */
            let refID = Database.database().reference().childByAutoId().key//generates unique id for this job
        
        //STORE in employee db space
        Database.database().reference().child("users").child(self.employeeID!).child("jobRequestsList").child(refID).setValue(requestData)
        //STORE in employers db space
        Database.database().reference().child("users").child(self.employerID!).child("jobRequestsList").child(refID).setValue(requestData)
            
        }
        else{
            //POP UP BOX
            showAlertBox(titleStr: "Error", messageStr: "Please fill in all boxes")
            
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func showAlertBox(titleStr: String, messageStr: String){
        let notification = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertControllerStyle.alert)
        let notifAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        {
            (UIAlertAction) -> Void in
        }
        notification.addAction(notifAction)
        self.present(notification, animated: true)
        {
            () -> Void in
        }
    }
    
    @IBAction func backClicked(_sender: AnyObject){// back button
        
        self.dismiss(animated: true, completion: nil)
        //  self.performSegue(withIdentifier: "back", sender: nil)
        
    }
    
    @IBAction func pendingClicked(_sender: AnyObject){
        self.type = "pending"
        self.performSegue(withIdentifier: "toJobTable", sender: nil)
    }
    
    @IBAction func acceptedClicked(_sender: AnyObject){
        self.type = "inprogress"
        self.performSegue(withIdentifier: "toJobTable", sender: nil)
    }
    
    @IBAction func completedClicked(_sender: AnyObject){
        self.type = "completed"
        self.performSegue(withIdentifier: "toJobTable", sender: nil)
    }
    
    //prepare for job table request page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let jobTableVC = segue.destination as! jobsTableController
        jobTableVC.type = self.type
    }
    //end - prepare for job tabke request page
    
    //Hide the key board when tapped outside textfield
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       // self.innerView.endEditing(true)
        self.view.endEditing(true)
    }
    
    
    //hide when return clicked
    /*
    func textFieldShouldReturn(_ textView: UITextView) -> Bool {
        //textField.resignFirstResponder()
        // return (true)
        if textView == jobTitleView{
           jobDescriptionView.becomeFirstResponder()
        }
        else if textView ==  jobDescriptionView{
            //emailField.becomeFirstResponder()
           termsView.resignFirstResponder()
        }
        return true
    }*/
    
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView == jobTitleView{
            jobDescriptionView.becomeFirstResponder()
        }
        else if textView ==  jobDescriptionView{
            //emailField.becomeFirstResponder()
            termsView.resignFirstResponder()
        }
        return true
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
