//
//  ContactsController.swift
//  employ
//
//  Created by Harrishan Sureshkumar on 12/03/2018.
//  Copyright © 2018 Harrishan Sureshkumar. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ContactsController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    var listOfContacts = [contact]()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var requestsButton: UIButton!
    
    @IBOutlet weak var requestsLabel: UILabel!
    var segRequests = 0
    
    var passID = ""
    var requestKeyID = ""
    var viewDidVar = 0
    var contactListChangeFir = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.requestsLabel.layer.cornerRadius = self.requestsLabel.frame.size.height/2 //CGFloat(17)
        self.requestsLabel.clipsToBounds = true
        
        /*//empty table
        listOfContacts.removeAll()
        self.tableView.reloadData()
        
        //count number of requests and display it in the button title
        self.countRequests()
        self.loadContacts()
       // let strCount = "Requests: " + String(count)
       // self.requestsButton.setTitle(strCount, for: .normal)
        
        
        
        //load list of contacts in alphabetical order
 */
       // self.listOfContacts.removeAll()
       // self.loadContacts()
       // self.tableView.reloadData()
       // self.loadContacts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.viewDidVar = 1 //flag for viewDidAppear, runs once each
        //empty table
        self.listOfContacts.removeAll()
        //self.tableView.reloadData()
        
        //count number of requests and display it in the button title
        self.countRequests()
        //self.loadContacts()
        self.loadContacts()
        
        self.tableView.reloadData()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.countRequests()
        
    }
    
    
    
    struct contact{
        var requestKeyID = ""
        var contactID = ""
        var name = ""
        var job = ""
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listOfContacts.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : ContactsTableViewCell
        cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactsTableViewCell
        
        cell.nameLabel.text = self.listOfContacts[indexPath.row].name
        cell.jobLabel.text = self.listOfContacts[indexPath.row].job
        print(self.listOfContacts[indexPath.row].name)
        print(self.listOfContacts[indexPath.row].job)
        cell.acceptButton.tag = indexPath.row
       // self.currentIndex = indexPath.row
      //  self.currentCID = self.listOfContacts[indexPath.row].childID
        cell.acceptButton.isHidden = true
        cell.declineButton.isHidden = true
        
        
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 70.0;//Choose your custom row height
    }
    
    func countRequests(){
        var count = 0
        let userId = KeychainWrapper.standard.string(forKey: "uid")
        Database.database().reference().child("users").child(userId!).child("contactRequestsList").observe(.value, with: { snapshot in
            if let snapshots = snapshot.value as? [String : AnyObject]{
                
                for child in snapshots { //for each pending request

                        let statusType = child.value["status"] as? String
                        if statusType == "pending"
                        {
                            print("test41: PENDING")
                            count = count + 1 //increment count
                        }
                }
                
                //let strCount = "Requests: " + String(count)
               // self.requestsButton.setTitle(strCount, for: .normal)
                self.requestsLabel.text = String(count)
                
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
            self.requestsLabel.text = String(count)
            //self.requestsButton.setTitle("Requests:", for: .normal)
            
        })
    }
    
    func loadContacts()
    {
        if self.viewDidVar == 1 {
           // self.viewDidVar = 0
        // var count = 0
        self.listOfContacts.removeAll()
        //  self.tableView.reloadData()
        let userId = KeychainWrapper.standard.string(forKey: "uid")
        Database.database().reference().child("users").child(userId!).child("contactsList").observe(.value, with: { snapshot in
            if let snapshots = snapshot.value as? [String : AnyObject]{
                
                if self.viewDidVar == 1{
                    self.viewDidVar = 0
                
                    
                for child in snapshots { //for each pending request
                    print("test44: inside first for loop")
                    let statusType = child.value["status"] as? String
                    if statusType == "true"
                    {
                        print("test44: inside first for if statement where status = true")
                        let childIDrecieved = child.value["childID"] as? String
                        print("test44: id recieved is " + childIDrecieved!)
                        //get name and jobCat of child
                        Database.database().reference().child("users").observe(.value, with: { snapshot in
                            if let snapshots2 = snapshot.value as? [String : AnyObject]{
                                for child2 in snapshots2 {
                                    print("test44: inside second for loop")
                                    //let userID = child.key as! String//get user id of child
                                    let id = child2.key as! String //get user id of child
                                    print("test44: id = " + id)
                                    if id == childIDrecieved
                                    {
                                        print("test44: id matched!")
                                        
                                        // if userType is Employee
                                        //let userType = child2.value["userType"] as? String
                                            //if EmployeeType is Freelancer
                                                //name = name
                                            //else
                                                //name = business name
                                        
                                        
                                        
                                        var childName = child2.value["name"] as? String
                                        //print(childName)
                                        
                                        
                                        var jobCat = "Contact"
                                        let userType = child2.value["userType"] as? String
                                        if userType == "Employee" //if user is employee
                                        {
                                            jobCat = (child2.value["jobCategory"] as? String)! //get jobcategory
                                            
                                            let employeeType = child2.value["EmployeeType"] as? String
                                            if employeeType == "Freelancer"
                                            {
                                                childName = child2.value["name"] as? String
                                            }
                                            else{//if business
                                                childName = child2.value["BusinessName"] as? String
                                            }
                                            
                                        }
                                        else{ //else no value for job category then
                                            jobCat = "" // they are an employer
                                        }
                                        print("twst44: name = " + childName!)
                                        print("test44: jobCat = " + jobCat)
                                        
                                        //get requestIDkey
                                        let requestKeyID = child.key
                                        
                                        var addFlag = 0
                                        //check if contact id already exists in list //BLOCK FIRES- should block the 3 fires caused by db change in 3 places
                                        for c in self.listOfContacts
                                        {
                                            if c.contactID == childIDrecieved
                                            {
                                                addFlag = 1
                                            }
                                        }//...so if contact is already in list dont add again
                                        
                                        if addFlag == 0 {
                                            self.listOfContacts.append(contact(requestKeyID: requestKeyID, contactID: childIDrecieved!, name: childName!, job: jobCat))//add to list of requests
                                        print("test44: add to list")
                                        self.listOfContacts = self.listOfContacts.sorted(by: { $0.name < $1.name}) //order list alphabetically
                                        self.tableView.reloadData()
                                        }//end of add flag
                                    }
                                }
                               // self.tableView.reloadData()
                            }
                            // self.tableView.reloadData()
                        }) //got the name of the child
                        
                        
                        
                        
                    }
                }
                
                // let strCount = "Requests: " + String(count)
                //  self.requestsButton.setTitle(strCount, for: .normal)
                
            }//end of view did var if statement
          }
            
        })
        // self.tableView.reloadData()
        }//end of if statement
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func requestsButtonClicked(_sender: AnyObject){
        self.performSegue(withIdentifier: "toRequests", sender: nil)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        self.segRequests = 1
        print(listOfContacts[indexPath.row].contactID)
        self.passID = listOfContacts[indexPath.row].contactID
        self.requestKeyID = listOfContacts[indexPath.row].requestKeyID
        
        self.performSegue(withIdentifier: "toViewContact", sender: nil)
        //send this id to the next viewContactController
    }
    
    @IBAction func historyClicked(_sender: AnyObject){
        showAlertBox(titleStr: "Help?", messageStr: "This page shows a list of your accepted contacts. Click one of the names in the list to view that contact's details as well as their location on a map. \n \n Click the 'Requests' button to view your contact request's sent to you by other users. The circled number represents the number of contact requests that are waiting to be accepted by you.")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segRequests == 1{
         let viewContactControllerVC = segue.destination as! viewContactController
         viewContactControllerVC.contactID = self.passID
         viewContactControllerVC.requestKeyID = self.requestKeyID
         segRequests = 0
        }
      
    }
    

}
