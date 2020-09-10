//
//  SignUpController.swift
//  employ
//
//  Created by Harrishan Sureshkumar on 02/01/2018.
//  Copyright © 2018 Harrishan Sureshkumar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SwiftKeychainWrapper


class SignUpEmployerController: UIViewController {
    
  //  @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var postcodeField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var repeatPasswordField: UITextField!
   // @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var descriptionField: UITextField!
    
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var confirmSlider: UISwitch!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var addPhotoButton: UIButton!
    
    @IBOutlet weak var confirmLabel: UILabel!
    var imagePicker: UIImagePickerController!
    //var textView = UITextView()
    var selectedImage: UIImage!
    
    @IBOutlet weak var userImageView: UIImageView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userImageView.image = #imageLiteral(resourceName: "icons8-contacts-50.png") //set image
        
        //round image
        let x = 3
        self.addPhotoButton.layer.cornerRadius = CGFloat(x)
        self.addPhotoButton.clipsToBounds = true
        self.userImageView.layer.cornerRadius = CGFloat(x)
        self.userImageView.clipsToBounds = true
        
        signUpButton.isEnabled = false
        confirmSlider.setOn(false, animated:true)
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        //textView = UITextView()
       // descriptionView.delegate = self as? UITextViewDelegate
        
       // descriptionView.text = "Description"
        //descriptionView.textColor = UIColor.lightGray
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ =  KeychainWrapper.standard.object(forKey: "KEY_UID")
        {
            self.performSegue(withIdentifier: "toSuccess", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func storeUserData(userId: String){
        
        if let imageData = UIImageJPEGRepresentation(self.userImageView.image!, 0.2){
            let imgUid = NSUUID().uuidString
            //let storage = Storage.storage()
            let metaData = StorageMetadata()
            Storage.storage().reference().child(imgUid).putData(imageData, metadata: metaData) { (metadata, error) in //Store image in cloud storage
                guard let metadata = metadata else{
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata.downloadURL()?.absoluteString
                
                let userData = [
                    "userType": "Employer",
                    "name" : self.nameField.text!,
                    "email": self.emailField.text!,
                    "description": self.descriptionField.text!,
                    "userImg": downloadURL!, //url to storage in firebase
                    "number": self.numberField.text!,
                    "password": self.passwordField.text!,
                    "location": self.locationField.text!,
                    "feedbackScore": 0.0,
                    "totalNumJobs": 0.0,
                    "postcode": self.postcodeField.text!.uppercased()
                    ] as [String: Any]
                
                Database.database().reference().child("users").child(userId).setValue(userData)  //stores image and username in user's tree in database
                self.performSegue(withIdentifier: "toSuccess", sender: nil)
            }
        }
    }
    

    @IBAction func passwordDown(_ sender: Any) {
       // var passwordFlag = 0;
        if passwordField.text == repeatPasswordField.text {
        //    passwordFlag = 1
            
            //make signup button visible...
            signUpButton.isEnabled = true
      }
    }
    
    @IBAction func confirm(_ sender: Any) {
        if confirmSlider.isOn {
           // emailField.isUserInteractionEnabled = false
            
        var allFilledFlag = 0;// flag that checks if all boxes are filled
            
            //A WAY TO DETECT IMAGE UPLOAD
            //check if image uploaded
            if self.userImageView.image == #imageLiteral(resourceName: "icons8-contacts-50.png")
            {
                //image wasnt changed
                //set flag
                allFilledFlag = 1
            }
        
        if (self.nameField.text?.isEmpty)! { allFilledFlag = 1 }
        if (self.emailField.text?.isEmpty)! { allFilledFlag = 1 }
        if (self.numberField.text?.isEmpty)! { allFilledFlag = 1 }
        if (self.postcodeField.text?.isEmpty)! { allFilledFlag = 1 }
        if (self.locationField.text?.isEmpty)! { allFilledFlag = 1 }
        //if (self.descriptionField.text?.isEmpty)! { allFilledFlag = 1 }
        if ((self.passwordField.text?.isEmpty)! || ((self.passwordField.text?.count)! < 6) ) { allFilledFlag = 1 }
        if (self.repeatPasswordField.text?.isEmpty)! { allFilledFlag = 1 }
        
        var passwordFlag = 0;//flag that checks passwords are the same
        
        if passwordField.text != repeatPasswordField.text { passwordFlag = 1}
        
        let checkFlag = allFilledFlag + passwordFlag
        //if checkFlag is > 0 then error in fields above
        
        
        if( checkFlag == 0){
            //disable all textboxes for editing
            nameField.isEnabled = false
            emailField.isEnabled = false
            numberField.isEnabled = false
            postcodeField.isEnabled = false
            descriptionField.isEnabled = false
            passwordField.isEnabled = false
            locationField.isEnabled = false
            repeatPasswordField.isEnabled = false
            addPhotoButton.isEnabled = false
            
            //make signup button visible...
            self.signUpButton.isEnabled = true
            confirmLabel.text = "Confirm that the above details are true. (Turn off to edit above fields)."
          
            }//check flag end
            else{
                //make sign up button invisible...
                signUpButton.isEnabled = false
            self.confirmSlider.isOn = false
            confirmLabel.text = "Confirm that the above details are true."
            showAlertBox(titleStr: "Complete the Form", messageStr: "Please complete all required fields, make sure to include a photo for security reasons, check to see if your passwords match and that your password is greater than 5 characters.")
            }
        }
        else{
            //enable all fields for editing
            self.signUpButton.isEnabled = true
            nameField.isEnabled = true
            emailField.isEnabled = true
            numberField.isEnabled = true
            postcodeField.isEnabled = true
            descriptionField.isEnabled = true
            passwordField.isEnabled = true
            locationField.isEnabled = true
            repeatPasswordField.isEnabled = true
            addPhotoButton.isEnabled = true
            
            confirmLabel.text = "Confirm that the above details are true."
            
            //make sign up button invisible...
            signUpButton.isEnabled = false

        }
    }
    
    
    @IBAction func signUpPressed(_ sender: Any){ //when sign up button pressed
        self.loadingLabel.text = "Loading..."
        if let email = emailField.text, let password = passwordField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if error != nil {//if user doesnt exist
                    
                    //create account
                    Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                        
                        self.storeUserData(userId : (user?.uid)!) //calls method above with is, -passes user id of the user to the func
                        KeychainWrapper.standard.set((user?.uid)!, forKey: "uid")// set users uid in keychain wrapper
                        //show a loading sign
                        // self.performSegue(withIdentifier: "toSuccess", sender: nil)
                    }
                }
                else{
                  //  if let userId = user?.uid{ //if user doesnt have a userid if then dont store the variable
                   //     KeychainWrapper.standard.set((userId), forKey: "uid")
                        // self.performSegue(withIdentifier: "toSuccess", sender: nil)
                     self.showAlertBox(titleStr: "User exists", messageStr: "Someone has already used this email to sign up!")
                    self.loadingLabel.text = "Unlock the slider and try again with another email address OR use the forgot my password feature to get a password reset link emailed to you."
                   // }
                }
            }
        }
        
     //   self.performSegue(withIdentifier: "toSuccess", sender: nil)

    }
    
