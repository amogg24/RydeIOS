//
//  AddGroupViewController.swift
//  Ryde
//
//  Created by Cody Cummings on 4/11/16.
//  Copyright © 2016 Jared Deiner. All rights reserved.
//

import UIKit

class AddGroupViewController: UIViewController {

    
    // Mark - IBOutlets
    
    @IBOutlet var groupNameTextField: UITextField!
    
    @IBOutlet var groupDescriptionTextView: UITextView!
    
    @IBOutlet var groupMemberSearchBar: UISearchBar!
    
    @IBOutlet var groupMemberTableView: UITableView!
    
    // Mark - IBActions
    
    @IBAction func saveGroup(sender: UIBarButtonItem) {
    }
    
    // Mark - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.groupMemberTableView.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }

}
