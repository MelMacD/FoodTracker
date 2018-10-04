//
//  MealTableViewController.swift
//  FoodTracker
//
// Controls the Table View, which involves displaying all Meal objects from persistent storage and providing a method for editing or
// selecting them
//
//  Created by Melanie MacDonald on 2018-10-01.
//  Copyright © 2018 Melanie MacDonald. All rights reserved.
//

import UIKit
import os.log

class MealTableViewController: UITableViewController {
    
    //MARK: Properties
    // Handles the Meals as an array of Meal objects
    var meals = [Meal]()

    // On loading the view, add an edit button and attempt to load any meals saved, otherwise loading sample data instead
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller
        navigationItem.leftBarButtonItem = editButtonItem

        // Load any saved meals, otherwise load sample data
        if let savedMeals = loadMeals() {
            meals += savedMeals
        }
        else {
            // Load the sample data
            loadSampleMeals()
        }
    }

    // MARK: - Table view data source

    // Sets the number of sections for the Table View, in this case there being only one
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Sets the number of rows in the section to the number of Meal objects in the meals array
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }

    // Sets each table cell to its appropriate values per Meal object in the meals array, using the IndexPath as an index for meals
    // array as well to ensure the meals are displayed in order of storage (or in order defined as sample data)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "MealTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }

        // Fetches the appropriate meal for the data source layout
        let meal = meals[indexPath.row]
        
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating

        return cell
    }

    // Override to support conditional editing of the table view.
    // This turns on editing of the table view, which is used in this case to potentially deleted rows/Meal objects from the table
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    // Only defined for deleting a table row, because there is a different process for adding rows defined in this program
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // Ensures the data storage is updated with the removal of a meal as well as updating the table to reflect this change
        if editingStyle == .delete {
            // Delete the row from the data source
            meals.remove(at: indexPath.row)
            saveMeals()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    // This code helps to distinguish between adding a new meal or editing an existing one before navigating to the Meal Detail View,
    // by either setting the meal attribute of the mealDetailViewController to the currently selected meal that the user tapped on so
    // that it can be displayed on the upcoming view, or not setting the meal attribute so the view knows to display the default data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new meal", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? MealViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedMealCell = sender as? MealTableViewCell else {
                fatalError("Unexpected sender: \(sender ?? "Unknown")")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedMeal = meals[indexPath.row]
            mealDetailViewController.meal = selectedMeal
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "Unknown")")
        }
    }

    //MARK: Actions
    // Executes on returning from the Meal Detail View, and either updates a meal if it is modified or adds a new row for a new meal
    // and updates the persistent data storage
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal {
            // if a row is selected, then the meal must have been modified, otherwise it must have been a new meal
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing meal
                meals[selectedIndexPath.row] = meal
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new meal to the meals array and modify the table view to reflect this new row
                let newIndexPath = IndexPath(row: meals.count, section: 0)
                
                meals.append(meal)
                
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            //Save any new or modified meals in data storage
            saveMeals()
        }
    }
    
    //MARK: Private Methods
    // If there are no meals saved, create sample meals for display instead so that the table view is never empty
    private func loadSampleMeals() {
        
        let photo1 = UIImage(named: "meal1")
        let photo2 = UIImage(named: "meal2")
        let photo3 = UIImage(named: "meal3")
        
        guard let meal1 = Meal(name: "Caprese Salad", photo: photo1, rating: 4) else {
            fatalError("Unable to instantiate meal1")
        }
        
        guard let meal2 = Meal(name: "Chicken and Potatoes", photo: photo2, rating: 5) else {
            fatalError("Unable to instantiate meal2")
        }
        
        guard let meal3 = Meal(name: "Pasta with Meatballs", photo: photo3, rating: 3) else {
            fatalError("Unable to instantiate meal3")
        }
        
        meals += [meal1, meal2, meal3]
    }
    
    // Save all meals into persistent storage, otherwise logging an error
    private func saveMeals() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Meals successfully saved", log: OSLog.default, type: .debug)
        }
        else {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }
    }
    
    // Retrieve any saved meals as an array of Meal objects
    private func loadMeals() -> [Meal]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
    }
}
