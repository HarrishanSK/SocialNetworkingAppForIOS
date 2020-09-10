//
//  updateEmployerController.swift
//  employ
//
//  Created by Harrishan Sureshkumar on 12/04/2018.
//  Copyright © 2018 Harrishan Sureshkumar. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class updateProfileController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var businessName: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var postcodeField: UITextField!
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var confirmSlider: UISwitch!
    @IBOutlet weak var confirmLabel: UILabel!

    @IBOutlet weak var pickerView: UIPickerView!
    var imagePicker: UIImagePickerController!
    
    
    var jobPickerData = ["",""]
    var jobCat = ""
    var userTypeG = ""
    var employeeTypeG = ""
    
    var alertController: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect data for job picker View:
        pickerView.delegate = self
        pickerView.dataSource = self
        
        self.confirmSlider.setOn(false, animated:true)
        
        //Connect data for image
        self.imagePicker = UIImagePickerController()
        self.imagePicker.allowsEditing = true
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
        //round image
        let x = 3
        self.changePhotoButton.layer.cornerRadius = CGFloat(x)
        self.changePhotoButton.clipsToBounds = true
        self.userImageView.layer.cornerRadius = CGFloat(x)
        self.userImageView.clipsToBounds = true
        
        self.nameField.delegate = self
        self.businessName.delegate = self
        self.descriptionField.delegate = self
        self.numberField.delegate = self
        self.locationField.delegate = self
        self.postcodeField.delegate = self
        
        self.updateButton.isEnabled = false
        
        self.loadUser()
        
        // Do any additional setup after loading the view.
    }

    func loadUser()
    {
        //Check userType
         //load common data
            //if employee
                //hide pickerView
                //hide businessField
        
            //if employer
                //load pickerView
                //load businessNameField
        
        if let uid = KeychainWrapper.standard.string(forKey: "uid"){
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value){ (snapshot) in
                if let child = snapshot.value as? [String : AnyObject]{
                    
                     let userType = child["userType"] as! String
                    
                      //load common data
                      let currentUserImageURL = child["userImg"] as! String
                      self.loadUserImage(currentUserImageUrl: currentUserImageURL)
                      self.nameField.text = child["name"] as! String
                      self.descriptionField.text = child["description"] as! String
                      self.numberField.text = child["number"] as! String
                      self.locationField.text = child["location"] as! String
                      self.postcodeField.text = child["postcode"] as! String
                    

                      self.userTypeG = userType //set user type globally
                    
                        if userType == "Employer"
                        {
                            
                            self.businessName.isHidden = true// hide business field
                            self.pickerView.isHidden = true// hide picker view
                        }
                        else if userType == "Employee"{
                            let employeeType = child["EmployeeType"] as! String
                            self.employeeTypeG = employeeType // set employeeType globally
                            if employeeType == "Business"
                            {
                            self.businessName.text = child["BusinessName"] as! String
                            }
                            else if employeeType == "Freelancer"
                            {
                                self.businessName.isHidden = true// hide business field
                            }
                            
                            self.jobCat = child["jobCategory"] as! String
                             self.jobPickerData = [self.jobCat,"Accountant","Actor", "Artist", "Architect", "App Developer","Assistant", "Baby Sitter", "Builder", "Caterer", "Caretaker", "Cleaner","Chef","Driver","Dentist","Doctor","Electrician","Engineer","Exterminator","Fashion Designer", "Florist", "Gardener","Graphic Designer", "Handyman", "Hairdresser","Masseuse", "Mechanic", "Makeup Artist", "Musician", "Nurse", "Painter", "Personal Trainer", "Personal Shopper", "Plumber", "Photographer", "Party Planner", "Software Engineer","Tattoo Artist", "Technician", "Tech Specialist", "Therapist", "Translator", "Tutor","Watch Specialist", "Window Cleaner", "Writer"] //44
                            self.pickerView.reloadAllComponents()
                            
                            
                        }
                    
                    
                }
            }
        }
        
        
    }
    
    func loadUserImage(currentUserImageUrl : String)
    {
        let httpsReference = Storage.storage().reference(forURL: currentUserImageUrl)
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        httpsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                self.userImageView.image = image
            }
        }
    }
    
    @IBAction func updateClicked(_sender: AnyObject)
    {
        updateUserDB()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backClicked(_sender: AnyObject)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func passwordReset()
    {
        if let uid = KeychainWrapper.standard.string(forKey: "uid"){
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value){ (snapshot) in
                if let child = snapshot.value as? [String : AnyObject]{
                    let email = child["email"] as! String //gets email of user
                    Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                                // ... //send reset link to email
                    }
                }
            }
        }

    }
    
    func updateUserDB(){
        
        if let userID = KeychainWrapper.standard.string(forKey: "uid"){
            
            //load image
            if let imageData = UIImageJPEGRepresentation(self.userImageView.image!, 0.2){//image quality 0.2
                let imgUid = NSUUID().uuidString
                let metaData = StorageMetadata()
                Storage.storage().reference().child(imgUid).putData(imageData, metadata: metaData) { (metadata, error) in //load image from cloud storage
                    guard let metadata = metadata else{
                        //An error occurred
                        return
                    }
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    let downloadURL = metadata.downloadURL()?.absoluteString
                
                    //This above code basically stores the image in the cloud and creates a reference url which is used to access that image. This url is stored with the user.
              //image loaded
                    
                    //if employee with business
                    if self.userTypeG == "Employee"
                    {
                        if self.employeeTypeG == "Business"
                        {
                            var businessName = "Business"
                            businessName = self.businessName.text!
                            let userBusinessData = [
                                "name": self.nameField.text,
                                "BusinessName": businessName,
                                "jobCategory": self.jobCat,
                                "description": self.descriptionField.text!,
                                "userImg": downloadURL!, //url to storage in firebase
                                "number": self.numberField.text!,
                                "location": self.locationField.text!,
                                "postcode": self.postcodeField.text!.uppercased()
                                ] as [String: Any] //
                            
                            Database.database().reference().child("users").child(userID).updateChildValues(userBusinessData)//store business employee's data to database
                        }
                        //if employee is freelancer
                        else if self.employeeTypeG == "Freelancer"
                        {
                            let userFreelancerData = [
                                "name": self.nameField.text!,
                                "jobCategory": self.jobCat,
                                "description": self.descriptionField.text!,
                                "userImg": downloadURL!, //url to storage in firebase
                                "number": self.numberField.text!,
                                "location": self.locationField.text!,
                                "postcode": self.postcodeField.text!.uppercased()
                                ] as [String: Any] //
                            
                             Database.database().reference().child("users").child(userID).updateChildValues(userFreelancerData)//store freelancers data to database
                         }
                        
                
                        
                    }
                        
                        //if employer
                else if self.userTypeG == "Employer"
                {
                    let userEmployerData = [
                        "name" : self.nameField.text!,
                        "description": self.descriptionField.text!,
                        "userImg": downloadURL!, //url to storage in firebase
                        "number": self.numberField.text!,
                        "location": self.locationField.text!,
                        "postcode": self.postcodeField.text!.uppercased()
                        ] as [String: Any] //
                    
                    Database.database().reference().child("users").child(userID).updateChildValues(userEmployerData)//store employers data to database
                }
                    
        
            
            }//updated user
          }
        }//end of request for image
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
        self.jobCat = jobPickerData[row]
        //jobPickLabel.text = jobPickerData[row]
    }
    
    @IBAction func photoButtonClicked(_sender: AnyObject){//add photo button clicked
        present(imagePicker, animated: true, completion: nil)
        self.changePhotoButton.setTitle("", for: .normal)
        
        
    }
    
    @IBAction func passwordResetClicked(_sender: AnyObject){
        showPasswordAlertBox()
        }

    @IBAction func confirmSliderClicked(_ sender: Any) {
        if self.confirmSlider.isOn {
            // emailField.isUserInteractionEnabled = false
            
            var checkFlag = 0;// flag that checks if all boxes are filled
            
            //A WAY TO DETECT IMAGE UPLOAD
            //check if image uploaded
           /* if self.userImageView.image == #imageLiteral(resourceName: "icons8-contacts-50.png")
            {
                //image wasnt changed
                //set flag
                allFilledFlag = 1
            }*/
            
            if (self.nameField.text?.isEmpty)! { checkFlag = 1 }
            if (self.numberField.text?.isEmpty)! { checkFlag = 1 }
            if (self.postcodeField.text?.isEmpty)! { checkFlag = 1 }
            if (self.locationField.text?.isEmpty)! { checkFlag = 1 }
            //if (self.descriptionField.text?.isEmpty)! { allFilledFlag = 1 }

         
            if( checkFlag == 0){
                //disable all textboxes for editing
                self.businessName.isEnabled = false
                self.nameField.isEnabled = false
                self.numberField.isEnabled = false
                self.postcodeField.isEnabled = false
                self.descriptionField.isEnabled = false
                self.locationField.isEnabled = false
                self.changePhotoButton.isEnabled = false
                
                //make signup button visible...
                self.updateButton.isEnabled = true
                confirmLabel.text = "Confirm that the above details are true. (Turn off to edit above fields)."
                
            }//check flag end
            else{
                //make sign up button invisible...
                self.updateButton.isEnabled = false
                self.confirmSlider.isOn = false
                self.confirmLabel.text = "Confirm that the above details are true."
                self.showAlertBox(titleStr: "Complete the Form", messageStr: "Please complete all required fields, make sure to include a photo for security reasons and check to see if your passwords match.")
            }
        }
        else{
            //enable all fields for editing
            self.updateButton.isEnabled = true
            self.nameField.isEnabled = true
            self.numberField.isEnabled = true
            self.postcodeField.isEnabled = true
            self.descriptionField.isEnabled = true
            self.locationField.isEnabled = true
            self.changePhotoButton.isEnabled = true
            self.confirmLabel.text = "Confirm that the above details are true."
            
            //make sign up button invisible...
            self.updateButton.isEnabled = false
            
        }
        
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
    
    //hide when return clicked
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textField.resignFirstResponder()
        // return (true)
        if textField == businessName{
            nameField.becomeFirstResponder()
        }
        else if textField == nameField{
            
            descriptionField.resignFirstResponder()
        }
        else if textField == descriptionField{
            
            numberField.resignFirstResponder()
        }
        else if textField == numberField{

            locationField.resignFirstResponder()
        }
        else if textField == locationField{
       
            postcodeField.resignFirstResponder()
        }
        
        return true
    }
    
    func showPasswordAlertBox(){
        
        self.alertController = UIAlertController(title: "Reset Password?", message: "Are you sure you want to reset your password? A reset link will be sent to your email account.", preferredStyle: UIAlertControllerStyle.alert)
        
        self.alertController?.addAction(UIAlertAction(title: "Send Link", style: .default, handler: { (action: UIAlertAction!) in
            self.passwordReset()
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        self.alertController?.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("CANCELLED")
        }))
        present((self.alertController)! , animated: true, completion: nil)
    }
    
    
    //Hide the key board when tapped outside textfield
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
extension updateProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
