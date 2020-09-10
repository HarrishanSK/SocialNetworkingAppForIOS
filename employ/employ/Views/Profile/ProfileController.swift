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

class ProfileController: UIViewController, UITabBarDelegate {
    
    //vars loaded for user
    var currentUserImageUrl: String!
    var userType: String!
    var name: String!
    var email: String!
    var location: String!
    
    var userDescription: String!
    
    @IBOutlet weak var navBar: UITabBar!
    //var timer = Timer()
   // @IBOutlet weak var searchTabButton: UITabBarItem!
    
    @IBOutlet weak var usrImgView: UIImageView!
    
    //icons on nav bar
    //@IBOutlet weak var searchIcon: UITabBarItem!
    @IBOutlet weak var searchBarButton: UITabBarItem!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    //text views for profile page
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var userTypeTextView: UITextView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var infoTextView: UITextView!

    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var locationTextView: UITextView!
    
    @IBOutlet weak var editProfileTab: UITabBarItem!
    @IBOutlet weak var helpTab: UITabBarItem!
    @IBOutlet weak var refreshTab: UITabBarItem!
    
    @IBOutlet weak var jobCatView: UITextView!
    @IBOutlet weak var feedbackScoreView: UITextView!
    @IBOutlet weak var jobCountView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.delegate = self
        
        //round edges
        let y = 3
        self.feedbackScoreView.layer.cornerRadius = CGFloat(y)
        self.feedbackScoreView.clipsToBounds = true
        self.jobCountView.layer.cornerRadius = CGFloat(y)
        self.jobCountView.clipsToBounds = true
        
        addPhotoButton.setTitle("", for: .normal)
        
        //round image
        let x = 3
        self.addPhotoButton.layer.cornerRadius = CGFloat(x)
        self.addPhotoButton.clipsToBounds = true
        self.usrImgView.layer.cornerRadius = CGFloat(x)
        self.usrImgView.clipsToBounds = true
        
        self.getUsersData()
        
        self.countContactRequests()
        self.countJobRequests()
        //if user is an employer
        

