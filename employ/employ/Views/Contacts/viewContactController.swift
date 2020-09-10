//
//  viewContactController.swift
//  employ
//
//  Created by Harrishan Sureshkumar on 10/04/2018.
//  Copyright © 2018 Harrishan Sureshkumar. All rights reserved.
//

import UIKit
import WebKit
import Firebase
import SwiftKeychainWrapper

class viewContactController: UIViewController, WKUIDelegate {
    var contactID : String?
    var requestKeyID : String?

    @IBOutlet weak var nameView: UITextView!
    @IBOutlet weak var detailsView: UITextView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    var alertController: UIAlertController?
    
    @IBOutlet weak var deleteContactButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsersData()
        
       // let myURL = URL(string: "https://www.google.co.uk/maps/dir/TW32PB/W55AL")
       // let myRequest = URLRequest(url: myURL!)
       // self.webView.load(myRequest)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
       // self.scrollView.frame = self.innerView.frame;
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func googleDistanceInput(contactsPostcode: String)
    {
        var employeePostcode = "" //always starting
        var employerPostcode = "" //always destination
        
        if let uid = KeychainWrapper.standard.string(forKey: "uid"){
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value){ (snapshot) in //connect to database
                
                if let postDict = snapshot.value as? [String : AnyObject]{
                    let myPostcode = postDict["postcode"] as! String //gets postcode of user
                    let myUserType = postDict["userType"] as! String //gets my userType
                    //Make sure starting is always employee location
                    if myUserType == "Employer"
                    {
                        employerPostcode = myPostcode
                        employeePostcode = contactsPostcode
                    }
                    else{
                        employeePostcode = myPostcode
                        employerPostcode = contactsPostcode
                    }//end of make sure starting is always employee location
                    //generate custom url
                    var customURL = "https://www.google.co.uk/maps/dir/" + employeePostcode + "/" + employerPostcode + ""
                    customURL = customURL
                        .replacingOccurrences(of: " ", with: "", options: .literal, range: nil)//remove spaces in url caused by postcodes
                    let myURL = URL(string: customURL) //declare custom url
                    let myRequest = URLRequest(url: myURL!)
                    self.webView.load(myRequest)//load map with custom url
                }
            }
        }
    }
    
    @IBAction func messageClicked(_sender: AnyObject)
    {
        if let uid = self.contactID {
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value){ (snapshot) in
                //  if let postDict = snapshot.value as? Dictionary<String, AnyObject>{
                if let child = snapshot.value as? [String : AnyObject]{
                    
                    let number = child["number"] as? String
                    let strSMS = "sms:+" + number!
        UIApplication.shared.open(URL(string: strSMS)!, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    @IBAction func callClicked(_sender: AnyObject)
    {
        getNumber()
    }
    
    func getNumber()
    {
        
        if let uid = self.contactID {
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value){ (snapshot) in
                //  if let postDict = snapshot.value as? Dictionary<String, AnyObject>{
                if let child = snapshot.value as? [String : AnyObject]{
                   
                        let childNumber = child["number"] as? String
                        
                        print(childNumber)
                        self.callUsersNumber(number: childNumber!)
                    
                }
                
            }
        }
    }
    
    private func callUsersNumber(number:String) {
        
        if let callURL = URL(string: "tel://\(number)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(callURL)) {
                application.open(callURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    func getUsersData(){
        if let uid = self.contactID {
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value){ (snapshot) in
                //  if let postDict = snapshot.value as? Dictionary<String, AnyObject>{
                if let postDict = snapshot.value as? [String : AnyObject]{
                   // self.currentUserImageUrl = postDict["userImg"] as! String //gets the url of image of user
                  //  self.loadUserImage()
                    //attributes for employer to be displayed : usertype, name , email , description
                    let userType = postDict["userType"] as! String
                    let name = postDict["name"] as! String //gets the name of user
                    let email = postDict["email"] as! String
                  //  let userDescription = postDict["description"] as! String
                    let location = postDict["location"] as! String
                    let postcode = postDict["postcode"] as! String
                    var feedbackScore = postDict["feedbackScore"] as! Double
                    
                    self.googleDistanceInput(contactsPostcode: postcode)//call google
                    
                    let dp2multiplier = pow(10.0, 1.0) //round double to 1dp
                    feedbackScore = round(feedbackScore * dp2multiplier) / dp2multiplier
                    let fs = String(feedbackScore)
                    
                    let jobsCount = String( postDict["totalNumJobs"] as! Int )
                    
                    //Details lines
                    let feedbackScoreLine = "Feedback Score: " + fs + "%" + "\n"
                    let jobsCompletedLine = "Jobs Completed: " + jobsCount + "\n" + "\n"
                    let emailLine = "Email: " + email + "\n"
                    let locationLine = "Location: " + location + "\n"
                    let postcodeLine = "Postcode: " + postcode
                    
                    
                    //Load for any user
                   // self.userTypeTextView.text = self.userType
                   // self.locationTextView.text = self.location
                    
                    //self.nameField.text = self.name
                    if userType == "Employer"
                    {
                        self.nameView.text = name
                        self.detailsView.text = feedbackScoreLine + jobsCompletedLine + emailLine + locationLine + postcodeLine
                        
                        
                        
                    }
                    else if userType == "Employee"
                    {
                        let empType = postDict["EmployeeType"] as! String
                        let jobCat = postDict["jobCategory"] as! String
                       // var jobCatLine = "Job Category: " + jobCat + "\n"
                        if empType == "Freelancer" //IF employee is freelancer
                        {
                            self.nameView.text = name
                            let dob = postDict["dob"] as! String
                            let jobCatLine = jobCat + "\n" + "\n"
                            let dobLine = "Date of Birth: " + dob + "\n"
                            
                            
                            
                            self.detailsView.text = jobCatLine + feedbackScoreLine + jobsCompletedLine + dobLine + emailLine + locationLine + postcodeLine
                            
                           
                        }
                        else if empType == "Business"{//IF employee is business
                            let businessName = postDict["BusinessName"] as! String
                            let ownerName = postDict["name"] as! String
                            let ownerNameLine = "Owner Name: " + ownerName + "\n"
                            let jobCatLine = jobCat + "s \n" + "\n"
                            self.nameView.text = businessName
                            self.detailsView.text = jobCatLine + feedbackScoreLine + jobsCompletedLine + ownerNameLine + emailLine + locationLine + postcodeLine
                            
                        }
                        
                    }
                    
                    //self.loadUserImage()
                }
                
            }
        }
    }
    
    @IBAction func backClicked(_sender: AnyObject){// back button
        
        self.dismiss(animated: true, completion: nil)
        //  self.performSegue(withIdentifier: "back", sender: nil)
        
    }
    
    @IBAction func deleteContactClicked(_sender: AnyObject){// back button
        showDeleteAlertBox()
    }
    
    func showDeleteAlertBox(){
        
        self.alertController = UIAlertController(title: "Are you sure?", message: "If you delete this person from your contact list you can no longer see their personal information and they can no longer see yours.", preferredStyle: UIAlertControllerStyle.alert)
        
        self.alertController?.addAction(UIAlertAction(title: "Delete Contact", style: .default, handler: { (action: UIAlertAction!) in
            let userId = KeychainWrapper.standard.string(forKey: "uid")//for logged in user
            
            //Delete contact from contact list
            Database.database().reference().child("users").child(userId!).child("contactsList").child(self.requestKeyID!).removeValue()
            //Delete logged in user from contact's contact list
            Database.database().reference().child("users").child(self.contactID!).child("contactsList").child(self.requestKeyID!).removeValue()
            
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.alertController?.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        present((self.alertController)! , animated: true, completion: nil)
    }
    
    @IBAction func viewProfileClicked(_sender: AnyObject){

          self.performSegue(withIdentifier: "toViewProfile", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewProfileVC = segue.destination as! viewProfileController
        viewProfileVC.childID = self.contactID
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
