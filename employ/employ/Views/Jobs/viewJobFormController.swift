//
//  viewJobFormController.swift
//  employ
//
//  Created by Harrishan Sureshkumar on 09/04/2018.
//  Copyright © 2018 Harrishan Sureshkumar. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class viewJobFormController: UIViewController {
    
    var type : String?
    var jobTitle : String?
    var jobDescription : String?
    var terms : String?
    var priceQuote : String?
    var jobKeyID : String?
    var myType : String?
    var employerID : String?
    var employeeID : String?
    

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var jobTitleView: UITextView!
    @IBOutlet weak var jobDescriptionView: UITextView!
    @IBOutlet weak var termsView: UITextView!
    @IBOutlet weak var priceView: UITextView!
    
    @IBOutlet weak var buttonStack: UIStackView!
    @IBOutlet weak var buttons: UIButton!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var confirmPayButton: UIButton!
    @IBOutlet weak var paypalLabel: UILabel!
    @IBOutlet weak var paypalInfoView: UITextView!
    @IBOutlet weak var paymentReceivedByEmployeeButton: UIButton!
    
    @IBOutlet weak var submitFeedbackButton: UIButton!
    @IBOutlet weak var feedbackTextView: UITextView!
    @IBOutlet weak var feedbackLabel: UILabel!
    
    weak var mDelegate:MyProtocol?
    
    var paypalInfo = ""
    var paypalFlag = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        payButton.isHidden = true
        confirmPayButton.isHidden = true
        
        paypalLabel.isHidden = true
        paypalInfoView.isHidden = true
        paymentReceivedByEmployeeButton.isHidden = true
        
        submitFeedbackButton.isHidden = true
        feedbackTextView.isHidden = true
        feedbackLabel.isHidden = true
        
        if self.myType == "Employer"
        {
            
           // hide buttons
            buttonStack.isHidden = true//Only show accept/decline button stack for pending employee
            
            if self.type == "accepted"
            {
                //show pay button
                payButton.isHidden = false//make visible
                confirmPayButton.isHidden = false
                paypalLabel.isHidden = false
                paypalInfoView.isHidden = false
                getEmployeesPaypalInfo() // store in paypal textView
                
                
                
            }
        }
        
        
        
        if self.type != "pending"
        {
            // hide buttons
            buttonStack.isHidden = true//Only show accept/decline button stack for pending employee
            
            if self.type == "accepted" && self.myType == "Employer"
            {/*
                //show pay button
                payButton.isHidden = false//make visible
                paypalLabel.isHidden = false
                paypalInfoView.isHidden = false*/
            }
        }
        
        if self.myType == "Employee"
        {
            if self.type == "paid"
            {
                paymentReceivedByEmployeeButton.isHidden = false // make visible
            }
        }
        
        
        if self.type == "completed"
        {
            submitFeedbackButton.isHidden = false//make visible
            feedbackTextView.isHidden = false
            feedbackLabel.isHidden = false
        }
        
        
        //capital starting letter
        var ptype = ""
        switch self.type {
        case "pending"?:
            ptype = "Pending"
        case "accepted"?:
            ptype = "Accepted"
        case "paid"?:
            ptype = "Paid"
        case "completed"?:
            ptype = "Completed"
        case "history"?:
            ptype = "History"
        default:
            ptype = "Pending"
        }
        
        titleLabel.text = "Job Request: " + ptype //self.type!
        jobTitleView.text = self.jobTitle
        jobDescriptionView.text = self.jobDescription
        termsView.text = self.terms
        priceView.text = self.priceQuote
        
        print("JOB KEY IS IS " + self.jobKeyID!)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonClicked(_sender: AnyObject){// back button
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func acceptClicked(_sender: AnyObject){
        
        self.alertPaypalInput()
   
        //CHANGE STATUS OF REQUEST FOR BOTH USERS IN DATABASE
        //.child("users").child(user.uid).setValue(["username": username])
        
        

    }
    
    func getEmployeesPaypalInfo()
    {
        var pInfo = "Not Recieved"
        Database.database().reference().child("users").child(self.employerID!).child("jobRequestsList").observe(.value, with: { snapshot in
            if let snapshots = snapshot.value as? [String : AnyObject]{
                
                for child in snapshots { //for each pending request
                    if child.key == self.jobKeyID
                    {
                        pInfo = (child.value["paypalInfo"] as? String)!
                        print("hapnd")
                        self.paypalInfoView.text = pInfo
                        
                    }
                }
            }
        }
        )
        
    }
    
    func updateDatabaseAccept()
    {
        if self.paypalFlag == 1{
            
            let timestamp = Date().timeIntervalSince1970
            let ts = String(timestamp) //set new timestamp
            
            //for employers request list
         //   Database.database().reference().child("users").child(self.employerID!).child("jobRequestsList").observe(.value, with: { snapshot in
             //   if let snapshots = snapshot.value as? [String : AnyObject]{
        Database.database().reference().child("users").child(self.employerID!).child("jobRequestsList").child(self.jobKeyID!).observeSingleEvent(of: .value){ (snapshot) in
            if let child = snapshot.value as? [String : AnyObject]{
                            
                  //  for child in snapshots { //for each pending request
                    //    if child.key == self.jobKeyID //with the jobKey id
                    //    {
                            
                            
                            let updateData = [
                                "employerId": self.employerID!,
                                "employeeId": self.employeeID!,
                                "jobTitle": self.jobTitle!,
                                "jobDescription": self.jobDescription!,
                                "employeeTerms": self.terms!,
                                "employeePriceQuote" : self.priceQuote!,
                                "lastTimestamp" : ts,
                                "paypalInfo" : self.paypalInfo,
                                "status": "accepted"
                                ] as [String: Any] //
                            
                            //delete chosen user from requestList .child("users/\(user.uid)/username").setValue(username)
                            Database.database().reference().child("users").child(self.employerID!).child("jobRequestsList").child(self.jobKeyID!).setValue(updateData)
                       // }
                   // }
                }
            }//)
            
            //for employees request list
           // Database.database().reference().child("users").child(self.employeeID!).child("jobRequestsList").observe(.value, with: { snapshot in
             //   if let snapshots = snapshot.value as? [String : AnyObject]{
         Database.database().reference().child("users").child(self.employeeID!).child("jobRequestsList").child(self.jobKeyID!).observeSingleEvent(of: .value){ (snapshot) in
                        if let child = snapshot.value as? [String : AnyObject]{
                 //   for child in snapshots { //for each pending request
                    //    if child.key == self.jobKeyID
                      //  {
                            //delete chosen user from requestList
                            
                            
                            let updateData = [
                                "employerId": self.employerID!,
                                "employeeId": self.employeeID!,
                                "jobTitle": self.jobTitle!,
                                "jobDescription": self.jobDescription!,
                                "employeeTerms": self.terms!,
                                "employeePriceQuote" : self.priceQuote!,
                                "lastTimestamp" : ts,
                                "status": "accepted"
                                ] as [String: Any] //
                            Database.database().reference().child("users").child(self.employeeID!).child("jobRequestsList").child(self.jobKeyID!).setValue(updateData)
                            
                     //   }
                  //  }
                }
            }//)
           // mDelegate?.sendArrayToPreviousVC(flag: 1)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func declineClicked(_sender: AnyObject){
        
        //REMOVE REQUEST FOR BOTH USERS IN DATABASE
        
        //for employers request list
        Database.database().reference().child("users").child(self.employerID!).child("jobRequestsList").observe(.value, with: { snapshot in
            if let snapshots = snapshot.value as? [String : AnyObject]{
                
                for child in snapshots { //for each pending request
                    if child.key == self.jobKeyID //with the jobKey id
                    {
                        //delete chosen user from requestList
                        Database.database().reference().child("users").child(self.employerID!).child("jobRequestsList").child(self.jobKeyID!).removeValue()
                    }
                }
            }
        })
        
        //for employees request list
        Database.database().reference().child("users").child(self.employeeID!).child("jobRequestsList").observe(.value, with: { snapshot in
            if let snapshots = snapshot.value as? [String : AnyObject]{
                
                for child in snapshots { //for each pending request
                    if child.key == self.jobKeyID
                    {
                        //delete chosen user from requestList
                        Database.database().reference().child("users").child(self.employeeID!).child("jobRequestsList").child(self.jobKeyID!).removeValue()
                    }
                }
            }
        })
        
        self.dismiss(animated: true, completion: nil)
      //  self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func declineClicked2(_sender: AnyObject){
        
        //REMOVE REQUEST FOR BOTH USERS IN DATABASE
        
        //for employers request list
        Database.database().reference().child("users").child(self.employerID!).child("jobRequestsList").child(self.jobKeyID!).observeSingleEvent(of: .value){ (snapshot) in
        if let child = snapshot.value as? [String : AnyObject]{
      //  Database.database().reference().child("users").child(self.employerID!).child("jobRequestsList").observe(.value, with: { snapshot in
      //      if let snapshots = snapshot.value as? [String : AnyObject]{
                
            //    for child in snapshots { //for each pending request
                   // if child.key == self.jobKeyID //with the jobKey id
                   // {
                        //delete chosen user from requestList
                        Database.database().reference().child("users").child(self.employerID!).child("jobRequestsList").child(self.jobKeyID!).removeValue()
                  //  }
                }
           // }
        }
        
        //for employees request list
        Database.database().reference().child("users").child(self.employeeID!).child("jobRequestsList").observe(.value, with: { snapshot in
            if let snapshots = snapshot.value as? [String : AnyObject]{
                
                for child in snapshots { //for each pending request
                    if child.key == self.jobKeyID
                    {
                        //delete chosen user from requestList
                        Database.database().reference().child("users").child(self.employeeID!).child("jobRequestsList").child(self.jobKeyID!).removeValue()
                    }
                }
            }
        })
        
        self.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func payClicked(_sender: AnyObject){
        self.performSegue(withIdentifier: "toPayment", sender: nil)
    }
    
    @IBAction func confClicked(_sender: AnyObject){
        showConfAlertBox()
    }
    
    @IBAction func paymentRecievedClicked(_sender: AnyObject){
        //updateDatabaseToCompleted - Job is now fully done
        updateJobStatusDB(statusValue: "completed")
    }
    
    func showConfAlertBox(){
        
        let alertController = UIAlertController(title: "Payment", message: "Please make sure you have completed payment. By clicking 'Agree' you are confirming that you have paid the agreed amount to the correct employee. Failure to do so could result in an incomplete payment and further problems.", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Agree", style: .default, handler: { (action: UIAlertAction!) in
            print("PAYMENT COMPLETE")
            
            //updateDatabasePaid
            self.updateJobStatusDB(statusValue: "paid")
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("PAYMENT CANCELLED")
        }))
        present((alertController) , animated: true, completion: nil)
    }
    
    func updateJobStatusDB(statusValue : String)
    {
        
            
            let timestamp = Date().timeIntervalSince1970
            let ts = String(timestamp) //set new timestamp
            
            //for employers request list
         //   Database.database().reference().child("users").child(self.employerID!).child("jobRequestsList").observe(.value, with: { snapshot in
          //      if let snapshots = snapshot.value as? [String : AnyObject]{
         Database.database().reference().child("users").child(self.employerID!).child("jobRequestsList").child(self.jobKeyID!).observeSingleEvent(of: .value){ (snapshot) in
                if let child = snapshot.value as? [String : AnyObject]{
                  //  for child in snapshots { //for each pending request
                     //   if child.key == self.jobKeyID //with the jobKey id
                     //   {
                            
                            
                            let updateData = [
                                "employerId": self.employerID!,
                                "employeeId": self.employeeID!,
                                "jobTitle": self.jobTitle!,
                                "jobDescription": self.jobDescription!,
                                "employeeTerms": self.terms!,
                                "employeePriceQuote" : self.priceQuote!,
                                "lastTimestamp" : ts,
                                "paypalInfo" : self.paypalInfo,
                                "status": statusValue
                                ] as [String: Any] //
                            
                            //delete chosen user from requestList .child("users/\(user.uid)/username").setValue(username)
                            Database.database().reference().child("users").child(self.employerID!).child("jobRequestsList").child(self.jobKeyID!).setValue(updateData)
                      //  }
                   // }
                }
            }//)
            
            //for employees request list
           // Database.database().reference().child("users").child(self.employeeID!).child("jobRequestsList").observe(.value, with: { snapshot in
         //       if let snapshots = snapshot.value as? [String : AnyObject]{
         Database.database().reference().child("users").child(self.employeeID!).child("jobRequestsList").child(self.jobKeyID!).observeSingleEvent(of: .value){ (snapshot) in
                if let child = snapshot.value as? [String : AnyObject]{
                   // for child in snapshots { //for each pending request
                   //     if child.key == self.jobKeyID
                   //     {
                            //delete chosen user from requestList
                            
                            
                            let updateData = [
                                "employerId": self.employerID!,
                                "employeeId": self.employeeID!,
                                "jobTitle": self.jobTitle!,
                                "jobDescription": self.jobDescription!,
                                "employeeTerms": self.terms!,
                                "employeePriceQuote" : self.priceQuote!,
                                "lastTimestamp" : ts,
                                "status": statusValue
                                ] as [String: Any] //
                            Database.database().reference().child("users").child(self.employeeID!).child("jobRequestsList").child(self.jobKeyID!).setValue(updateData)
                            
                    //    }
                 //   }
                }
            }//)
            //var retToPrev = statusValue + "DONE"
        //mDelegate?.sendArrayToPreviousVC(flag: 1)
            self.dismiss(animated: true, completion: nil)
        
    }
    
    func alertPaypalInput(){
        self.paypalInfo = "Not recieved"
        
        //creates the alert controller
        let alert = UIAlertController(title: "Enter your Paypal Email or Number", message: "The Employer will send the payment to this address", preferredStyle: UIAlertControllerStyle.alert)
        
        //adds the text field to the alert controller
        alert.addTextField { (textField) in
            //textField.text = " - "
        }
        
        //gets the value from the text field and
        alert.addAction(UIAlertAction(title: "Agree", style: .default, handler: { (action: UIAlertAction!) in
            let textField = alert.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField.text)")
            self.paypalInfo = (textField.text)!
            self.paypalFlag = 1
            self.updateDatabaseAccept()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("PAYMENT CANCELLED")
        }))
        
        //show alert
        present((alert) , animated: true, completion: nil)
    }
    
    @IBAction func submitFeedbackClicked(_sender: AnyObject){
        
        //get other users feedbackScore + totalNumJobs
        //newFeedbackScore = (feedbackScore * totalNumJobs) + enteredFeedback)/ (totalNumJobs+1)
        //totalNumJobs++
        //update database
        
        var ID = ""
        var oppositeID = ""
        if self.myType == "Employer"
        {
            //get Employeeeees ID
            ID = self.employeeID!
            oppositeID = self.employerID!
            
            
        }
        else {
            //get Employerrrrs ID
            ID = self.employerID!
            oppositeID = self.employeeID!
        }
        
        var valueEntered = 1;
        let enteredFeedbackInput = self.feedbackTextView.text
        if enteredFeedbackInput == nil || enteredFeedbackInput == ""
        {
            valueEntered = 0
        }
        
        let enteredFeedback = Double(self.feedbackTextView.text)
        let ef = Int(self.feedbackTextView.text)
        if ef! > 100 || ef! < 0
        {
            showAlertBox(titleStr: "Error", messageStr: "Enter a number between 0 and 100 for feedback")
        }
        else{
        
        if valueEntered == 1{
        //for user with this ID
        Database.database().reference().child("users").child(ID).observeSingleEvent(of: .value){ (snapshot) in
            
            
        //update job status to history for ME only
        Database.database().reference().child("users").child(oppositeID).child("jobRequestsList").child(self.jobKeyID!).updateChildValues(["status": "history"])
            
            if let child = snapshot.value as? [String : AnyObject]{
                let feedbackScore = child["feedbackScore"] as! Double //gets the feedback score of user
                var totalNumJobs = child["totalNumJobs"] as! Double  //gets total number of jobs for the user
   
                //calculate new total average for new feedback score for this user
                let newFeedbackScore = ((feedbackScore * totalNumJobs) + enteredFeedback!) / (totalNumJobs + 1.0)
                totalNumJobs = totalNumJobs + 1.0

                //update new feedback score and new totalNumJobs (tnj) to database
               Database.database().reference().child("users/\(ID)/feedbackScore").setValue(newFeedbackScore)
               Database.database().reference().child("users/\(ID)/totalNumJobs").setValue(totalNumJobs)
                
                
                        //print("MY ID IS " + oppositeID)
                      // Database.database().reference().child("users/\(oppositeID)/jobRequestsList/\(self.jobKeyID)/status").setValue("history")
                
            }
        }
    
        
        }
        else{
            //show alert box
            showAlertBox(titleStr: "Error", messageStr: "Please enter a value before submitting")
        }
        
        self.dismiss(animated: true, completion: nil)
        }
        
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
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol MyProtocol: class
{
    func sendArrayToPreviousVC(flag: Int)
}
