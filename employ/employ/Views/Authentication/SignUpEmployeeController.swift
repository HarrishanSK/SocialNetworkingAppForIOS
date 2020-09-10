//
//  SignUpEmployeeViewController.swift
//  employ
//
//  Created by Harrishan Sureshkumar on 18/01/2018.
//  Copyright © 2018 Harrishan Sureshkumar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SwiftKeychainWrapper

class SignUpEmployeeController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{

    

   // @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var postcodeField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var repeatPasswordField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var businessNameField: UITextField!
    
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
        var dob = ""
    @IBOutlet weak var pickerView: UIPickerView! //for job category
    let jobPickerData = ["Pick a Job Category","Accountant","Actor", "Artist", "Architect", "App Developer","Assistant", "Baby Sitter", "Builder", "Caterer", "Caretaker", "Cleaner","Chef","Driver","Dentist","Doctor","Electrician","Engineer","Exterminator","Fashion Designer", "Florist", "Gardener","Graphic Designer", "Handyman", "Hairdresser","Masseuse", "Mechanic", "Makeup Artist", "Musician", "Nurse", "Painter", "Personal Trainer", "Personal Shopper", "Plumber", "Photographer", "Party Planner", "Software Engineer","Tattoo Artist", "Technician", "Tech Specialist", "Therapist", "Translator", "Tutor","Watch Specialist", "Window Cleaner", "Writer"] //44
    var jobCat = ""
    //jobPickLabel
    
    @IBOutlet weak var employeeSlider: UISwitch!
    @IBOutlet weak var confirmSlider: UISwitch!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var addPhotoButton: UIButton!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var confirmLabel: UILabel!
    
    var imagePicker: UIImagePickerController!
    var selectedImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userImageView.image = #imageLiteral(resourceName: "icons8-contacts-50.png") //set image
        signUpButton.isEnabled = false
        
        // Connect data for job picker View:
        pickerView.delegate = self
        pickerView.dataSource = self
        
        //round image
        let x = 3
        self.addPhotoButton.layer.cornerRadius = CGFloat(x)
        self.addPhotoButton.clipsToBounds = true
        self.userImageView.layer.cornerRadius = CGFloat(x)
        self.userImageView.clipsToBounds = true

        //Confirm slider starts off
        confirmSlider.setOn(false, animated:true)
        employeeSlider.setOn(false, animated:true)
        businessNameField.isHidden = true
        
