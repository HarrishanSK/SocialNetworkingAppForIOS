//
//  JobTableViewCell.swift
//  employ
//
//  Created by Harrishan Sureshkumar on 07/04/2018.
//  Copyright © 2018 Harrishan Sureshkumar. All rights reserved.
//

import UIKit

class JobTableViewCell: UITableViewCell {
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