        // Do any additional setup after loading the view.
        
        
       // searchBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(searchButtonTapped(sender:)))!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getUsersData()
    }
    
    //override var isBeingPresented: Bool
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //This method will be called when user changes tab.
        print("tabBar selection")
        print(tabBar.selectedItem )
        if self.tabBar.selectedItem  == editProfileTab
        {
            //load edit profile page
            self.performSegue(withIdentifier: "toUpdateProfile", sender: nil)
        }
        else if self.tabBar.selectedItem  == helpTab
        {
            //when help tab is clicked load help page
            self.helpClicked()
            
        }
        else if self.tabBar.selectedItem  == refreshTab
        {
            //refresh page
            self.getUsersData()
            
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func searchButtonTapped(sender: UIBarButtonItem) {
        
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
        if let uid = KeychainWrapper.standard.string(forKey: "uid"){
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
                        
                        //Load for any user
                        self.userTypeTextView.text = self.userType
                        self.locationTextView.text = self.location
                        
                        var feedbackScore = postDict["feedbackScore"] as! Double
                        
                        let dp2multiplier = pow(10.0, 1.0) //round double to 1dp
                        feedbackScore = round(feedbackScore * dp2multiplier) / dp2multiplier
                        var fs = String(feedbackScore)
                        
                        var jobsCount = String( postDict["totalNumJobs"] as! Int )
                        var feedbackLine = "Feedback Score: " + fs + "%"
                        var jobCountLine = "Jobs Completed: " + jobsCount
                        self.feedbackScoreView.text = feedbackLine
                        self.jobCountView.text = jobCountLine
                        
                        //self.nameField.text = self.name
                        if self.userType == "Employer"
                        {
                            self.nameTextView.text = self.name
                            self.infoTextView.text = self.email + "\n"// + self.userDescription
                            self.descriptionTextView.text = self.userDescription
                            self.jobCatView.text = "Employer"
                        }
                        else if self.userType == "Employee"
                        {
                            let empType = postDict["EmployeeType"] as! String
                            let jobCat = postDict["jobCategory"] as! String
                             if empType == "Freelancer" //IF employee is freelancer
                             {
                                self.nameTextView.text = self.name
                                let dob = postDict["dob"] as! String
                                
                                self.jobCatView.text = jobCat
                                
                                self.infoTextView.text = "Date of Birth: " + dob + "\n Email: " + self.email //+ "\n" + self.userDescription
                                self.descriptionTextView.text = self.userDescription
                             }
                             else if empType == "Business"{//IF employee is business
                                let businessName = postDict["BusinessName"] as! String
                                self.jobCatView.text = jobCat + "'s"
                                self.nameTextView.text = businessName
                                self.infoTextView.text = "Email: " + self.email + "\n" //+ self.userDescription
                                
                                self.descriptionTextView.text = self.userDescription
                            }
                            
                        }
                        
                        //self.loadUserImage()
                    }
                    
                }
            }
    }
    
    func countContactRequests(){
        var count = 0
        let userId = KeychainWrapper.standard.string(forKey: "uid")
        Database.database().reference().child("users").child(userId!).child("contactRequestsList").observe(.value, with: { snapshot in
            if let snapshots = snapshot.value as? [String : AnyObject]{
                
                for child in snapshots { //for each pending request
                    
                    let statusType = child.value["status"] as? String//get status of child
                    if statusType == "pending"
                    {
                        
                        count = count + 1 //increment count
                        print("test41.2: PENDING, count is " + String(count))
                    }
                }
                
                //let strCount = "Requests: " + String(count)
                // self.requestsButton.setTitle(strCount, for: .normal)
               // self.requestsLabel.text = String(count)
                
            }
            else{
                self.tabBarController?.tabBar.items?[3].badgeValue = nil
            }
            
            if count > 0 {
                self.tabBarController?.tabBar.items?[3].badgeValue = String(count) //badge = count
            }
            else{//if count is 0
                self.tabBarController?.tabBar.items?[3].badgeValue = nil //dont show badge
            }
           // self.requestsLabel.text = String(count)
            //self.requestsButton.setTitle("Requests:", for: .normal)
            
        })
    }
    

    
    func countJobRequests(){
        var totalJobsInProgress = 0
        let userId = KeychainWrapper.standard.string(forKey: "uid")
        Database.database().reference().child("users").child(userId!).child("jobRequestsList").observe(.value, with: { snapshot in
            if let snapshots = snapshot.value as? [String : AnyObject]{
                var pending = 0;
                var accepted = 0
                var completed = 0
                var paid = 0
                var history = 0
                for child in snapshots { //for each job request for this user
                    let statusType = child.value["status"] as? String
                    
                    if statusType == "pending"                    {
                        pending = pending + 1
                    }
                    else if statusType == "accepted"
                    {
                        accepted = accepted + 1
                    }
                    else if statusType == "paid"
                    {
                        paid = paid + 1
                    }
                    else  if statusType == "completed"
                    {
                        completed = completed + 1
                    }
                    else{ //history
                        history = history + 1
                    }
                }
                totalJobsInProgress = pending + accepted + paid + completed
                self.tabBarController?.tabBar.items?[2].badgeValue = String(totalJobsInProgress)
                
            }
            else{
                self.tabBarController?.tabBar.items?[3].badgeValue = nil
            }
            
            if totalJobsInProgress > 0 {
                self.tabBarController?.tabBar.items?[2].badgeValue = String(totalJobsInProgress) //badge = count
            }
            else{//if count is 0
                self.tabBarController?.tabBar.items?[2].badgeValue = nil //dont show badge
            }
            
         }
        )
    }
    
    func helpClicked() {
        if self.userType == "Employee"
        {
            showAlertBox(titleStr: "Employee Help?", messageStr: "When an Employer searches for help using the search engine your name would appear on the list of results if you are located nearby. Wait for an Employer to contact you or search for them by name in the Search Page, check your Contacts page for any contact requests and check the Jobs page for any Job Requests!")
        }
        else{
            showAlertBox(titleStr: "Employer Help?", messageStr: "Go to the Search page and use our search engine to find employees near you! Click their name in the generated list to view their profile. Their profile will show their details and 3 options in the central tab bar. You can call them, message them, request to add them as a contact and also send a job request!")
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
  //  @IBAction func searchIconClicked(_sender: AnyObject){// back button
  //      self.performSegue(withIdentifier: "toSearch", sender: nil)
  //  }
    
    

    @IBAction func signOutClicked(_sender: AnyObject){// back button
        
        
        KeychainWrapper.standard.removeObject(forKey: "uid")
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        self.performSegue(withIdentifier: "signOut", sender: nil)
        
    }
    
    

    
    
}


