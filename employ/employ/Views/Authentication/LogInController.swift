//
//  ViewController.swift
//  employ
//
//  Created by Harrishan Sureshkumar on 02/01/2018.
//  Copyright © 2018 Harrishan Sureshkumar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SwiftKeychainWrapper


class LogInController: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var loginSucceeded = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ =  KeychainWrapper.standard.object(forKey: "KEY_UID")
        {
            self.performSegue(withIdentifier: "toFeed", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    @IBAction func signInPressed(_ sender:
        Any){
        if let email = emailField.text, let password = passwordField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if error != nil {//if user doesnt exist
                    self.loginSucceeded = false
                    self.shouldPerformSegue(withIdentifier: "toFeed", sender: nil)
                    self.showAlertBox(titleStr: "Your login details are incorrect or your device is not connected to the internet.", messageStr: "")
                }
                else{
                    if let userId = user?.uid{ //if user doesnt have a user id then dont store the variable
                     KeychainWrapper.standard.set((userId), forKey: "uid")
                     self.loginSucceeded = true
                        if self.shouldPerformSegue(withIdentifier: "toFeed", sender: nil) == true{
                            self.performSegue(withIdentifier: "toFeed", sender: nil) //logs in and takes user to their feed
                        }
                        
                    }
                }
            }
        }
     }
    

    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let id = identifier {
            if id == "toFeed" {
                if self.loginSucceeded != true {
                    return false
                }
            }
        }
        return true
    }


    @IBAction func forgotClicked(_sender: AnyObject){
        self.performSegue(withIdentifier: "toForgotYourPasswordPage", sender: nil)
    }
    
    @IBAction func signUpClicked(_sender: AnyObject){
        self.performSegue(withIdentifier: "toPickUserType", sender: nil)
    }
    
    //toForgotYourPasswordPage
    
    //Hide the key board when tapped outside textfield
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    //hide when return clicked
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textField.resignFirstResponder()
       // return (true)
        if textField == emailField{
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField{
            //emailField.becomeFirstResponder()
            passwordField.resignFirstResponder()
        }
        return true
    }

    
    
}


