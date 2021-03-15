//
//  CoreDataStack.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 3/15/21.
//

import Foundation
import CoreData

class CoreDataStack {
    var container: NSPersistentContainer{
        let container = NSPersistentContainer(name: "Lists")
        container.loadPersistentStores{ (description, error) in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
        }
        
        return container
    }
    
    var managedContex: NSManagedObjectContext {
        return container.viewContext
    }
}
