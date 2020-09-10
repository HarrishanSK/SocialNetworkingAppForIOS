//
//  SearchController.swift
//  employ
//
//  Created by Harrishan Sureshkumar on 07/02/2018.
//  Copyright © 2018 Harrishan Sureshkumar. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase
import Alamofire


class SearchController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITabBarDelegate {
    
    //GOOGLE MAPS API KEY = AIzaSyCbtyQZcIPMg8qttGQgYNDZ1hnntyND40w //------------
    //example https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=W55AL,England&destinations=TW32PB,England&key=AIzaSyCbtyQZcIPMg8qttGQgYNDZ1hnntyND40w
    
   // @IBOutlet weak var searchTableView: UITableView!
   // @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
   // @IBOutlet weak var searchBar: UITextField!
    var searchTerm = ""
    var userArray = [String]()
    var jobArray = [String]()
    var locationArray = [String]()
    
   // var postcode1 = "tw1 1bl"
    @IBOutlet weak var tabBar: UITabBar!
    //var postcode2 = "e1 4gh
    var myPostcode = "w55al"
    //self.listOfMembers.append(listMember(name: name, jobCategory: jc!, location: location!, distance: distG, duration: durG))//
    
    var catchFireFlag = 0
    var testArray = ["Hi", "What", "the", "hell", "happen"] //works
    var egImage : UIImage!
    var imageArray: [UIImage] = []
    var listOfMembers = [listMember]()
    var listOfSortedMembers = [listMember]()
    var distanceTimeArray = [DistanceTime]() // Stores an array of Distance/Time values for list of members
    var distanceTimeIndex = 0;
    var listSize = 0;
    
    var durationGlobal = globalVariables.durationGlobal
    var distanceGlobal = globalVariables.distanceGlobal
   // var ret = ["please","help"]
    var JSONutf8GLOBAL = ""
    var waitFlag = 0;
    var wait = 0
    var ret = ["distance","duration"]
    var childId = ""
    var requestCount = 0
    
    var myType = ""
    
    @IBOutlet weak var advancedTab: UITabBarItem!
    @IBOutlet weak var nameTab: UITabBarItem!
    var tabPointer = 0
    @IBOutlet weak var tabReplaceLabel: UILabel!
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        self.searchBar.delegate = self
        self.tabBar.delegate = self
        self.tabBar.selectedItem = advancedTab
        self.tabReplaceLabel.isHidden = true
        self.tabBar.isHidden = true
        checkUserType()
        getMyPostcode()
        //getMyPostcode
        //var p1 = "W55AL"