    @IBAction func postcodeEdited(_sender: AnyObject)
    {
        showAlertBox(titleStr: "Check Postcode!", messageStr: "Make sure the postcode you entered is valid otherwise your profile will not be accessible by other users and this will limit other functionalities within the app aswell.")
    }
    
    @IBAction func numberEdited(_sender: AnyObject)
    {
        showAlertBox(titleStr: "Check Number!", messageStr: "Make sure the phone number you entered is valid otherwise your profile will limit functionalities within the app.")
    }
    
    @IBAction func addPhoto(_sender: AnyObject){//add photo button clicked
        present(imagePicker, animated: true, completion: nil)
        addPhotoButton.setTitle("", for: .normal)
        
        
    }
    
    @IBAction func backClicked(_sender: AnyObject){// back button
        self.performSegue(withIdentifier: "back", sender: nil)
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
    /*
    @IBAction func descriptionViewComplete(_ textView: UITextView){
        if self.descriptionView.text.isEmpty {
            self.descriptionView.text = "Description"
            self.descriptionView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func descriptionViewStartEditing(_ textView: UITextView){
        if self.descriptionView.textColor == UIColor.lightGray {
            self.descriptionView.text = nil
           self.descriptionView.textColor = UIColor.black
        }
    }
 */
    

    
}

extension SignUpEmployerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            userImageView.image = image
        }
        else{
            print("Image wasnt selected")
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}


