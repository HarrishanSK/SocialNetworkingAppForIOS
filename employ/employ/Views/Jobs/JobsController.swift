//
//  JobController.swift
//  employ
//
//  Created by Harrishan Sureshkumar on 09/04/2018.
//  Copyright © 2018 Harrishan Sureshkumar. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class JobsController: UIViewController {

    var type = "pending"
    @IBOutlet weak var pendingView: UILabel!
    @IBOutlet weak var acceptedView: UILabel!
    @IBOutlet weak var paidView: UILabel!
    @IBOutlet weak var completedView: UILabel!
    
    @IBOutlet weak var pendingButton: UIButton!
    @IBOutlet weak var acceptedButton: UIButton!
    @IBOutlet weak var paidButton: UIButton!
    @IBOutlet weak var completedButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var historyIconButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtons()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        countTypes()
    }
    
    func setButtons()
    {
        var x = 7.0
        self.pendingButton.layer.cornerRadius = CGFloat(x)
        self.pendingButton.clipsToBounds = true
        self.pendingView.layer.cornerRadius = CGFloat(x)
        self.pendingView.clipsToBounds = true
        
        self.acceptedButton.layer.cornerRadius = CGFloat(x)
        self.acceptedButton.clipsToBounds = true
        self.acceptedView.layer.cornerRadius = CGFloat(x)
        self.acceptedView.clipsToBounds = true
        
        self.paidButton.layer.cornerRadius = CGFloat(x)
        self.paidButton.clipsToBounds = true
        self.paidView.layer.cornerRadius = CGFloat(x)
        self.paidView.clipsToBounds = true
        
        self.completedButton.layer.cornerRadius = CGFloat(x)
        self.completedButton.clipsToBounds = true
        self.completedView.layer.cornerRadius = CGFloat(x)
        self.completedView.clipsToBounds = true
        
        self.historyButton.layer.cornerRadius = CGFloat(x)
        self.historyButton.clipsToBounds = true
        self.historyIconButton.layer.cornerRadius = CGFloat(x)
        self.historyIconButton.clipsToBounds = true
        
    }
    


    func countTypes(){
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
                var totalJobsInProgress = pending + accepted + paid + completed
                //update boxes
                self.pendingView.text = String(pending)
                self.acceptedView.text = String(accepted)
                self.paidView.text = String(paid)
                self.completedView.text = String(completed)
                //history?
                
            }
        }
        )
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pendingClicked(_sender: AnyObject){
        self.type = "pending"
        self.performSegue(withIdentifier: "toJobTable", sender: nil)
    }
    
    @IBAction func acceptedClicked(_sender: AnyObject){
        self.type = "accepted"
        self.performSegue(withIdentifier: "toJobTable", sender: nil)
    }
    
    @IBAction func paidClicked(_sender: AnyObject){
        self.type = "paid"
        self.performSegue(withIdentifier: "toJobTable", sender: nil)
    }
    
    
    @IBAction func completedClicked(_sender: AnyObject){
        self.type = "completed"
        self.performSegue(withIdentifier: "toJobTable", sender: nil)
    }
    
    @IBAction func historyClicked(_sender: AnyObject){
        self.type = "history"
        self.performSegue(withIdentifier: "toJobTable", sender: nil)
    }
    
    @IBAction func helpClicked(_sender: AnyObject){
        showAlertBox(titleStr: "Help?", messageStr:"A job goes through 4 stages. \n \n 1)Pending: The job starts off as pending when an Employer has sent a job request to an Employee \n \n 2)Accepted: When the Employee accepts the job its status changes to 'Accepted'\n \n 3)Paid: When the Job is done, the Employer must pay the employee and confirm payment. \n \n 4) The Employee then checks that payment is recieved and clicks confirm at which point the job status is 'Completed'. \n \n Both users can then give feedback for the jobs in the completed section at which point the job is transfered to the user's job history." )
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
    
    //prepare for job table request page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let jobTableVC = segue.destination as! jobsTableController
        jobTableVC.type = self.type
    }
    //end - prepare for job tabke request page

}