        tableView.dataSource = self
        tableView.delegate = self
        //tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: "searchCell")
        //tableView.register(customCell.self, forCellReuseIdentifier: "customCell")
       // self.tableView.register(CustomCell.self, forCellReuseIdentifier: "Cell")
        

        
        //getList()
        // Do any additional setup after loading the view.
       // getDistanceTime(postcode2: "E1 4GG");
      //  getMyPostcode()
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //This method will be called when user changes tab.
        print("tabBar selection")
        print(tabBar.selectedItem )
        if self.tabBar.selectedItem  == advancedTab
        {
            self.tabPointer = 0
        }
        else if self.tabBar.selectedItem  == nameTab{
            self.tabPointer = 1
        }

    }
    
    func getMyPostcode(){
        if let uid = KeychainWrapper.standard.string(forKey: "uid"){
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value){ (snapshot) in
                if let postDict = snapshot.value as? [String : AnyObject]{
                    self.myPostcode = postDict["postcode"] as! String //gets my postcode
                    //self.myPostcode = postcode1
                    print("MY POSTCODE IS == " + self.myPostcode)
                    // p1 = self.myPostcode
                    
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        runSearchEngine()
    }
    
   
    
    struct globalVariables{
        static var durationGlobal = ""
        static var distanceGlobal = ""
    }
    
    struct DistanceTime{
         var distance = ""
        var time = ""
    }
    
    struct listMember{
        var id = ""
        var name = ""
        var jobCategory = ""
        var location = ""
        var distance = ""
        var duration = ""
        var postcode = ""
    }
    
    /* OLD get Distance Time Function
    func getDistanceTime(postcode2: String) //-> [String]
    {
      //for every user in list...get distance/time values...and set them...
        for member in listOfMembers
        {}
        print("MY POSTCODE IS === " + self.myPostcode)
          let postcodeA = self.myPostcode
            .replacingOccurrences(of: " ", with: "", options: .literal, range: nil)//remove spaces in postcode
          let postcodeB = postcode2.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)//remove spaces in postcode
        
          let CUSTOM_URL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins="+postcodeA+",England&destinations="+postcodeB+",England&key=AIzaSyCbtyQZcIPMg8qttGQgYNDZ1hnntyND40w"

        var ret1 = ["distance", "time"]
        var test = "test"
        
        self.wait = 0
       // while(self.wait == 0){
        Alamofire.request(CUSTOM_URL).response { response in
            self.wait = 1
            if response.response?.statusCode == 200
            {
             print("This is a test = " + test)
                test = "test CHANGED IN ALAMO"
                 //
                print("This is a test = " + test)
           // print("Request: \(response.request)")
           // print("Response: \(response.response)")
            print("Error: \(response.error)")
               // let JSONutf8 = String(data: response.data!, encoding: .utf8)
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) // if there is a response...
            {
               
                
                let JSONutf8 = utf8Text
            
                let retDT = self.extractDistanceMatrixJson(JSONutf8: JSONutf8) //ret[distance, time]
                self.distanceTimeArray.append(DistanceTime(distance: retDT[0] , time: retDT[1] ))
                
            self.waitFlag = 1
                print("This is a test INSIDE alamo = " + test + " distance: " + self.ret[0] + "time: " + self.ret[1])
           // dispatch_semaphore_signal(semaphore)
                
                self.listOfMembers[self.distanceTimeIndex].distance = retDT[0]
                self.listOfMembers[self.distanceTimeIndex].duration =  retDT[1]
                //self.tableView.reloadData()
                self.distanceTimeIndex = self.distanceTimeIndex + 1
                print("DISTANCE TIME INDEX IS NOW ===== " + String(self.distanceTimeIndex))
                
                //order the list  DONT WORK BRO
             //   if( self.distanceTimeIndex == self.listSize)
              //  {//time as NSString).doubleValue
                 self.listOfSortedMembers = self.listOfMembers.sorted(by: { ($0.duration as NSString).doubleValue < ($1.duration as NSString).doubleValue })
                 self.tableView.reloadData()
              //  }
                /*
                for member in  self.listOfSortedMembers
                {
                    print("NAME:" + member.name)
                    print("DURATION:" + member.duration)
                    print("DISTANCE:" + member.distance)
                }*/
            
            }
           
            
         }
            // completion() Note to self: Your gonna have to add a "new member to the list" here, this has to be void. dont use globals.
        }
       // waitAlamo()

        
       // self.setup(JSONutf8: self.JSONutf8GLOBAL)
        //var ret = [distanceGlobal, durationGlobal]
       // print(self.distanceGlobal + " BR00000000" + self.durationGlobal)
             print("This is a test outside alamo = " + test + " distance: " + self.ret[0] + "time: " + self.ret[1])
          //  return self.ret
        
    }*/
    
    
    
 func getDistanceTimeNew(listOfMembersLocal: [listMember])
    {
        let dispatch = DispatchGroup()
        var listOfMembersLocal2 = listOfMembersLocal
        //for every user in list...get distance/time values...and set them...
        for member in  0 ..< listOfMembersLocal2.count //for each list member
        {
            dispatch.enter() //synchronized code between disptach enter and leave. Prevents race conditions
            let postcodeB = self.myPostcode
                .replacingOccurrences(of: " ", with: "", options: .literal, range: nil)//remove spaces in postcode
            let postcodeA = listOfMembersLocal2[member].postcode.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)//remove spaces in postcode
            
            let CUSTOM_URL = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins="+postcodeA+",England&destinations="+postcodeB+",England&key=AIzaSyCbtyQZcIPMg8qttGQgYNDZ1hnntyND40w"
            
            Alamofire.request(CUSTOM_URL).response { response in //Send http request

                if response.response?.statusCode == 200
                    //recieve successful http response
                {
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) // if there is response data...
                    {   let JSONutf8 = utf8Text //read in JSON text in utf8 format
                        
                        var retDT = self.extractDistanceMatrixJson(JSONutf8: JSONutf8) //extract JSON
                         listOfMembersLocal2[member].distance = retDT[0]//set distance
                         listOfMembersLocal2[member].duration = retDT[1]//set duration

                        self.listOfSortedMembers = listOfMembersLocal2.sorted(by: { ($0.duration as NSString).doubleValue < ($1.duration as NSString).doubleValue }) //sort current list
                        self.tableView.reloadData()//reload data into table
                     //    }
                    }//end of if there is a response if statement
                }
                dispatch.leave()// end synchronized code block.
            }//END OF ALAMOFIRE REQUEST
        }//end of forloop
    }//end of method
    
    
    
    
    
    
    
    
    
    
    
    
    
    func waitAlamo()
    {
        while(self.waitFlag == 0)
        {
            print("waiting" + String(self.waitFlag))
        }
        //waitFlag = 1
    }
    

    
    func extractDistanceMatrixJson(JSONutf8: String) -> [String]
    {
        var finalDistance = "0.0"
        var finalTime = "0.0"
        var JSONtext = JSONutf8.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)//remove white spaces
        JSONtext = JSONtext.replacingOccurrences(of: "\n", with: "", options: .literal, range: nil)//remove new lines(put it all on one line)
       // print("JSON TEXT without spaces and \n ====== " + JSONtext)
        
        let split1 = ",\"value\":"  //"\"elements\":[{\"distance\":{\"text\":\""
        
        let split2 = "},\"duration\":{"  //,\"value\":0},\"duration\":{\"text\":\""  //"\",\"value\":0},"   //mi\","
        let dArray = JSONtext.components(separatedBy: split1)
       // print("SIZE OF DARRAY IS " + String(describing: dArray.count)) //error test: print size of array
        // print(dArray[1])
        
        if( dArray.count >= 2)
        {
            let d2Array = dArray[1].components(separatedBy: split2)
            if( d2Array.count >= 1)
            {
                let distance = d2Array[0] //distance value in meters from google distance matrix api
                
                //Convert meters to miles and Round the value to 1 decimal place
                var distanceMiles = (distance as NSString).doubleValue * 0.000621371192 //distance converted to miles
                let dpmultiplier = pow(10.0, 1.0) //round to 1dp
                distanceMiles = round(distanceMiles * dpmultiplier) / dpmultiplier
               // distanceMiles = round(distanceMiles)
                
               // print("DISTANCE IS " + String(distanceMiles) + " miles!!!!")
                 finalDistance = String(distanceMiles)
               // self.distanceGlobal  = String(distanceMiles)//sets distance to be added to list for member
                //ret[0] = String(distanceMiles)
               // print("distanceGlobal is equal to ================== " + self.distanceGlobal)
                
                //WORKS!
                
                let split3 = "},\"status\":" //\",\"value\":0},\"" //},\"duration\":{\"text\":\""
                //let split4 = "min"
                if ( dArray.count >= 3)
                {
                    let d3Array = dArray[2].components(separatedBy: split3)
                    // let d4Array = d3Array[1].components(separatedBy: split4)
                    
                    let time = d3Array[0] // stores duration in seconds
                    
                    var timeMins = (time as NSString).doubleValue / 60
                    let dp2multiplier = pow(10.0, 1.0) //round to 1dp
                    timeMins = round(timeMins * dp2multiplier) / dp2multiplier
                    //timeMins = round(timeMins)
                    
                    //print("DURATION ISSSSSSS " + String(timeMins))
                    //ret[1] = String(timeMins)
                     finalTime = String(timeMins)
                   // self.durationGlobal = String(timeMins)  //sets time of duration to be added to list of member
                  //  print("durationGlobal is equal to ================== " + self.durationGlobal)
                    
                    //var ret = [self.distanceGlobal, self.durationGlobal]
                  //  print(self.distanceGlobal + " BRUH" + self.durationGlobal)
                    //return ret
                    // }//Note to self: do the same for time/duration?, then order the the array and put the table cells in order
                }
            }
        }
        let ret = [finalDistance, finalTime]
        return ret
    }
    
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfSortedMembers.count // userArray.count // return size of array e.g list.count
        //return testArray.count
    }
    
   // public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //    return 100 //sets row height
   // }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : SearchTableViewCell
        cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
        

        
        if listOfSortedMembers[indexPath.row].id != "none"{ //none means the list has no values
            cell.userLabel.text = listOfSortedMembers[indexPath.row].name // userArray[indexPath.row]
            cell.jobLabel.text = listOfSortedMembers[indexPath.row].jobCategory  //jobArray[indexPath.row]
            cell.locationLabel.text = listOfSortedMembers[indexPath.row].location  //locationArray[indexPath.row]
            cell.durationLabel.text = listOfSortedMembers[indexPath.row].duration + "mins"
            cell.distanceLabel.text = listOfSortedMembers[indexPath.row].distance + "miles"
        }
        else{
            cell.userLabel.text = listOfSortedMembers[indexPath.row].name // userArray[indexPath.row]
            cell.jobLabel.text = "Click help on the top right corner for more info." //listOfSortedMembers[indexPath.row].jobCategory  //jobArray[indexPath.row]
            cell.locationLabel.text = listOfSortedMembers[indexPath.row].location  //locationArray[indexPath.row]
            cell.durationLabel.text = listOfSortedMembers[indexPath.row].duration
            cell.distanceLabel.text = listOfSortedMembers[indexPath.row].distance
        }
        
        
        return cell
        
      //  let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! customCell
       // let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell
       //  cell.userLabel?.text = testArray[indexPath.row] //SNAPSHOT HERE
        ///self.tableView.reloadData()
        //cell.userLabel.text = testArray[indexPath.row]//test array line
         //cell.userImage.image = imageArray[indexPath.row] //UIImage(named: imageArray[indexPath.row]) //
         //cell.userImage?.image = egImage
        //self.tableView.reloadData()
      //  cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2 //makes cell view rounded
        //cell.userImage.layer.cornerRadius = cell.userImage.frame.height / 2 //makes user image rounded
       // return cell
    }
    
    func getList()
    {
        var listOfMembersLocal = [listMember]()//list of members to be retrieved from database
        var ref: DatabaseReference!//declare database reference
        ref = Database.database().reference() //reference to databse
        
        ref.child("users").observe(.value, with: { snapshot in //connect to database to retrieve user data
            if let snapshots = snapshot.value as? [String : AnyObject]{//retireve snapshots from database under user's
            if self.catchFireFlag == 1 { //prevent firing observer event from change in database
                self.catchFireFlag = 0//reset flag
                    
                for child in snapshots { //each child is a user
                     let userType = child.value["userType"] as? String//get user type of employee
                     if userType == "Employee"//if user is a employee
                    {
                        let jobCat = child.value["jobCategory"] as? String//get job category of employee
                        let jobCatL = jobCat?.lowercased()//convert it to lowercase
                        let location = child.value["location"] as? String//gets location of employee
                        
                        if jobCatL?.range(of: self.searchTerm.lowercased()) != nil{ //if search term is substring of jobCat
                            let employeeType = child.value["EmployeeType"] as? String//get employee type
                            var name = "" //declare name for employee
                            let postcode = child.value["postcode"] as? String//get employee postcode
                            
                            //check employee type
                            if employeeType == "Freelancer"{ // if freelancer
                                name = (child.value["name"] as? String)!//store name of employee as name
                            }
                            else if employeeType == "Business" //if business
                            {
                                name = (child.value["BusinessName"] as? String)!//store name of business as name
                            }//end check employee type
                        
                            let userChildID = child.key //get user id of child
          
                            
                            //check if members user id already exists in list
                            var addFlag = 0
                            for m in listOfMembersLocal
                            {
                                if m.id == userChildID
                                {
                                    addFlag = 1
                                }
                            }//...so if member is already in list so dont add again
                             //(BLOCK FIRES- should block the 3 fires caused by db change in 3 places)
                            
                            if addFlag == 0 {
                            listOfMembersLocal.append(listMember(id: userChildID, name: name, jobCategory: jobCat!, location: location!, distance:  "loading", duration: "loading", postcode: postcode!))
                                // adds this member to the list
                            }
                            
                            if listOfMembersLocal.count == 35 { break; } // caps the list at 35 members
                        }
                    }//end of if employee
                }//end of for each user (child)
                if listOfMembersLocal.count == 0{
                    //display empty cell
                    self.listOfSortedMembers.append(listMember(id: "0", name: "No results found", jobCategory: "", location: "", distance:  "", duration: "", postcode: ""))
                    // add empty member to list!
                }
                else{ //if list.count != 0
                    //get the distance/time between employer and employee for whole list and reload table
                    self.getDistanceTimeNew(listOfMembersLocal: listOfMembersLocal)
                    self.tableView.reloadData()
                }//end of if list.count != 0
               
            }//end of catch fire flag for observer events
          }//end  of snapshot
        })//end of database call
    }//end of method
    
    func loadUserImage(iURL: String)
    {
        let httpsReference = Storage.storage().reference(forURL: iURL)
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        httpsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
               
                let image = UIImage(data: data!)
                
                //add image to image array
                
                self.imageArray.append(image!)
                //self.usrImgView.image = image
            }
        }
    }
    
    func getEmployerByName()
    {
        var listOfMembersLocal = [listMember]()
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        //Test : let searchTerm = "Mechanic"
        ref.child("users").observe(.value, with: { snapshot in
            if let snapshots = snapshot.value as? [String : AnyObject]{
                
                for child in snapshots {
                    let userType = child.value["userType"] as? String
                    if userType == "Employer"
                    {
                        var name = child.value["name"] as? String
                        name = name?.lowercased()
                        let location = child.value["location"] as? String
                        // if jobCatC == self.searchTerm.lowercased(){ //if string = string
                        if name?.range(of: self.searchTerm.lowercased()) != nil{ //if string is substring
                            //count
                            self.listSize = self.listSize + 1
                        }
                    }
                }
                
                for child in snapshots {
                    let userType = child.value["userType"] as? String
                    if userType == "Employer"
                    {
                        var name = child.value["name"] as? String
                        var nameL = name?.lowercased()
                        let location = child.value["location"] as? String
                        
                        if nameL?.range(of: self.searchTerm.lowercased()) != nil{ //if string is substring
                            let postcode = child.value["postcode"] as? String
                            let jc = " "

                            
                            let userChildID = child.key as! String//get user id of child
                            
                            
                            var addFlag = 0
                            //check if members user id already exists in list //BLOCK FIRES- should block the 3 fires caused by db change in 3 places
                            for m in listOfMembersLocal
                            {
                                if m.id == userChildID
                                {
                                    addFlag = 1
                                }
                            }//...so if member is already in list so dont add again
                            
                            if addFlag == 0{
                                listOfMembersLocal.append(listMember(id: userChildID, name: name!, jobCategory: jc, location: location!, distance:  "loading", duration: "loading", postcode: postcode!))// adds this member to the list
                                print("ADDED" + name! + " TO LIST OF members")
                            }
                            print("Child: ", child)
                            print(name)

                            print(self.userArray.count)
                            
                            if listOfMembersLocal.count == 35 { break; } // caps the list at 35 members
                           
                        }
                    }
                }
                //  self.getDistanceTimeNew()
                
                //
                //self.tableView.reloadData()
            }
            self.getDistanceTimeNew(listOfMembersLocal: listOfMembersLocal)
            self.tableView.reloadData()
        })
        
        //self.tableView.reloadData()
        // print(usersQuery)
        
    }
    func getEmployeesByName()
    {
        var listOfMembersLocal = [listMember]()
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        //Test : let searchTerm = "Mechanic"
        ref.child("users").observe(.value, with: { snapshot in
            if let snapshots = snapshot.value as? [String : AnyObject]{
                
                /*
                for child in snapshots {
                    let userType = child.value["userType"] as? String
                    if userType == "Employee"
                    {
                        var jobCatC = child.value["jobCategory"] as? String
                        jobCatC = jobCatC?.lowercased()
                        let location = child.value["location"] as? String
                        // if jobCatC == self.searchTerm.lowercased(){ //if string = string
                        if jobCatC?.range(of: self.searchTerm.lowercased()) != nil{ //if string is substring
                            //count
                            self.listSize = self.listSize + 1
                        }
                    }
                }*/
                
                for child in snapshots {
                    let userType = child.value["userType"] as? String
                    if userType == "Employee"
                    {
                        var jobCat = child.value["jobCategory"] as? String
                        jobCat = jobCat?.lowercased()
                        let location = child.value["location"] as? String
                        
                        //check employee type
                        var name = ""
                        var employeeType = child.value["EmployeeType"] as? String
                        if employeeType == "Freelancer"
                        {
                            name = (child.value["name"] as? String)!
                        }
                        else if employeeType == "Business" //if business
                        {
                            name = (child.value["BusinessName"] as? String)!
                        }//end check employee type
                        
                        
                        //  if jobCat == self.searchTerm.lowercased(){// if string = string
                        if name.lowercased().range(of: self.searchTerm.lowercased()) != nil{ //if string is substring
                            
                            
                            let postcode = child.value["postcode"] as? String

                            self.userArray.append(name)
                            let jc = child.value["jobCategory"] as? String
                            self.jobArray.append(jc!)
                            self.locationArray.append(location!)

                            
                            let userChildID = child.key as! String//get user id of child
                            //self.listOfMembers.append(listMember(id: userID, name: name, jobCategory: jc!, location: location!, distance:  "distance1", duration: "duration2", postcode: postcode!))// adds this member to the list
                            
                            var addFlag = 0
                            //check if members user id already exists in list //BLOCK FIRES- should block the 3 fires caused by db change in 3 places
                            for m in listOfMembersLocal
                            {
                                if m.id == userChildID
                                {
                                    addFlag = 1
                                }
                            }//...so if member is already in list so dont add again
                            
                            if addFlag == 0{
                            listOfMembersLocal.append(listMember(id: userChildID, name: name, jobCategory: jc!, location: location!, distance:  "loading", duration: "loading", postcode: postcode!))// adds this member to the list
                            print("ADDED" + name + " TO LIST OF members")
                            }
                            
                            if listOfMembersLocal.count == 35 { break; } // caps the list at 35 members
                        }
                    }
                }

            }
            if listOfMembersLocal.count == 0{
                //display empty cell
                self.listOfSortedMembers.append(listMember(id: "0", name: "No results found", jobCategory: "", location: "", distance:  "", duration: "", postcode: ""))// add empty member to list!
                
            }
            else{
                self.getDistanceTimeNew(listOfMembersLocal: listOfMembersLocal)
                self.tableView.reloadData()
            }
        })
        
    }
    
    func checkUserType()
    {
        let userId = KeychainWrapper.standard.string(forKey: "uid")

        Database.database().reference().child("users").child(userId!).observeSingleEvent(of: .value){ (snapshot) in
            if let child = snapshot.value as? [String : AnyObject]{
                
                //  for child in snapshots { //for each pending request
                let userType = child["userType"] as? String
                if userType == "Employer"
                {
                    self.myType = "Employer"
                    self.tabBar.isHidden = false
                }
                else{
                    self.myType = "Employee"
                    self.tabBar.isHidden = true
                   // self.tabReplaceLabel
                    self.tabReplaceLabel.isHidden = false
                }
               // print("USER1 is an " + self.myType)
                //self.runSearchEngine()
            }

        }

        
        
    }
    
    func exampleImg()
    {
        
        let httpsReference = Storage.storage().reference(forURL: "https://firebasestorage.googleapis.com/v0/b/employ-166fd.appspot.com/o/993191A5-5BC4-4DC5-ABED-EB1A7CEB682B?alt=media&token=733b7541-4bfb-4936-a444-4617b4356abb")
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        httpsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                // Uh-oh, an error occurred!
            } else {
                
                let image = UIImage(data: data!)
                
                //add image to image array
                
                self.egImage = image
                //self.usrImgView.image = image
            }
        }
        
    }
    
    @IBAction func cancelClicked(_sender: AnyObject){// search button
        
        self.searchBar.endEditing(true)
        
    }
    
    @IBAction func searchClicked(_sender: AnyObject){// search button

        self.runSearchEngine()

    }
    
    func runSearchEngine(){
        self.catchFireFlag = 1;
        self.distanceTimeIndex = 0;
        self.listSize = 0;
       // self.listOfMembers.removeAll()
        self.listOfSortedMembers.removeAll()
        
        
        
        self.searchTerm = searchBar.text!
        self.searchTerm = self.searchTerm
            .replacingOccurrences(of: " ", with: "", options: .literal, range: nil)//remove spaces in searchTerm
        self.searchTerm = self.searchTerm.lowercased()// convert to lowercase
        
        getMyPostcode()//get postcode just incase it was changed during a profile update!
        if self.myType == "Employer"
        {
            if self.tabPointer == 0
            {
            self.searchOptimiser()
            self.getList()
            }
            else if tabPointer == 1
            {
                //search employees by name for employer
                self.getEmployeesByName()
                
                
            }
         print("SIZE OF LIST IS : " + String( self.listOfMembers.count))
        }
        else if self.myType == "Employee"{ //im an employee so search by name for employers
            self.getEmployerByName()
        }
        
        if self.listOfSortedMembers.count == 0{
            self.listOfSortedMembers.append(listMember(id: "none", name: "No results found", jobCategory: "", location: "", distance:  "", duration: "", postcode: ""))// add empty member to list!
            self.tableView.reloadData()
        }
    }
    
    //let jobPickerData = ["Pick a Job Category","Accountant","Actor", "Artist", "Architect", "App Developer","Assistant", "Builder", "Caterer!!!!", "Caretaker", "Cleaner","Chef","Driver","Dentist","Doctor", "Engineer","Fashion Designer", "Florist", "Gardener","Graphic Designer", "Handyman", "Hairdresser", "Mechanic", "Makeup Artist", "Musician", "Nurse", "Painter", "Personal Trainer", "Personal Shopper", "Plumber", "Photographer", "Party Planner", "Software Engineer","Tattoo Artist", "Technician", "Tech Specialist", "Therapist", "Translator", "Tutor", "Window Cleaner", "Writer"] //40
    
    func searchOptimiser(){
        let jobPickerData = ["Pick a Job Category","Accountant","Actor", "Artist", "Architect", "App Developer","Assistant", "Baby Sitter", "Builder", "Caterer", "Caretaker", "Cleaner","Chef","Driver","Dentist","Doctor","Electrician","Engineer","Exterminator","Fashion Designer", "Florist", "Gardener","Graphic Designer", "Handyman", "Hairdresser","Masseuse", "Mechanic", "Makeup Artist", "Musician", "Nurse", "Painter", "Personal Trainer", "Personal Shopper", "Plumber", "Photographer", "Party Planner", "Software Engineer","Tattoo Artist", "Technician", "Tech Specialist", "Therapist", "Translator", "Tutor","Watch Specialist", "Window Cleaner", "Writer"] //44
        var loops = 1
        for i in 0..<loops{
        
        //Florist relations
         if (self.searchTerm.range(of: "flower") != nil || self.searchTerm.range(of: "petals") != nil || self.searchTerm.range(of: "bouquet") != nil || self.searchTerm.range(of: "garland") != nil || self.searchTerm.range(of: "rose") != nil){ //if string is substring
            
                self.searchTerm = "florist"
                break
            }
            
        //Caretaker relations
        if ( (self.searchTerm.range(of: "watchman") != nil) || (self.searchTerm.range(of: "caretaker") != nil) || ((self.searchTerm.range(of: "look") != nil) && (self.searchTerm.range(of: "house") != nil) || (self.searchTerm.range(of: "land") != nil)  || (self.searchTerm.range(of: "building") != nil) ) || (self.searchTerm.range(of: "property") != nil) || (self.searchTerm.range(of: "flat") != nil) || (self.searchTerm.range(of: "apartment") != nil) || (self.searchTerm.range(of: "mansion") != nil) ){ //if string is substring
                self.searchTerm = "caretaker"
                break
        }
        
            
        //Baby Sitter relations
            if ( (self.searchTerm.range(of: "baby") != nil) ||
                (self.searchTerm.range(of: "care") != nil) ||
                (self.searchTerm.range(of: "child") != nil) || (self.searchTerm.range(of: "supervis") != nil) || (self.searchTerm.range(of: "daughter") != nil) || (self.searchTerm.range(of: "kids") != nil) || (self.searchTerm.range(of: "lookaft") != nil)){ //if string is substring
                self.searchTerm = "baby sitter"
                break
        }
        
        //Plumber relations
        if ((self.searchTerm.range(of: "plumb") != nil) || (self.searchTerm.range(of: "toilet") != nil) || (self.searchTerm.range(of: "sink") != nil) || (self.searchTerm.range(of: "drain") != nil) || (self.searchTerm.range(of: "clog") != nil)  || ((self.searchTerm.range(of: "loo") != nil) && !(self.searchTerm.range(of: "look") != nil) && !(self.searchTerm.range(of: "loop") != nil) && !(self.searchTerm.range(of: "loot") != nil)) ){ //if string is substring
            // if (self.searchTerm.range(of: "repair") != nil) || (self.searchTerm.range(of: "prob") != nil) || (self.searchTerm.range(of: "brok") != nil) { //if string is substring
            self.searchTerm = "plumber"
            break
       //  }
            
        }
        
        //Accountant relations
        if (self.searchTerm.range(of: "balancesheet") != nil || (self.searchTerm.range(of: "investment") != nil)){ //if string is substring
           // if (self.searchTerm.range(of: "help") != nil) || (self.searchTerm.range(of: "need") != nil) || (self.searchTerm.range(of: "money") != nil) { //if string is substring
                self.searchTerm = "accountant"
                break
          //  }
            
        }
        
        //Actor relations
        if ( (self.searchTerm.range(of: "acting") != nil) || (self.searchTerm.range(of: "audition") != nil) || (self.searchTerm.range(of: "drama") != nil)){ //if string is substring
                self.searchTerm = "actor"
            break
            //  }
            
        }
        
        
        
        //Painter relations
        if ( (self.searchTerm.range(of: "painter") != nil) || ((self.searchTerm.range(of: "paint") != nil) && (self.searchTerm.range(of: "house") != nil)) || ((self.searchTerm.range(of: "paint") != nil) && (self.searchTerm.range(of: "room") != nil))) { //if string is substring
                self.searchTerm = "painter"
                break
        }
            
        //Artist relations
        if ( (self.searchTerm.range(of: "paint") != nil) || (self.searchTerm.range(of: "canvas") != nil) || ((self.searchTerm.range(of: "draw") != nil) && !(self.searchTerm.range(of: "withdraw") != nil)) || (self.searchTerm.range(of: "sketch") != nil)  ){ //if string is substring
            self.searchTerm = "artist"
            break
        }
        
        //App Developer relations
        if ( (self.searchTerm.range(of: "appdeveloper") != nil) || (self.searchTerm.range(of: "ios") != nil) || (self.searchTerm.range(of: "android") != nil) || (self.searchTerm.range(of: "mobile") != nil)    ){ //if string is substring
            self.searchTerm = "app developer"
            break
        }
        
        //Assistant relations
        if ( (self.searchTerm.range(of: "assisting") != nil) || (self.searchTerm.range(of: "receptionist") != nil) ){ //if string is substring
                self.searchTerm = "assistant"
                break
        }
            

        //Builder relations
        if ((self.searchTerm.range(of: "scaff") != nil) || (self.searchTerm.range(of: "build") != nil) || (self.searchTerm.range(of: "shed") != nil) || (self.searchTerm.range(of: "extension") != nil) || (self.searchTerm.range(of: "cement") != nil) || (self.searchTerm.range(of: "patio") != nil) || (self.searchTerm.range(of: "brick") != nil)  ){ //if string is substring
            self.searchTerm = "builder"
            break
        }
        
        //Caterer relations
        if ( (self.searchTerm.range(of: "food") != nil) || (self.searchTerm.range(of: "hungry") != nil)  || (self.searchTerm.range(of: "dessert") != nil) || (self.searchTerm.range(of: "icecre") != nil) || (self.searchTerm.range(of: "cake") != nil)   || ((self.searchTerm.range(of: "cook") != nil) && (self.searchTerm.range(of: "party") != nil) ) ){ //if string is substring
            self.searchTerm = "caterer"
            break
        }
        

        
        //Cleaner relations
        if (  ((self.searchTerm.range(of: "clean") != nil) || ((self.searchTerm.range(of: "wash") != nil)))){
            self.searchTerm = "cleaner"
            break
        }
        
        //Chef relations
        if ( (self.searchTerm.range(of: "cook") != nil) ){ //if string is substring
            self.searchTerm = "chef"
            break
        }
            
        //Driver relations
        if ( (self.searchTerm.range(of: "uber") != nil) || (self.searchTerm.range(of: "driving") != nil) || (self.searchTerm.range(of: "taxi") != nil) ){ //if string is substring
                self.searchTerm = "driver"
                break
        }

        //Dentist relations
        if ( (self.searchTerm.range(of: "tooth") != nil) || (self.searchTerm.range(of: "teeth") != nil) || (self.searchTerm.range(of: "brace") != nil) || (self.searchTerm.range(of: "filling") != nil) || (self.searchTerm.range(of: "retainer") != nil) ){ //if string is substring
                self.searchTerm = "dentist"
                break
        }
         if ((self.searchTerm.range(of: "pain") != nil) && ((self.searchTerm.range(of: "tooth") != nil) || (self.searchTerm.range(of: "teeth") != nil) ))
         {
            self.searchTerm = "dentist"
            break
         }
        
        //Massuese relations
        if ( (self.searchTerm.range(of: "backpain") != nil) || (self.searchTerm.range(of: "massage") != nil) || (self.searchTerm.range(of: "relax") != nil) ){ //if string is substring
                self.searchTerm = "massuese"
                break
        }
            
        //Musician relations
        if ( (self.searchTerm.range(of: "guitar") != nil) || (self.searchTerm.range(of: "sing") != nil) || (self.searchTerm.range(of: "piano") != nil) || (self.searchTerm.range(of: "drums") != nil) || (self.searchTerm.range(of: "violin") != nil) || (self.searchTerm.range(of: "keyboard") != nil) || (self.searchTerm.range(of: "flute") != nil) || (self.searchTerm.range(of: "dj") != nil) || (self.searchTerm.range(of: "band") != nil)){ //if string is substring
                self.searchTerm = "musician"
                break
        }
        
        //Tattoo Artist relations
        if ( (self.searchTerm.range(of: "tattoo") != nil) || (self.searchTerm.range(of: "ink") != nil) || (self.searchTerm.range(of: "needle") != nil)){ //if string is substring
                self.searchTerm = "tattoo artist"
                break
        }
            
        //Doctor relations
        if ( (self.searchTerm.range(of: "pain") != nil) || (self.searchTerm.range(of: "cancer") != nil) || (self.searchTerm.range(of: "arm") != nil) || (self.searchTerm.range(of: "leg") != nil) || (self.searchTerm.range(of: "blood") != nil) || (self.searchTerm.range(of: "bleed") != nil) || (self.searchTerm.range(of: "medic") != nil) || (self.searchTerm.range(of: "hospit") != nil) ){ //if string is substring
                self.searchTerm = "doctor"
                break
        }
            
        //Engineer relations
        if ( (self.searchTerm.range(of: "tv") != nil) || (self.searchTerm.range(of: "aircond") != nil) || (self.searchTerm.range(of: "boiler") != nil) || (self.searchTerm.range(of: "fridge") != nil) || (self.searchTerm.range(of: "microwa") != nil) || (self.searchTerm.range(of: "oven") != nil) || (self.searchTerm.range(of: "freezer") != nil)){ //if string is substring
                self.searchTerm = "engineer"
                break
        }
        
        //Electrician relations
        if ( (self.searchTerm.range(of: "electr") != nil) || (self.searchTerm.range(of: "alarm") != nil) || (self.searchTerm.range(of: "wiring") != nil) || (self.searchTerm.range(of: "socket") != nil) || (self.searchTerm.range(of: "plug") != nil) || (self.searchTerm.range(of: "fuse") != nil)){ //if string is substring
                self.searchTerm = "electrician"
                break
        }

        //Fashion Designer relations
        if ( (self.searchTerm.range(of: "cloth") != nil) || (self.searchTerm.range(of: "handbag") != nil) || (self.searchTerm.range(of: "shoe") != nil) ){ //if string is substring
                self.searchTerm = "fashion designer"
                break
        }
            
        //Gardener relations
        if ( (self.searchTerm.range(of: "gard") != nil) || (self.searchTerm.range(of: "tree") != nil) || (self.searchTerm.range(of: "grass") != nil) || (self.searchTerm.range(of: "lawn") != nil)  ){ //if string is substring
                self.searchTerm = "gardener"
                break
        }
            
        //Graphic Designer relations
        if ( (self.searchTerm.range(of: "logo") != nil) || (self.searchTerm.range(of: "3d") != nil) || (self.searchTerm.range(of: "photoshop") != nil) || (self.searchTerm.range(of: "graphics") != nil)  ){ //if string is substring
                self.searchTerm = "graphic designer"
                break
        }
            
            
        //Hairdresser relations
        if ( (self.searchTerm.range(of: "hair") != nil) || (self.searchTerm.range(of: "barber") != nil) || (self.searchTerm.range(of: "hair") != nil) && (self.searchTerm.range(of: "cut") != nil) || (self.searchTerm.range(of: "beard") != nil) || (self.searchTerm.range(of: "dye") != nil) || (self.searchTerm.range(of: "eyebrow") != nil) ){ //if string is substring
                self.searchTerm = "hairdresser"
                break
        }
    
        
            //"Personal Shopper", "Plumber", "Photographer", "Party Planner", "Software Engineer","Tattoo Artist", "Technician", "Tech Specialist", "Therapist", "Translator", "Tutor", "Window Cleaner", "Writer"] //41
 
        //Personal shopper relations
        if ((self.searchTerm.range(of: "shopping") != nil) || (self.searchTerm.range(of: "buy") != nil) || (self.searchTerm.range(of: "purchase") != nil) ){ //if string is substring
                self.searchTerm = "personal shopper"
                break
        }
            
        //Photographer relations
        if ( (self.searchTerm.range(of: "photo") != nil) || (self.searchTerm.range(of: "camera") != nil) && (self.searchTerm.range(of: "video") != nil) || (self.searchTerm.range(of: "pic") != nil) || (self.searchTerm.range(of: "media") != nil) || (self.searchTerm.range(of: "paparaz") != nil) ){ //if string is substring
                self.searchTerm = "photographer"
                break
        }
  
        //Party planner relations
        if ( (self.searchTerm.range(of: "party") != nil) || (self.searchTerm.range(of: "event") != nil) && (self.searchTerm.range(of: "wedding") != nil) || (self.searchTerm.range(of: "decor") != nil) || (self.searchTerm.range(of: "celebra") != nil) || (self.searchTerm.range(of: "dinner") != nil) || (self.searchTerm.range(of: "prom") != nil) || (self.searchTerm.range(of: "banquet") != nil) || (self.searchTerm.range(of: "reception") != nil)  ){ //if string is substring
                self.searchTerm = "party planner"
                break
        }
 
        //Software Engineer relations
        if ( (self.searchTerm.range(of: "coding") != nil) || (self.searchTerm.range(of: "website") != nil) && (self.searchTerm.range(of: "software") != nil) || (self.searchTerm.range(of: "system") != nil) || (self.searchTerm.range(of: "interface") != nil) ){ //if string is substring
                self.searchTerm = "software engineer"
                break
        }
            

        
        //Technician relations
        if ( (self.searchTerm.range(of: "techni") != nil)){ //if string is substring
                self.searchTerm = "technician"
                break
        }
            
        //Tech Specialist relations
            if ( ((self.searchTerm.range(of: "comp") != nil) && !(self.searchTerm.range(of: "compa") != nil)) && !(self.searchTerm.range(of: "compl") != nil) || (self.searchTerm.range(of: "phone") != nil) ||
                (self.searchTerm.range(of: "router") != nil) ||
                (self.searchTerm.range(of: "mobile") != nil) || (self.searchTerm.range(of: "internet") != nil) || (self.searchTerm.range(of: "server") != nil) || (self.searchTerm.range(of: "screen") != nil) || (self.searchTerm.range(of: "lapt") != nil) || (self.searchTerm.range(of: "hacker") != nil) || (self.searchTerm.range(of: "hacker") != nil) || (self.searchTerm.range(of: "ipad") != nil) || (self.searchTerm.range(of: "tablet") != nil) || (self.searchTerm.range(of: "comp") != nil) && ((self.searchTerm.range(of: "virus") != nil) || ((self.searchTerm.range(of: "prob") != nil) || ((self.searchTerm.range(of: "brok") != nil)) || ((self.searchTerm.range(of: "tech") != nil)) ) )){ //if string is substring
                self.searchTerm = "tech"
                break
        }
    
        //Therapist relations
            if ( (self.searchTerm.range(of: "therapy") != nil) || (self.searchTerm.range(of: "companion") != nil) || (self.searchTerm.range(of: "crazy") != nil) || (self.searchTerm.range(of: "disord") != nil) || (self.searchTerm.range(of: "depress") != nil) ||  (self.searchTerm.range(of: "mental") != nil) || (self.searchTerm.range(of: "hypno") != nil) || (self.searchTerm.range(of: "psycho") != nil)){ //if string is substring
                self.searchTerm = "therapist"
                break
        }
        
        //Translator relations
            if ( (self.searchTerm.range(of: "translat") != nil) || (self.searchTerm.range(of: "language") != nil)){ //if string is substring
                self.searchTerm = "translator"
                break
        }
            
        //Watch specialist relations
        if ( ((self.searchTerm.range(of: "watch") != nil) && !(self.searchTerm.range(of: "watched") != nil) && !(self.searchTerm.range(of: "watching") != nil) ) || (self.searchTerm.range(of: "time") != nil) || (self.searchTerm.range(of: "clock") != nil)){ //if string is substring
                self.searchTerm = "watch specialist"
                break
        }
            
        //Tutor relations
        if ( (self.searchTerm.range(of: "school") != nil) || (self.searchTerm.range(of: "exam") != nil) || (self.searchTerm.range(of: "multiply") != nil) || (self.searchTerm.range(of: "tuition") != nil) || (self.searchTerm.range(of: "study") != nil) || (self.searchTerm.range(of: "homework") != nil) || (self.searchTerm.range(of: "maths") != nil) || (self.searchTerm.range(of: "english") != nil) || (self.searchTerm.range(of: "spanish") != nil) || (self.searchTerm.range(of: "chinese") != nil) || (self.searchTerm.range(of: "history") != nil) || (self.searchTerm.range(of: "geo") != nil) || (self.searchTerm.range(of: "science") != nil) || (self.searchTerm.range(of: "french") != nil) || (self.searchTerm.range(of: "teach") != nil) || (self.searchTerm.range(of: "learn") != nil)){ //if string is substring
                self.searchTerm = "tutor"
                break
        }

        //Window Cleaner relations
        if ( (self.searchTerm.range(of: "window") != nil) || ((self.searchTerm.range(of: "glass") != nil) && (self.searchTerm.range(of: "clean") != nil) || (self.searchTerm.range(of: "wash") != nil))){ //if string is substring
                self.searchTerm = "window"
                break
        }
            
        //Writer relations
        if ( (self.searchTerm.range(of: "writing") != nil) || ((self.searchTerm.range(of: "author") != nil) || (self.searchTerm.range(of: "book") != nil)) || (self.searchTerm.range(of: "essay") != nil)){ //if string is substring
                self.searchTerm = "writer"
                break
        }
        
        //Mechanic relations
        if ( (self.searchTerm.range(of: "car") != nil) || (self.searchTerm.range(of: "vehicle") != nil) || (self.searchTerm.range(of: "van") != nil) || (self.searchTerm.range(of: "truck") != nil) || (self.searchTerm.range(of: "tyre") != nil) || (self.searchTerm.range(of: "wingmirror") != nil) || (self.searchTerm.range(of: "sidedoor") != nil) || (self.searchTerm.range(of: "boot") != nil) ){ //if string is substring
                
                self.searchTerm = "mechanic"
                break
        }
            
        //Handyman relations
        if ( (self.searchTerm.range(of: "anything") != nil) || (self.searchTerm.range(of: "boxes") != nil) || (self.searchTerm.range(of: "mov") != nil) || (self.searchTerm.range(of: "help") != nil) || (self.searchTerm.range(of: "carry") != nil) || (self.searchTerm.range(of: "brok") != nil) || (self.searchTerm.range(of: "moving") != nil) || (self.searchTerm.range(of: "fix") != nil) || (self.searchTerm.range(of: "getridof") != nil) || (self.searchTerm.range(of: "crack") != nil) || (self.searchTerm.range(of: "smash") != nil)){ //if string is substring
                self.searchTerm = "handyman"
                break
        }
            
        //Personal trainer relations
        if ( (self.searchTerm.range(of: "gym") != nil) || (self.searchTerm.range(of: "box") != nil) || (self.searchTerm.range(of: "weight") != nil) && (self.searchTerm.range(of: "loss") != nil) || (self.searchTerm.range(of: "muscle") != nil) || (self.searchTerm.range(of: "training") != nil) || (self.searchTerm.range(of: "lovehandles") != nil) || (self.searchTerm.range(of: "belly") != nil) || (self.searchTerm.range(of: "overweight") != nil) || (self.searchTerm.range(of: "ripped") != nil)  || ((self.searchTerm.range(of: "fat") != nil)  ) && !(self.searchTerm.range(of: "fath") != nil)  ){ //if string is substring
                self.searchTerm = "personal trainer"
                break
        }
        
        //Exterminator relations
        if ( (self.searchTerm.range(of: "rat") != nil) || (self.searchTerm.range(of: "rodent") != nil) || (self.searchTerm.range(of: "mouse") != nil) || (self.searchTerm.range(of: "mice") != nil) || (self.searchTerm.range(of: "bugs") != nil) || (self.searchTerm.range(of: "infestation") != nil) || (self.searchTerm.range(of: "bees") != nil) || (self.searchTerm.range(of: "spider") != nil) || (self.searchTerm.range(of: "insect") != nil)){ //if string is substring
                self.searchTerm = "exterminator"
                break
        }
        
        //Architect relations
        if ( (self.searchTerm.range(of: "arch") != nil) || (self.searchTerm.range(of: "house") != nil) || (self.searchTerm.range(of: "building") != nil)    ){ //if string is substring
                self.searchTerm = "architect"
                break
        }

        //Proposal for spelling mistakes: check if 60% of letters match in given order
       /* var length = self.searchTerm.count
        for job in jobPickerData //for each jobCat
        {
            for i in 1..<length //for each letter in search Term
            {
                
            }
        }*/
            
        }//end of forloop
        
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)  {
        self.searchBar.resignFirstResponder()
        
    }
    
    func sortList()
    {
       // var listOfSortedMembers = [listMember]()
        var count = self.listOfMembers.count
        var smallestNum = (self.listOfMembers[0].duration as NSString).doubleValue
        var closestMember = self.listOfMembers[0]
        var closestMembersIndex = 0
        var sorted = true
        while(!sorted)
        {
        for i in 1..<count
        {
            var selectedMemeberNum = (self.listOfMembers[i].duration as NSString).doubleValue
            if selectedMemeberNum < smallestNum
            {
                smallestNum = (self.listOfMembers[i].duration as NSString).doubleValue //Current member has smallest num
                closestMember = self.listOfMembers[i]
                closestMembersIndex = i
            }
        }
        self.listOfSortedMembers.append(closestMember)
        self.listOfMembers.remove(at: closestMembersIndex)
            if self.listOfMembers.count == 0
            {
                sorted = false //sorted now
            }
        }
        
        self.listOfMembers = self.listOfSortedMembers
        
        
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        self.runSearchEngine()
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        self.runSearchEngine()
        searchBar.resignFirstResponder()
        return true
    }
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if listOfSortedMembers[indexPath.row].id != "none"{ //Do this if results!= null
            print(listOfSortedMembers[indexPath.row].id)
            self.childId = listOfSortedMembers[indexPath.row].id
            
            
            self.performSegue(withIdentifier: "toViewProfile", sender: nil)
             //send this id to the next viewProfileController
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewProfileVC = segue.destination as! viewProfileController
        viewProfileVC.childID = self.childId
    }
    
    @IBAction func helpClicked(_ sender: Any) {
        if self.myType == "Employee"
        {
            showAlertBox(titleStr: "Help?", messageStr: "As an Employee you can search for Employer's by name")
        }
        else{
            showAlertBox(titleStr: "Help?", messageStr: "1) Advanced Search : \n As an Employer you can search for an Employee by entering a job category (examples; mechanic, cleaner, gardener, plumber..etc). \n Or you can simply type in your problem and our search engine will try and come up with a list of employees who can help you! \n (Example: I need flowers for my mum, will show a list of florists nearby) \n \n 2)Name Search: \n Once clicked, this feature allows for you to find Employees by name. \n \n 3) Our search engine will show you a list of employees nearby starting with the people closest to you!")
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

    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
