//
//  jobsTableController.swift
//  employ
//
//  Created by Harrishan Sureshkumar on 07/04/2018.
//  Copyright © 2018 Harrishan Sureshkumar. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class jobsTableController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var type: String? // Pending, accepted, paid, completed or history
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var typeLabel: UILabel!
    var myType = "Employee"
    var listOfJobs = [jobListMember]()
    var listOfSortedJobs = [jobListMember]()
    
    var clickedJobTitle = ""
    var clickedJobDescription = ""
    var clickedTerms = ""
    var clickedPrice = ""
    var clickedJobKeyID = ""
    var clickedEmployerID = ""
    var clickedEmployeeID = ""
    
    var countViews = 0
    
    
    struct jobListMember{
        var senderID = ""
        var jobTitle = ""
        var name = ""
        var timestamp = ""
        var price = " "
        var jobDescription = ""
        var terms = ""
        var jobKeyID = ""
        var employerID = ""
        var employeeID = ""
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        print("Open jobstableController")
        //checkUserAndLoadRequests()
        print("the type is " + self.type!)
       // typeLabel.text = self.type
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
        typeLabel.text = ptype
        //countViews = countViews + 1
        
      //  getJobRequests()

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        self.listOfJobs.removeAll()
        self.listOfSortedJobs.removeAll()
        self.tableView.reloadData()
        self.checkUserAndLoadRequests()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.listOfJobs.removeAll()
        self.listOfSortedJobs.removeAll()
        self.tableView.reloadData()
        self.checkUserAndLoadRequests()
        
       // self.checkUserAndLoadRequests()
        
        /*
        //sendFlagToPreviousVC()
        self.countViews = self.countViews + 1
        if self.countViews > 1 && self.type != "history" {
           
            self.dismiss(animated: true, completion: nil)
            
        }*/
        
        //Count 4 types
        
   }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getJobRequests(){
        print("test 50 : in getJobRequests")
        let userId = KeychainWrapper.standard.string(forKey: "uid")
        
        Database.database().reference().child("users").child(userId!).child("jobRequestsList").observe(.value, with: { snapshot in
            if let snapshots = snapshot.value as? [String : AnyObject]{
                
                for child in snapshots { //for each pending request
                    print("test 50 : in first forloop")
                    let statusType = child.value["status"] as? String
                    
                    if statusType == self.type
                    {
                        print("test 50 : For this status type: " + self.type!)
                        let jt = (child.value["jobTitle"] as? String)!
                        print("test 50 : job title is " + jt)
                        let ts = child.value["lastTimestamp"] as? String
                        print("test50 : time stamp = " + ts!)
                        let price = child.value["employeePriceQuote"] as? String
                        print("test50 : price = " + price!)
                        let jd = child.value["jobDescription"] as? String
                        let t = child.value["employeeTerms"] as? String
                        let jobKey = child.key
                        let employerID = child.value["employerId"] as? String
                        let employeeID = child.value["employeeId"] as? String
                        
                        var name = ""
                        var ID = ""
                        
                        
                        //let userType = child.value["userType"] as? String
                        if self.myType == "Employee"{
                            ID = (child.value["employerId"] as? String)!
                        }
                        else if self.myType == "Employer"{
                            ID = (child.value["employeeId"] as? String)!
                        }
                        print("test50 : this User is not an " + self.myType)
                        
                        //get name
                        Database.database().reference().child("users").observe(.value, with: { snapshot in
                            if let snapshots2 = snapshot.value as? [String : AnyObject]{
                                
                                for child2 in snapshots2 { //for each pending request
                                    print("test 50 : in second forloop")
                                    let personID = child2.key
                                    if personID == ID{
                                        print("test 50 : id matched!!!")
                                        
                                        name = (child2.value["name"] as? String)!
                                        
                                        //if business then but business name
                                        let uType = (child2.value["userType"] as? String)!
                                        if uType == "Employee"{
                                            let eType = (child2.value["EmployeeType"] as? String)!
                                            if eType == "Business" {
                                                let bName = (child2.value["BusinessName"] as? String)!
                                                name = bName
                                            }
                                        }
   
                                        print("test50 : name = " + name)
                                       
                                        
                                        var addFlag = 0
                                        //check if members jobkey id already exists in list //BLOCK FIRES- should block the 3 fires caused by db change in 3 places
                                        for m in self.listOfJobs
                                        {
                                            if m.jobKeyID == jobKey
                                            {
                                                addFlag = 1
                                            }
                                        }//...so if member is already in list so dont add again
                                        
                                        if addFlag == 0 {
                                        self.listOfJobs.append(jobListMember( senderID: ID, jobTitle: jt, name: name, timestamp: ts!, price: price!, jobDescription: jd!, terms: t!, jobKeyID: jobKey, employerID: employerID!, employeeID: employeeID!))//add to list of requests
                                        
                                        self.listOfSortedJobs = self.listOfJobs.sorted(by: { $0.timestamp > $1.timestamp}) //order list using time. Latest first
                                        self.tableView.reloadData()
                                        print("test 50 : Added to list of sorted jobs: " + String(self.listOfSortedJobs.count))
                                        //self.tableView.reloadData()
                                        }
                                        
                                    }
                                }//end of for each child

                                
                            }
                            
                            // if no requests...load empty table
                            if self.listOfSortedJobs.count < 1 {
                                self.listOfSortedJobs.append(jobListMember( senderID: "", jobTitle: "", name: "No Requests", timestamp: "", price: "", jobDescription: "", terms: "", jobKeyID: "none", employerID: "", employeeID: ""))//add to list of requests
                                self.tableView.reloadData()
                            }
                            
                        })
                        //end of get name
                        
                    }
                }

                
            } //if snapshots - end
            

            
        })
        
    }
    
    func checkUserAndLoadRequests()
    {
        let userId = KeychainWrapper.standard.string(forKey: "uid")
         let dispatch = DispatchGroup()
        dispatch.enter()
        Database.database().reference().child("users").child(userId!).observeSingleEvent(of: .value){ (snapshot) in
         //   if let snapshots = snapshot.value as? [String : AnyObject]{
                if let child = snapshot.value as? [String : AnyObject]{
                  //  self.currentUserImageUrl = postDict["userImg"] as! String //gets the url of image of user
                    
              //  for child in snapshots { //for each pending request
                    let userType = child["userType"] as? String
                    if userType == "Employee"
                    {
                        self.myType = "Employee"
                    }
                    else{
                        self.myType = "Employer"
                    }
                    print("USER1 is an " + self.myType)
                    self.getJobRequests()
                }
           // }
            dispatch.leave()
        }
      //  print("USER2 is an " + self.myType)
        
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listOfSortedJobs.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : JobTableViewCell
        cell = tableView.dequeueReusableCell(withIdentifier: "jobCell", for: indexPath) as! JobTableViewCell
        
        if self.listOfSortedJobs[indexPath.row].jobKeyID != "none"
        {
            cell.nameLabel.text = "Name: " + self.listOfSortedJobs[indexPath.row].name
            cell.jobTitleLabel.text = self.listOfSortedJobs[indexPath.row].jobTitle
            cell.priceLabel.text = "£" + self.listOfSortedJobs[indexPath.row].price
    
        }
        else{
            cell.jobTitleLabel.text = "No " + self.type! + " jobs found."
            cell.nameLabel.text = ""
            cell.priceLabel.text = ""
        }
        
         return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80.0;//Choose your custom row height
    }
    
    @IBAction func backClicked(_sender: AnyObject){// back button
        
        self.dismiss(animated: true, completion: nil)
        //  self.performSegue(withIdentifier: "back", sender: nil)
        
    }
    
    //prepare for pending form page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let jobFormVC = segue.destination as! viewJobFormController
        jobFormVC.mDelegate = self as? MyProtocol//added for retvalue
        jobFormVC.type = self.type
        jobFormVC.jobTitle = self.clickedJobTitle
        jobFormVC.jobDescription = self.clickedJobDescription
        jobFormVC.terms = self.clickedTerms
        jobFormVC.priceQuote = self.clickedPrice
        jobFormVC.jobKeyID = self.clickedJobKeyID
        jobFormVC.myType = self.myType
        jobFormVC.employerID = self.clickedEmployerID
         jobFormVC.employeeID = self.clickedEmployeeID
       
        
    }
    //end - prepare for pending form page
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if self.listOfSortedJobs[indexPath.row].jobKeyID != "none" {

        self.clickedJobTitle = listOfSortedJobs[indexPath.row].jobTitle
        self.clickedJobDescription = listOfSortedJobs[indexPath.row].jobDescription
        self.clickedTerms = listOfSortedJobs[indexPath.row].terms
        self.clickedPrice = listOfSortedJobs[indexPath.row].price
        self.clickedJobKeyID = listOfSortedJobs[indexPath.row].jobKeyID
        self.clickedEmployerID = listOfSortedJobs[indexPath.row].employerID
        self.clickedEmployeeID = listOfSortedJobs[indexPath.row].employeeID
        
        self.performSegue(withIdentifier: "toViewJob", sender: nil)
        //send this id to the next viewProfileController
        }
    }
    
    func sendFlagToPreviousVC(flag: Int) {
        //exceute on return back
        if flag == 1{
            self.dismiss(animated: true, completion: nil)
        }
        print("ADAI" + String(flag))
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
