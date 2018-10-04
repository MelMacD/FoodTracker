//
//  MealTableViewCell.swift
//  FoodTracker
//
// Provides a way to create and organize information within the Table View for each cell
//
//  Created by Melanie MacDonald on 2018-09-28.
//  Copyright © 2018 Melanie MacDonald. All rights reserved.
//

import UIKit

class MealTableViewCell: UITableViewCell {
    
    //MARK: Properties
    // Provides these outlets as a way to modify or read the information within the cells that is displayed to the user
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // Controls whether a cell is seen as selected, which has certain behavior attached such as visually altering the cell when selected
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
