//
//  ContactsTableViewCell.swift
//  employ
//
//  Created by Harrishan Sureshkumar on 12/03/2018.
//  Copyright © 2018 Harrishan Sureshkumar. All rights reserved.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func acceptButtonClicked(_sender: AnyObject){// back button
        
    }
    
    @IBAction func declineButtonClicked(_sender: AnyObject){// back button  
        
    }

}
