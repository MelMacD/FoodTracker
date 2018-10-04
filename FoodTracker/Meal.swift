//
//  Meal.swift
//  FoodTracker
//
// The purpose of this file is to provide a class that defines a Meal, so Meal objects can be created, modified, displayed, and stored
// with certain constraints given that dictate what is and isn't appropriate values for the Meal attributes
//
//  Created by Melanie MacDonald on 2018-09-28.
//  Copyright © 2018 Melanie MacDonald. All rights reserved.
//

import UIKit
import os.log

// This class uses NSObject and NSCoding to facilitate persistent storage of Meal objects by providing a way to encode and decode the
// Meal attributes to and from storage
class Meal: NSObject, NSCoding {
    
    //MARK: Properties
    
    var name: String
    var photo: UIImage?
    var rating: Int
    
    //MARK: Archiving Paths
    // Dictate where and how the persistent storage is kept
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
    
    //MARK: Types
    // Provides key to keep track of values saved in persistent storage, used when encoding and decoding to process the correct attributes
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let rating = "rating"
    }
    
    //MARK: Initialization
    // Provides constraints for the Meal attributes where appropriate
    init?(name: String, photo: UIImage?, rating: Int) {
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        
        // The rating must be between 0 and 5 inclusively
        guard (rating >= 0) && (rating <= 5) else {
            return nil
        }
        
        // Initialize stored properties
        self.name = name
        self.photo = photo
        self.rating = rating
    }
    
    //MARK: NSCoding
    // Encodes attributes into the proper format for storage
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(rating, forKey: PropertyKey.rating)
    }
    
    // Decodes attributes and casts them into their respective types if present before saving them back into the Meal attributes
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because photo is an optional property of Meal, just use conditional cast
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        
        let rating = aDecoder.decodeInteger(forKey: PropertyKey.rating)
        
        // Must call designated initializer
        self.init(name: name, photo: photo, rating: rating)
    }
}