        //Connect data for image
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate

        
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
    
    
    
    
    // The num of columns of data in the picker view
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data in the picker view
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return jobPickerData.count
    }
    
    // Data at (X,Y) col/row passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return jobPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
         jobCat = jobPickerData[row]
         //jobPickLabel.text = jobPickerData[row]
    }
    

    
    func storeFreelancerData(userId: String){
        
        if let imageData = UIImageJPEGRepresentation(self.userImageView.image!, 0.2){//image quality 0.2
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
                
                //dob
                self.datePicker.datePickerMode = UIDatePickerMode.date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let dob = dateFormatter.string(from: self.datePicker.date)
                print(dob)
                
                let userData = [
                    "userType": "Employee",
                    "EmployeeType": "Freelancer",
                    "dob": dob,
                    "jobCategory": self.jobCat,
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
                    ] as [String: Any] //                    "dob": self.dob, "jobCategory": self.jobCat
                Database.database().reference().child("users").child(userId).setValue(userData)  //stores image and username in user's tree in database
                self.performSegue(withIdentifier: "toSuccess", sender: nil)
            }
        }
        else{
            
        }
    }

    func storeImage(userId: String) -> String {
    
        var downloadURL = ""
        if let imageData = UIImageJPEGRepresentation(self.userImageView.image!, 0.2){//image quality 0.2
            let imgUid = NSUUID().uuidString
            //let storage = Storage.storage()
            let metaData = StorageMetadata()
            Storage.storage().reference().child(imgUid).putData(imageData, metadata: metaData) { (metadata, error) in //Store image in cloud storage
                guard let metadata = metadata else{
                    // Uh-oh, an error occurred!
                    return
                }
                
                // Metadata contains file metadata such as size, content-type, and download URL.
                downloadURL = (metadata.downloadURL()?.absoluteString)!
                
                if downloadURL == ""
                {
                    self.showAlertBox(titleStr: "Please upload an image", messageStr: "An image must be uploaded to your profile before continuing. This is to encourage trust between users in the app.")
                }
        
            }
        }

          return downloadURL
    }
    
            
    func storeBusinessData(userId: String){
        
        if let imageData = UIImageJPEGRepresentation(self.userImageView.image!, 0.2){//image quality 0.2
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
                
                //dob
                self.datePicker.datePickerMode = UIDatePickerMode.date
                var dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MM yyyy"
                var dob = dateFormatter.string(from: self.datePicker.date)
                print(dob)
        
        //let downloadURL = storeImage(userId: userId)
                
                let userData = [
                    "userType": "Employee",
                    "EmployeeType": "Business",
                    "BusinessName": self.businessNameField.text!,
                    "dob": dob,
                    "jobCategory": self.jobCat,
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
                    ] as [String: Any] //                    "dob": self.dob, "jobCategory": self.jobCat
                Database.database().reference().child("users").child(userId).setValue(userData)  //stores image and username in user's tree in database
                self.performSegue(withIdentifier: "toSuccess", sender: nil)
            }
        }
    }
    
    @IBAction func datePickerEdited(sender: UIDatePicker) {
        /*
        print("print \(sender.date)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM dd, YYYY"
        self.dob = dateFormatter.string(from: sender.date)
        
        var date = self.datePicker.date
        
        print(date)
        
        */
        
        
        self.datePicker.datePickerMode = UIDatePickerMode.date
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM yyyy"
        var date = dateFormatter.string(from: datePicker.date)
        print(date)
    }
    
    @IBAction func employeeSliderEdited(_sender: Any){
        if employeeSlider.isOn {
            businessNameField.isHidden = false
        }
        else{
            businessNameField.isHidden = true
        }
    }
    
    
    @IBAction func confirm(_ sender: Any) {
        if self.confirmSlider.isOn {
            confirmLabel.text = "Confirm that the above details are true. (Turn off to enable editing)"
            // emailField.isUserInteractionEnabled = false
           // print(self.dob)
            print(self.jobCat)
            
            
            
            
            //dob
            self.datePicker.datePickerMode = UIDatePickerMode.date
            var dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MM yyyy"
            var dob = dateFormatter.string(from: self.datePicker.date)
            print(dob)
            
            
            
            
            
            
            
            
            var allFilledFlag = 0;// flag that checks if all boxes are filled
            
            //A WAY TO DETECT IMAGE UPLOAD
            //check if image uploaded
            if self.userImageView.image == #imageLiteral(resourceName: "icons8-contacts-50.png")
            {
                //image wasnt changed
                //set flag
                allFilledFlag = 1
            }
            
           // if (self.addPhotoButton.titleLabel?.text != "") { allFilledFlag = 1}
            if (self.nameField.text?.isEmpty)! { allFilledFlag = 1 }
            if (self.emailField.text?.isEmpty)! { allFilledFlag = 1 }
            if (self.numberField.text?.isEmpty)! { allFilledFlag = 1 }
            if (self.postcodeField.text?.isEmpty)! { allFilledFlag = 1 }
            //if (self.descriptionField.text?.isEmpty)! { allFilledFlag = 1 }
            if ((self.passwordField.text?.isEmpty)! || ((self.passwordField.text?.count)! < 6) ) { allFilledFlag = 1 }
            if (self.locationField.text?.isEmpty)! { allFilledFlag = 1 }
            if (self.repeatPasswordField.text?.isEmpty)! { allFilledFlag = 1 }
            if (self.jobCat == "Pick a Job Category" || self.jobCat == "") { allFilledFlag = 1 }
            
            if employeeSlider.isOn {
                if (self.businessNameField.text?.isEmpty)! { allFilledFlag = 1 }
            }
            var passwordFlag = 0;//flag that checks passwords are the same
            
            if self.passwordField.text != self.repeatPasswordField.text { passwordFlag = 1}
            
            let checkFlag = allFilledFlag + passwordFlag
            //if checkFlag is > 0 then error in fields above
            
            
            if( checkFlag == 0){
                //disable all textboxes for editing
                nameField.isEnabled = false
                businessNameField.isEnabled = false
                emailField.isEnabled = false
                numberField.isEnabled = false
                postcodeField.isEnabled = false
                descriptionField.isEnabled = false
                passwordField.isEnabled = false
                locationField.isEnabled = false
                repeatPasswordField.isEnabled = false
                employeeSlider.isEnabled = false
                datePicker.isEnabled = false
                pickerView.isHidden = true
                addPhotoButton.isEnabled = false
                
                //make signup button enabled...
                self.signUpButton.isEnabled = true
                
                

            }
            else{
                //make sign up button disabled...
                self.signUpButton.isEnabled = false
                self.confirmSlider.isOn = false
                confirmLabel.text = "Confirm that the above details are true."
                showAlertBox(titleStr: "Complete the Form", messageStr: "Please complete all required fields, make sure to include a photo for security reasons, check to see if your passwords match and that your password is greater than 5 characters.")
            }
        }
        else{//if slider off
            //make sign up button invisible and everything else editable...
            self.signUpButton.isEnabled = true
            nameField.isEnabled = true
            businessNameField.isEnabled = true
            emailField.isEnabled = true
            numberField.isEnabled = true
            postcodeField.isEnabled = true
            descriptionField.isEnabled = true
            passwordField.isEnabled = true
            locationField.isEnabled = true
            repeatPasswordField.isEnabled = true
            employeeSlider.isEnabled = true
            datePicker.isEnabled = true
            pickerView.isHidden = false
            addPhotoButton.isEnabled = true
            
            confirmLabel.text = "Confirm that the above details are true."
            
            self.signUpButton.isEnabled = false
        }
    }
    
    
    @IBAction func signUpPressed(_ sender: Any){ //when sign up button pressed
        
        self.loadingLabel.text = "Loading..."
        
        if let email = emailField.text, let password = passwordField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if error != nil {//if user doesnt exist
                    
                    //create account in authentication
                    Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                        
                        if self.employeeSlider.isOn {
                            self.storeBusinessData(userId : (user?.uid)!) //calls method above with is, -passes user id of the user to the func
                            //KeychainWrapper.standard.set((user?.uid)!, forKey: "uid")
                        }
                        else{
                            self.storeFreelancerData(userId : (user?.uid)!) //calls method above with is, -passes user id of the user to the func
                            
                        }
                        //self.storeUserData(userId : (user?.uid)!) //calls method above with is, -passes user id of the user to the func
                        KeychainWrapper.standard.set((user?.uid)!, forKey: "uid")
                        // self.performSegue(withIdentifier: "toSuccess", sender: nil)
                    }
                }
                else{
                    //if let userId = user?.uid{ //if user doesnt have a userid if then dont store the variable
                   //     KeychainWrapper.standard.set((userId), forKey: "uid")
                        // self.performSegue(withIdentifier: "toSuccess", sender: nil)
                        self.showAlertBox(titleStr: "User exists", messageStr: "Someone has already used this email to sign up!")
                        self.loadingLabel.text = "Unlock the slider and try again with another email address OR use the forgot my password feature to get a password reset link emailed to you."
                   // }
                }
            }
        }
        
       // self.performSegue(withIdentifier: "toSuccess", sender: nil)
        
    }
    
    @IBAction func addPhoto(_sender: AnyObject){//add photo button clicked
        present(imagePicker, animated: true, completion: nil)
        self.addPhotoButton.setTitle("", for: .normal)
        
        
    }
    
    @IBAction func backClicked(_sender: AnyObject){// back button
        self.performSegue(withIdentifier: "back", sender: nil)
          //self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func numberEdited(_sender: AnyObject)
    {
        showAlertBox(titleStr: "Check Number!", messageStr: "Make sure the phone number you entered is valid otherwise your profile will limit functionalities within the app.")
    }
    
    @IBAction func postcodeEdited(_sender: AnyObject)
    {
        showAlertBox(titleStr: "Check Postcode!", messageStr: "Make sure the postcode you entered is valid otherwise your profile will not be accessible by other users and this will limit other functionalities within the app aswell.")
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
    
    //Hide the key board when tapped outside textfield
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

}

extension SignUpEmployeeController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
