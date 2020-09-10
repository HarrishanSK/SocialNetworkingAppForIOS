//
//  ProfileTestController.swift
//  employ
//
//  Created by Harrishan Sureshkumar on 30/01/2018.
//  Copyright © 2018 Harrishan Sureshkumar. All rights reserved.
//
import UIKit
import SwiftKeychainWrapper
import Firebase

class viewProfileController: UIViewController, UITabBarDelegate {
    
    var childID : String?
    var fromContactRequestsPage : Bool?
    
    //vars loaded for user
    var currentUserImageUrl: String!
    var userType: String!
    var name: String!
    var email: String!
    var location: String!
    var number: String!
    var userDescription: String!
    
      var alertController: UIAlertController?

    @IBOutlet weak var feedbackScoreView: UITextView!
    @IBOutlet weak var jobsCompletedView: UITextView!
    
    @IBOutlet weak var jobTitleView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var navBar: UITabBar!
    //var timer = Timer()
    // @IBOutlet weak var searchTabButton: UITabBarItem!
    
    @IBOutlet weak var usrImgView: UIImageView!
    
    //icons on nav bar
    //@IBOutlet weak var searchIcon: UITabBarItem!
    @IBOutlet weak var searchBarButton: UITabBarItem!
    
    //text views for profile page
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var userTypeTextView: UITextView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var infoTextView: UITextView!
    
    @IBOutlet weak var locationTextView: UITextView!
    
    @IBOutlet weak var tabBar: UITabBar!
    // @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var callTab: UITabBarItem!
    @IBOutlet weak var messageTab: UITabBarItem!
    
    @IBOutlet weak var requestJobTab: UITabBarItem!
    @IBOutlet weak var addContactButton: UIButton!
    
   // @IBOutlet weak var callTab: UITabBarItem!
    override func viewDidLoad() {
        if let recievedText = childID {
            childID = recievedText
        }
        super.viewDidLoad()
        self.tabBar.delegate = self
        addPhotoButton.setTitle("", for: .normal)
        
        //round image
        let x = 3
        self.addPhotoButton.layer.cornerRadius = CGFloat(x)
        self.addPhotoButton.clipsToBounds = true
        self.usrImgView.layer.cornerRadius = CGFloat(x)
        self.usrImgView.clipsToBounds = true
        
        self.feedbackScoreView.layer.cornerRadius = CGFloat(x)
        self.feedbackScoreView.clipsToBounds = true
        self.jobsCompletedView.layer.cornerRadius = CGFloat(x)
        self.jobsCompletedView.clipsToBounds = true
        
        //if user is an employer
        getUsersData()
        checkContact()
        
        //check are we friends/contacts?
            //pending
            //confirmed
            //request
        if fromContactRequestsPage == true{
            addContactButton.isHidden = true
        }
        
        //if user is an employer then disable job requets button
        
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //This method will be called when user changes tab.
        print("tabBar selectoin")
        print(tabBar.selectedItem )
        if tabBar.selectedItem  == callTab
        {
            print("call tab selected")
            getNumber()
        }
        
        else if tabBar.selectedItem  == messageTab
        {
            messageClicked()
            print("message tab selected")
        }
        else if tabBar.selectedItem == requestJobTab
        {
            //Segue to request Job Page
            self.performSegue(withIdentifier: "toJobRequest", sender: nil)
            
        }
        
        
    }
    
    func checkContact() //checks if child is already users contact
    {
        let userId = KeychainWrapper.standard.string(forKey: "uid")
        Database.database().reference().child("users").child(userId!).child("contactsList").observe(.value, with: { snapshot in
            if let snapshots = snapshot.value as? [String : AnyObject]{
                
                for child in snapshots {
                   let childIDrevieved = child.value["childID"] as? String
                        if childIDrevieved == self.childID{
                         let statusType = child.value["status"] as? String
                         if statusType == "pending"
                         {
                            print("test31: TINGS PENDING")
                            //Make button say pending
                            self.addContactButton.setTitle("Pending", for: .normal)
                            self.addContactButton.isEnabled = false
                         }
                         else if statusType == "true"
                         {
                            print("test31: FRIENDS")
                            //Make button say contact
                            self.addContactButton.setTitle("Contact", for: .normal)
                            self.addContactButton.isEnabled = false
                        }
                         else{
                            print("test31: Never friends")
                            //Make button say add contact
                            self.addContactButton.setTitle("Add Contact", for: .normal)
                            self.addContactButton.isEnabled = true
                         }
                    }
                    
                }
            }
        })
        
    }
    
