//
//  MealViewController.swift
//  FoodTracker
//
// This View can be used to either create a new meal, or edit an existing one, and so it displays only one meal or default values that may be modified and then saved.
//
//  Created by Melanie MacDonald on 2018-09-21.
//  Copyright © 2018 Melanie MacDonald. All rights reserved.
//

import UIKit
import os.log

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: Properties

    // These variables are connected to corresponding text/photo/button/custom fields on the UI, and
    // can be used either to retrieve values from those fields or to set their values
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    /*
     This value is either passed by 'MealTableViewController' in 'prepare(for:sender:)' or constructed as part of adding a new meal
    */
    var meal: Meal?
    
    // Executes on loading the view, and so gives the chance to set certain default values on displaying the view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field's user input through delegate callbacks.
        nameTextField.delegate = self
        
        // Set up views if editing an existing Meal.
        // If the meal variable has a value (it is optional, so it may not be set), then this view must be displaying a preexisting Meal for editing, and so the corresponding details should be displayed rather than the defaults (as when creating a new Meal)
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text   = meal.name
            photoImageView.image = meal.photo
            ratingControl.rating = meal.rating
        }
        
        // Enable the Save button only if the text field has a valid Meal name
        updateSaveButtonState()
    }
    
    //MARK: UITextFieldDelegate
    
    // This activates when hitting the "Return" or "Done" key on the keyboard, in this case hiding it
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        // indicates whether system should respond to the press of the "Return" or "Done" key or not
        // in this case, there's no reason not to respond, so it should always return true
        return true
    }
    
    // Executes after done editing, and after the keyboard is hidden
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Checks to be sure the text entered is valid before allowing the user to save
        updateSaveButtonState()
        // Sets the title of the meal to what the user entered in the text field
        navigationItem.title = textField.text
    }
    
    // Executes after the user taps on the text field in order to start typing
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing
        saveButton.isEnabled = false
    }
    
    //MARK: UIImagePickerControllerDelegate
    
    // Executes on clicking the "Cancel" button while browsing the phone for an image for the image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled
        dismiss(animated: true, completion: nil)
    }
    
    // Captures the image to be displayed from the image picker when the user taps an image, and sets it in the image view, then dismisses the picker and returns to the view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // Saves the image selected by the user, or else displays an error if a UIImage object is not returned
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image on the view
        photoImageView.image = selectedImage
        
        // Dismiss the picker
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Navigation
    
    // Is attached to the "Cancel" button on the view, and executes when it is clicked
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        // It determines the style of presentation based on whether a Navigation Controller was used to navigate to the current view. If so, then it was a modal transition, and so a meal was added
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        // If a meal was added, then it was modally displayed, and the modal just needs to be dismissed to go back to the table view
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        }
        // Otherwise, the view may have been displayed with a push transition, as when editing a meal, and so the current view was pushed onto the navigation stack. To go back to the previous view the current view needs to be popped
        else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
        // If neither of the above conditions are true, then no navigation controllers were used to get to the current view, which puts the program in an error state
        else {
            fatalError("The MealViewController is not inside a navigation controller")
        }
    }
    
    // This method lets you configure a view controller before it's presented
    // It executes for the unwind segue, which normally occurs when attempting to save a meal after editing or adding it, and performs actions necessary for the display of the next view, which in this case involves saving the meal that the user has modified or created so that it can be added as a row to the new table view and saved in the data model (or a preexisting row is modified)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = nameTextField.text ?? ""
        let photo = photoImageView.image
        let rating = ratingControl.rating
        
        // Set the meal to be passed to MealTableViewController after the unwind segue
        // This saves the state of the meal object that the user modified or created so that it may be edited or saved in the data model and displayed on the table view
        meal = Meal(name: name, photo: photo, rating: rating)
    }
    
    //MARK: Actions
    
    // Executes on clicking on the image view, so that the image picker controller can be triggered to allow a user to pick an image from the phone's photo gallery for display in the app
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // Hide the keyboard in case it was open when user taps on the image
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library
        let imagePickerController = UIImagePickerController()
        
        // Only allows photos to be picked, not taken
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    
    // Purpose is to ensure the save button is only clickable when the values on the view for the meal are in a valid format for the Meal object, namely the text field cannot be empty, whereas the image is optional, and the rating button has its own handling in another file to ensure it is a valid value
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
}

