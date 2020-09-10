//
//  PickUserTypeController.swift
//  employ
//
//  Created by Harrishan Sureshkumar on 17/01/2018.
//  Copyright © 2018 Harrishan Sureshkumar. All rights reserved.
//

import UIKit

class PickUserTypeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func employeeClicked(_sender: AnyObject){
        self.performSegue(withIdentifier: "toEmployeeSignUpPage", sender: nil)
    }
    
    @IBAction func employerClicked(_sender: AnyObject){
        self.performSegue(withIdentifier: "toEmployerSignUpPage", sender: nil)
    }
    
    @IBAction func backClicked(_sender: AnyObject){
        self.performSegue(withIdentifier: "back", sender: nil)
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