    func messageClicked()
    {
        if let uid = self.childID {
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
    
    func getNumber()
    {
      
      //  Database.database().reference().child("users").observe(.value, with: { snapshot in
      //      if let snapshots = snapshot.value as? [String : AnyObject]{
                let uid = self.childID
        Database.database().reference().child("users").child(self.childID!).observeSingleEvent(of: .value){ (snapshot) in
                    //  if let postDict = snapshot.value as? Dictionary<String, AnyObject>{
                    if let child = snapshot.value as? [String : AnyObject]{
                        
               // for child in snapshots {
                 //   let childId = child.key
                  //  if(childId == self.childID) {//found child user in database
                        let childNumber = child["number"] as? String
                    
                        print(childNumber)
                        self.callUsersNumber(number: childNumber!)
                   // }
               // }
                
            }
        }//)
    }
    
    private func callUsersNumber(number:String) {
        
        if let callURL = URL(string: "tel://\(number)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(callURL)) {
                application.open(callURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func searchButtonTapped(sender: UIBarButtonItem) {
        
    }
    
    @IBAction func addContactClicked(_sender: AnyObject){// back button
        showAddContactAlertBox()

    }
    
    func showAddContactAlertBox(){
        
        self.alertController = UIAlertController(title: "Send Contact Request?", message: "Once this contact request is accepted this user will be able to see your personal details such as your location. Similarly you will gain access to their details and location by tapping the user's name in your contact list on the Contact's page.", preferredStyle: UIAlertControllerStyle.alert)
        
        self.alertController?.addAction(UIAlertAction(title: "Send Request", style: .default, handler: { (action: UIAlertAction!) in
            self.addContact()
            self.addContactButton.setTitle("Pending", for: .normal)
            //addContactButton.isHidden = true
            self.addContactButton.isEnabled = false
        }))
        
        self.alertController?.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            //do nothing
        }))
        present((self.alertController)! , animated: true, completion: nil)
    }
    
    func addContact(){
        let userId = KeychainWrapper.standard.string(forKey: "uid")
        let contactData = [
            "childID": self.childID!,
            "status": "pending"
            ] as [String: Any] //
        
         let refID = Database.database().reference().childByAutoId().key//generates unique id for this contact request
        
        Database.database().reference().child("users").child(userId!).child("contactsList").child(refID).setValue(contactData)
        
        //example format : Database.database().reference().child("users").child(userId).setValue(userData)
        //contact request, stores request in child's storage space
        let requestData = [
            "requestUserId": userId!,
            "status": "pending"
            ] as [String: Any] //
        Database.database().reference().child("users").child(self.childID!).child("contactRequestsList").child(refID).setValue(requestData)
    }
    
    
    func sendJobRequest(){
        let userId = KeychainWrapper.standard.string(forKey: "uid")
        let jobData = [
            "childID": self.childID,
            "description": "Employee",
            "status": "pending"
            ] as [String: Any] //
        Database.database().reference().child("users").child(userId!).child("job").setValue(jobData)
    }
    
    func loadUserImage()
    {
        let httpsReference = Storage.storage().reference(forURL: currentUserImageUrl)
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        httpsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                self.usrImgView.image = image
            }
        }
    }
    
    
    
    func getUsersData(){
        if let uid = childID {
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value){ (snapshot) in
                //  if let postDict = snapshot.value as? Dictionary<String, AnyObject>{
                if let postDict = snapshot.value as? [String : AnyObject]{
                    self.currentUserImageUrl = postDict["userImg"] as! String //gets the url of image of user
                    self.loadUserImage()
                    //attributes for employer to be displayed : usertype, name , email , description
                    self.userType = postDict["userType"] as! String
                    self.name = postDict["name"] as! String //gets the name of user
                    self.email = postDict["email"] as! String
                    self.userDescription = postDict["description"] as! String
                    self.location = postDict["location"] as! String
                        var feedbackScore = postDict["feedbackScore"] as! Double
                    
                            let dp2multiplier = pow(10.0, 1.0) //round double to 1dp
                            feedbackScore = round(feedbackScore * dp2multiplier) / dp2multiplier
                            var fs = String(feedbackScore)
                    
                        var jobsCount = String( postDict["totalNumJobs"] as! Int )
                    self.feedbackScoreView.text = "Feedback Score: " + fs + "%"
                    self.jobsCompletedView.text = "Jobs Completed: " + jobsCount
                    
                    //Load for any user
                    self.userTypeTextView.text = self.userType
                    self.locationTextView.text = self.location
                    
                    //self.nameField.text = self.name
                    if self.userType == "Employer"
                    {
                        self.jobTitleView.text = "Employer"
                        self.nameTextView.text = self.name
                        self.infoTextView.text = self.email + "\n" //+ self.userDescription
                        self.descriptionTextView.text = self.userDescription
                        
                        self.requestJobTab.isEnabled = false
                        self.requestJobTab.title = "Employer"

                        //requestJobTab.remove
                     //   tabBarController?.viewControllers?.remove(at: 0)
                        
                        
                    }
                    else if self.userType == "Employee"
                    {
                        let empType = postDict["EmployeeType"] as! String
                         let jobCat = postDict["jobCategory"] as! String
                        if empType == "Freelancer" //IF employee is freelancer
                        {
                            self.nameTextView.text = self.name
                            let dob = postDict["dob"] as! String
                            
                            self.jobTitleView.text = jobCat
                            
                            self.infoTextView.text = "Email: " + self.email + "\n Date of Birth: " + dob 
                            self.descriptionTextView.text = self.userDescription
                        }
                        else if empType == "Business"{//IF employee is business
                            let businessName = postDict["BusinessName"] as! String
                            self.nameTextView.text = businessName
                            self.jobTitleView.text = jobCat + "'s"
                            self.infoTextView.text = "Email: " + self.email + "\n" //+ "Description: \n \n" + self.userDescription
                             self.descriptionTextView.text = self.userDescription
                        }
                        
                    }
                    
                    //self.loadUserImage()
                }
                
            }
        }
    }
    
    //  @IBAction func searchIconClicked(_sender: AnyObject){// back button
    //      self.performSegue(withIdentifier: "toSearch", sender: nil)
    //  }
    
    //prepare for job request page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let jobRequestVC = segue.destination as! jobRequestController
        jobRequestVC.childID = self.childID
    }
    //end - prepare for job request page
    
    
    @IBAction func backClicked(_sender: AnyObject){// back button
        
        self.dismiss(animated: true, completion: nil)
      //  self.performSegue(withIdentifier: "back", sender: nil)
        
    }

   // @IBAction func callClicked(_sender: AnyObject){// back button
        
   //     getNumber()
        
   // }
    
    
    
    
}



