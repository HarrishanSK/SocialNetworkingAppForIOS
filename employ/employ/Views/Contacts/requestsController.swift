//
//  requestsController.swift
//  employ
//
//  Created by Harrishan Sureshkumar on 12/03/2018.
//  Copyright © 2018 Harrishan Sureshkumar. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class requestsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var listOfContacts = [contactRequest]()
    var currentCID = ""
    var currentRequestID = ""
    var currentIndex = 0
    var wait = 0
    
    var passID = ""
    
    struct contactRequest{
        var requestID = ""
        var childID = ""
        var name = ""
        var job = ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        

        //self.tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
       // self.listOfContacts.removeAll()
      //  self.tableView.reloadData()
        
        self.loadRequests()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadRequests(){
       // var count = 0
        self.listOfContacts.removeAll()
      //  self.tableView.reloadData()
        let userId = KeychainWrapper.standard.string(forKey: "uid")
        Database.database().reference().child("users").child(userId!).child("contactRequestsList").observe(.value, with: { snapshot in
            if let snapshots = snapshot.value as? [String : AnyObject]{
                
                for child in snapshots { //for each pending request
                    print("test42: inside first for loop")
                    let statusType = child.value["status"] as? String
                    if statusType == "pending"
                    {
                        print("test42: inside first for if statement where status = pending")
                        let childIDrecieved = child.value["requestUserId"] as? String
                        print("test42: id recieved is " + childIDrecieved!)
                        //get name and jobCat of child
                            Database.database().reference().child("users").observe(.value, with: { snapshot in
                            if let snapshots2 = snapshot.value as? [String : AnyObject]{
                                for child2 in snapshots2 {
                                    print("test42: inside second for loop")
                                    //let userID = child.key as! String//get user id of child
                                    let id = child2.key //get user id of child
                                    print("test42: id = " + id)
                                    if id == childIDrecieved
                                    {
                                        print("test42: id matched!")
                                        
                                     var childName = child2.value["name"] as? String
                                        
                                        //if employee
                                        let userType = child2.value["userType"] as? String
                                        if userType == "Employee"{
                                            //if usertype is business
                                            let employeeType = child2.value["EmployeeType"] as? String
                                                if employeeType == "Business"
                                                {
                                                    //name is business name
                                                    childName = child2.value["BusinessName"] as? String
                                            }
                                        }
                                        
                                        
                                        
                                        
                                        print("test42: name = " + childName!)
                                     var jobCat = " "
                                        if let jobC = child2.value["jobCategory"] as? [String : AnyObject]{ // if theres value
                                            jobCat = String(describing: jobC) //store job category of user
                                        }
                                        else{ //else no value for job category then
                                            jobCat = " " // they are an employer
                                        }
                                        print(jobCat)
                                       
                                        var addFlag = 0
                                        //check if members user id already exists in list //BLOCK FIRES- should block the 3 fires caused by db change in 3 places
                                        for m in self.listOfContacts
                                        {
                                            if m.requestID == child.key
                                            {
                                                addFlag = 1
                                            }
                                        }//...so if member is already in list so dont add again
                                        
                                        if addFlag == 0{
                                        self.listOfContacts.append(contactRequest( requestID: child.key ,childID: childIDrecieved!, name: childName!, job: jobCat))//add to list of requests
                                        print("test42: add to list")
                                        }
                                      //self.listOfContacts = self.listOfContacts.sorted(by: { $0.name < $1.name}) //order list alphabetically
                                      //self.tableView.reloadData()
                                    }
                                }
                                self.tableView.reloadData()
                              }
                               // self.tableView.reloadData()
                            }) //got the name of the child
                        
                        
                        
                        
                    }
                }
                
               // let strCount = "Requests: " + String(count)
              //  self.requestsButton.setTitle(strCount, for: .normal)
                
            }
        })
       // self.tableView.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listOfContacts.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : ContactsTableViewCell
        cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactsTableViewCell
        
        cell.nameLabel.text = self.listOfContacts[indexPath.row].name
        cell.jobLabel.text = self.listOfContacts[indexPath.row].job
        
        cell.acceptButton.tag = indexPath.row
        self.currentIndex = indexPath.row
        self.currentCID = self.listOfContacts[indexPath.row].childID
        self.currentRequestID = self.listOfContacts[indexPath.row].requestID
        cell.acceptButton.addTarget(self, action: #selector(self.acceptButtonClicked2(sender:)), for: .touchUpInside)
        cell.declineButton.addTarget(self, action: #selector(self.declineButtonClicked(sender:)), for: .touchUpInside)

        
        return cell
    }
    
    @objc func declineButtonClicked(sender: UIButton) {
        //self.listOfContacts.remove(at: self.currentIndex)
      //  self.tableView.reloadData()
        
       // var reloadCounter = 0;
        //remove this child from contactRequestList and add them to contactList: true
        let chosenId = self.currentCID
        let requestID = self.currentRequestID
        
        let userId = KeychainWrapper.standard.string(forKey: "uid")//for logged in user
        
        //remove request from user2's contact request list (i.e the person who recieved the contact request)
        Database.database().reference().child("users").child(userId!).child("contactRequestsList").child(requestID).removeValue()
        //remove request from user1's contact list (i.e the person who sent the contact request)
        Database.database().reference().child("users").child(chosenId).child("contactsList").child(requestID).removeValue()
        
        self.dismiss(animated: true, completion: nil)
        
       // self.listOfContacts.removeAll()
      //  self.tableView.reloadData()
      //  self.loadRequests()
        
        
        //for tony's request list
        /*Database.database().reference().child("users").child(userId!).child("contactRequestsList").observe(.value, with: { snapshot in
            if let snapshots = snapshot.value as? [String : AnyObject]{
                
                for child in snapshots { //for each pending request
                    print("test43: inside first for loop")
                    let statusType = child.value["status"] as? String
                    let childId = child.value["requestUserId"] as? String
                    if statusType == "pending"
                    {
                        
                        if childId == chosenId{
                            
                            //delete chosen user from requestList
                            Database.database().reference().child("users").child(userId!).child("contactRequestsList").child(child.key).removeValue()
                            //self.viewDidLoad()
                            
                        }
                    }
                }
                
            }
            //reloadCounter = reloadCounter + 1
        }
        )// rick is now removed from tonys request list*/
        

        
        
        
        
        //---
        //remove pending contact from contact list of request sender
       /* Database.database().reference().child("users").child(chosenId).child("contactsList").observe(.value, with: { snapshot in
            if let snapshots2 = snapshot.value as? [String : AnyObject]{
                
                for contact in snapshots2 { //for each pending request
                    print("IN NESTED 2ND FOR")
                    let contactId = contact.value["childID"] as? String
                    print("CHOSEN ID IS")
                    print(chosenId)
                    print("Contact ID IS")
                    print(contactId)
                    print("contact = chosen")
                    
                    if userId == contactId {

                        //     let contactStatus = contact.value["status"] as? String
                        //  if contactStatus == "pending"
                        //  {
                        //remove this entry
                        print("REMOVING 1 ")
                        Database.database().reference().child("users").child(chosenId).child("contactsList").child(contact.key).removeValue()
                        //self.viewDidLoad()
                        // self.listOfContactRequests.removeAll()
                        // }
                    }
                }
            }
            reloadCounter = reloadCounter + 1
        })*/
        //---
       // self.dismiss(animated: true, completion: nil)
      //   self.loadRequests()
    }
    
   /* @objc func acceptButtonClicked(sender: UIButton) {
        //self.listOfContacts.remove(at: self.currentIndex)
       // self.tableView.reloadData()
        
        var reloadCounter = 0;
        //remove this child from contactRequestList and add them to contactList: true
        let chosenId = self.currentCID
        let requestId = self.currentRequestID
        let userId = KeychainWrapper.standard.string(forKey: "uid")//for logged in user
        
        //for tony's request list
        Database.database().reference().child("users").child(userId!).child("contactRequestsList").observe(.value, with: { snapshot in
            if let snapshots = snapshot.value as? [String : AnyObject]{
                
                for child in snapshots { //for each pending request
                    print("test43: inside first for loop")
                    let statusType = child.value["status"] as? String
                    let childId = child.value["requestUserId"] as? String
                    if statusType == "pending"
                    {
                        
                        if childId == chosenId{
                            
                        //delete chosen user from requestList
                       Database.database().reference().child("users").child(userId!).child("contactRequestsList").child(child.key).removeValue()
                           
                        //add chosen user to contactList
                            let contactData = [
                                "childID": chosenId,
                                "status": "true"
                                ] as [String: Any]
                        Database.database().reference().child("users").child(userId!).child("contactsList").childByAutoId().setValue(contactData)
                         self.listOfContacts.removeAll()
                            print("test43: added contact1")
                        }
                    }
                  }
                
                 }
            reloadCounter = reloadCounter + 1
                }
            )// rick is now removed from tonys request list
                        
                        
                        
                            
            //if rick is also pending in tony's contact list then remove him
            Database.database().reference().child("users").child(userId!).child("contactsList").observe(.value, with: { snapshot in
            if let snapshots = snapshot.value as? [String : AnyObject]{
                
                for contact in snapshots { //for each pending request
                    let contactId = contact.value["childID"] as? String
                    if chosenId == contactId {
                        let contactStatus = contact.value["status"] as? String
                          if contactStatus == "pending"
                          {
                            //remove this entry
                             Database.database().reference().child("users").child(userId!).child("contactsList").child(contact.key).removeValue()
                            self.listOfContacts.removeAll()
                          }
                    }
                }
             }
                reloadCounter = reloadCounter + 1
            })
        
        
        
        
        
        //Now its time to update RICKS list!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        //if tony is pending in ricks's contact list then remove him
        Database.database().reference().child("users").child(chosenId).child("contactsList").observe(.value, with: { snapshot in
            if let snapshots = snapshot.value as? [String : AnyObject]{
                
                for contact in snapshots { //for each pending request
                    let contactId = contact.value["childID"] as? String
                    if userId == contactId {
                        let contactStatus = contact.value["status"] as? String
                        if contactStatus == "pending"
                        {
                            //remove this entry
                            Database.database().reference().child("users").child(chosenId).child("contactsList").child(contact.key).removeValue()
                            self.listOfContacts.removeAll()
                            //add  user to ricks contactList
                            let contactData = [
                                "childID": userId,
                                "status": "true"
                                ] as [String: Any]
                            Database.database().reference().child("users").child(chosenId).child("contactsList").childByAutoId().setValue(contactData)
                            self.listOfContacts.removeAll()
                            
                        }
                        
                        
                    }
                }
            }
            reloadCounter = reloadCounter + 1
        })
        
        //for ricks request list, remove tony in request list and add him to contacts list
        Database.database().reference().child("users").child(chosenId).child("contactRequestsList").observe(.value, with: { snapshot in
            if let snapshots = snapshot.value as? [String : AnyObject]{
                
                for child in snapshots { //for each pending request
                    print("test43: inside first for loop")
                    let statusType = child.value["status"] as? String
                    let childId = child.value["requestUserId"] as? String
                    if childId == userId { //if found tony's ID in ricks request list
                     if statusType == "pending"
                     {
                        
                        //if childId == userId{ //if found tony's ID in ricks request list
                            
                            //delete  user from ricks requestList
                            Database.database().reference().child("users").child(chosenId).child("contactRequestsList").child(child.key).removeValue()
                        self.listOfContacts.removeAll()
                      //  }
                        }
                        
                        print("test43: added contact2")
                        
                     
                    }
                }
            }
             reloadCounter = reloadCounter + 1
        }
        )// tony is now removed from rick's request list
        
        
        if reloadCounter == 4{ //NOTE:doesnt even reach HERE so what on earth is happening... nest these 4 sections to force linear flow
        // self.loadRequests()
            print("rc test43 " + String(reloadCounter))
            self.wait = 1
           // self.tableView.reloadData()
        }

     //self.tableView.reloadData()
   //viewDidAppear(true)
        self.dismiss(animated: true, completion: nil)

    }*/
    

    @objc func acceptButtonClicked2(sender: UIButton) {

        let chosenId = self.currentCID
        let requestId = self.currentRequestID
        let userId = KeychainWrapper.standard.string(forKey: "uid")//for logged in user
        
        //for user 1 (i.e person who sent request)
                //update from pending to accepted
                Database.database().reference().child("users").child(chosenId).child("contactsList").child(requestId).updateChildValues(["status": "true"])

        
        //for user 2 ( i.e person who recieved the request) ME
                
                //remove from contactRequests List
                Database.database().reference().child("users").child(userId!).child("contactRequestsList").child(requestId).removeValue()
                
                //...and add to contactsList
                let addData = [
                    "childID": chosenId, //other user's id
                    "status": "true" //true means both users are now contacts of each other
                    ] as [String: Any]
        Database.database().reference().child("users").child(userId!).child("contactsList").child(requestId).setValue(addData)  //stores image and username in user's tree in database

        
       self.dismiss(animated: true, completion: nil)
      //  self.listOfContacts.removeAll()
     //   self.tableView.reloadData()
       //  self.loadRequests()
        
    }
    
    @IBAction func backButtonClicked(_sender: AnyObject){// back button
        //self.performSegue(withIdentifier: "back", sender: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print(listOfContacts[indexPath.row].childID)
        self.passID = listOfContacts[indexPath.row].childID

        
        self.performSegue(withIdentifier: "toViewProfile", sender: nil)
        //send this id to the next viewProfileController
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50.0;//Choose your custom row height
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewProfileVC = segue.destination as! viewProfileController
        viewProfileVC.childID = self.passID
        viewProfileVC.fromContactRequestsPage = true
    }


}
