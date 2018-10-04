//
//  RatingControl.swift
//  FoodTracker
//
// This class defines the custom ratings button, which is displayed as stars that may or may not be filled depending on the rating value
//
//  Created by Melanie MacDonald on 2018-09-28.
//  Copyright © 2018 Melanie MacDonald. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    //MARK: Properties
    // The rating control is represented as an array of buttons, as each rating star needs to be clickable
    private var ratingButtons = [UIButton]()
    
    // didSet defines an inspectable property that executes certain code when that variable's value is modified
    
    // When the rating value is changed, update which stars are filled
    var rating = 0 {
        didSet {
            updateButtonSelectionStates()
        }
    }
    
    // When the size of the stars are changed, redraw the stars in the Stack View
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    // When the number of stars is changed, redraw the stars in the Stack View
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
    //MARK: Initialization
    // On creation, either from data or from a new Meal object, redraw the rating control for accurate display
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    //MARK: Button Action
    // On tapping any one of the rating buttons adjust the rating attribute accordingly
    @objc func ratingButtonTapped(button: UIButton) {
        guard let index = ratingButtons.index(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(ratingButtons)")
        }
        
        // Calculate the rating of the selected button
        let selectedRating = index + 1
        
        if selectedRating == rating {
            // If the selected star represents the current rating, reset the rating to 0.
            rating = 0
        } else {
            // Otherwise set the rating to the selected star
            rating = selectedRating
        }    }
    
    //MARK: Private Methods
    // Defines the existence and appearance of all rating stars in the UIStackView
    private func setupButtons() {
        //clear any existing buttons, so it starts from a blank state
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        // Load the images to be used for the stars, which can be either filled, empty, or highlighted, depending on the rating or state
        // of the button
        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        // Executes for each star that is to be displayed, starting at a zero index, in the range 0 -> (starCount - 1)
        for index in 0..<starCount {
            // Create the button
            let button = UIButton()
            // Set the button images accordingly depending on the button state
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            // Add constraints for proper display on the screen in proportion to other objects on the view, that updates according
            // to any changes in screen size or orientation
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            // Set the accessibility label to help users see how to use the rating mechanic
            button.accessibilityLabel = "Set \(index + 1) star rating"
            
            // Setup the button action
            button.addTarget(self, action:
                #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
            
            // Add the button to the stack
            addArrangedSubview(button)
            
            // Add the new button to the rating button array
            ratingButtons.append(button)
        }
        
        updateButtonSelectionStates()
    }
    
    // Sets the state of the buttons by defining whether a star should be considered selected (filled in) or not in relation to the rating
    private func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            // If the index of a button is less than the rating, that button should be selected
            button.isSelected = index < rating
            
            // Set the hint string for the currently selected star, so the user knows how to reset the rating to zero
            let hintString: String?
            if rating == index + 1 {
                hintString = "Tap to reset the rating to zero."
            } else {
                hintString = nil
            }
            
            // Calculate the value string, which may be dictated to the user depending on accessibility settings
            let valueString: String
            switch (rating) {
            case 0:
                valueString = "No rating set."
            case 1:
                valueString = "1 star set."
            default:
                valueString = "\(rating) stars set."
            }
            
            // Assign the hint string and value string
            button.accessibilityHint = hintString
            button.accessibilityValue = valueString        }
    }
}
