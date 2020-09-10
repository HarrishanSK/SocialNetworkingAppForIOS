//
//  InfoController.swift
//  employ
//
//  Created by Harrishan Sureshkumar on 14/04/2018.
//  Copyright © 2018 Harrishan Sureshkumar. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class InfoController: UIViewController {

    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var jobsButton: UIButton!
    @IBOutlet weak var contactsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var x = 7.0
        self.profileButton.layer.cornerRadius = CGFloat(x)
        self.profileButton.clipsToBounds = true
        self.searchButton.layer.cornerRadius = CGFloat(x)
        self.searchButton.clipsToBounds = true
        self.jobsButton.layer.cornerRadius = CGFloat(x)
        self.jobsButton.clipsToBounds = true
        self.contactsButton.layer.cornerRadius = CGFloat(x)
        self.contactsButton.clipsToBounds = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func contactsClicked(_sender: AnyObject){
        showAlertBox(titleStr: "Contacts Page:", messageStr: "This page shows a list of your accepted contacts. Click one of the names in the list to view that contact's details as well as their location on a map. \n \n Click the 'Requests' button to view your contact request's sent to you by other users. The circled number represents the number of contact requests that are waiting to be accepted by you.")
    }
    
    @IBAction func profileClicked(_sender: AnyObject) {
            showAlertBox(titleStr: "Profile Page:", messageStr: "This page is shown to other users who search for you using the search page. You can edit your details using the 'Edit Profile' tab button on the left side of the central tab bar of the profile page. After editing your details, you must click the refresh button on the right to see the changes. \n \n A user's feedback score is an average from all the jobs they have been involved in. The Jobs completed section shows the number of jobs they have been involved in. \n \n The 'Sign Out' button is located on the top left of the profile page ")

    }
    
    @IBAction func searchClicked(_sender: AnyObject) {
        showAlertBox(titleStr: "Search Page:", messageStr: "Employer : \n \n 1) Advanced Search : \n As an Employer you can search for an Employee by entering a job category (examples; mechanic, cleaner, gardener, plumber..etc). \n Or you can simply type in your problem and our search engine will try and come up with a list of employees who can help you! \n (Example: I need flowers for my mum, will show a list of florists nearby) \n \n 2)Name Search: \n Once clicked, this feature allows for you to find Employees by name. \n \n 3) Our search engine will show you a list of employees nearby starting with the people closest to you! \n \n Employee: \n\n As an Employee you can search for Employer's by name.")
    }
    
    @IBAction func jobsClicked(_sender: AnyObject){
        showAlertBox(titleStr: "Jobs Page", messageStr:"A job goes through 4 stages. \n \n 1)Pending: The job starts off as pending when an Employer has sent a job request to an Employee \n \n 2)Accepted: When the Employee accepts the job its status changes to 'Accepted'\n \n 3)Paid: When the Job is done, the Employer must pay the employee and confirm payment. \n \n 4) The Employee then checks that payment is recieved and clicks confirm at which point the job status is 'Completed'. \n \n Both users can then give feedback for the jobs in the completed section at which point the job is transfered to the user's job history." )
    }
    
    //This was used once to wipe out all contact links in the entire database///////////////////////////////////////////
    @IBAction func delContClicked(_sender: AnyObject){
            //delCont()
    }
    
    //DELETE ALL CONTACT LISTS AND CONTACT REQUESTS LISTS in whole DB
    func delCont()
    {
        //for all users
        Database.database().reference().child("users").observe(.value, with: { snapshot in
            if let snapshots = snapshot.value as? [String : AnyObject]{
                
                for child in snapshots { //for each user with a contact request list
                    Database.database().reference().child("users").child(child.key).child("contactRequestsList").observe(.value, with: { snapshot2 in
                        if let snapshots2 = snapshot2.value as? [String : AnyObject]{
                            for listMember in snapshots2
                            {
                                //delete list member
                                Database.database().reference().child("users").child(child.key).child("contactRequestsList").child(listMember.key).removeValue()
                            }
                        }
                    })
                    
                    //For each user with a contactList
                    Database.database().reference().child("users").child(child.key).child("contactsList").observe(.value, with: { snapshot3 in
                        if let snapshots3 = snapshot3.value as? [String : AnyObject]{
                            for listMember2 in snapshots3
                            {
                                //delete list member
                                Database.database().reference().child("users").child(child.key).child("contactsList").child(listMember2.key).removeValue()
                            }
                        }
                    })
                    
                }
                
            }
        }
        )// rick is now removed from tonys request list
    }
    //This was used once to wipe out all contact links in the entire database!////////////////////////////////
    
    
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
