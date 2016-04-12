//
//  ProfileTableViewCell.swift
//  Ryde
//
//  Created by Andrew Mogg on 4/12/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
