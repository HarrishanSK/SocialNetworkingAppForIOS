//
//  ForgotPasswordViewController.swift
//  employ
//
//  Created by Harrishan Sureshkumar on 18/01/2018.
//  Copyright © 2018 Harrishan Sureshkumar. All rights reserved.
//

import UIKit
import Firebase


class ForgotPasswordController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var repeatEmailField: UITextField!
        var alertController: UIAlertController?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    @IBAction func resetPressed(_ sender: Any){ //when reset button pressed
        
        if self.emailField.text != self.repeatEmailField.text {
            self.showAlertBox(titleStr: "The information you entered is incorrect.", messageStr: "")
        }
        else{
        
        showPasswordAlertBox()
        }


        self.performSegue(withIdentifier: "back", sender: nil)
    }
    @IBAction func backClicked(_sender: AnyObject){// back button
        self.performSegue(withIdentifier: "back", sender: nil)
    }
    
    //Hide the key board when tapped outside textfield
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    //hide when return clicked
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func showPasswordAlertBox(){
        
        self.alertController = UIAlertController(title: "Reset Password?", message: "Are you sure you want to reset your password? A reset link will be sent to your email account.", preferredStyle: UIAlertControllerStyle.alert)
        
        self.alertController?.addAction(UIAlertAction(title: "Send Link", style: .default, handler: { (action: UIAlertAction!) in
            
            
                let email = self.emailField.text
                Auth.auth().sendPasswordReset(withEmail: email!) { (error) in
                     if error != nil {//if user doesnt exist
                        self.showAlertBox(titleStr: "User Doesnt Exist", messageStr: "")
                    }
                     else{
                        self.dismiss(animated: true, completion: nil)
                    }
                }

            
        }))
        
        self.alertController?.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("CANCELLED")
        }))
        present((self.alertController)! , animated: true, completion: nil)
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
