//
//  GroupDetailsTableViewController.swift
//  Ryde
//
//  Created by Cody Cummings on 4/5/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit

class GroupDetailsTableViewController: UITableViewController {

    // Mark - Fields

    var groupInfo: Dictionary<String, Dictionary<Int, String>>?
    
    // Mark - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ask server what groups i am a part of and fill groupArray
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
}
