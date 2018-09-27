//
//  ViewController.swift
//  FoodTracker
//
//  Created by Melanie MacDonald on 2018-09-21.
//  Copyright © 2018 Melanie MacDonald. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    //MARK: Properties

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mealNameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field's user input through delegate callbacks.
        nameTextField.delegate = self
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        // indicates whether system should respond to the press of the "Return" or "Done" key or not
        // in this case, there's no reason not to respond, so it should always return true
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        mealNameLabel.text = textField.text
    }
    
    //MARK: Actions
    
    @IBAction func setDefaultLabelText(_ sender: UIButton) {
        mealNameLabel.text = "Default Text"
    }
}

