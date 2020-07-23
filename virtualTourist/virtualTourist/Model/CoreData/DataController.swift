//
//  DataController.swift
//  virtualTourist
//
//  Created by Oleh Titov on 23.07.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    static let global = DataController(modelName: "virtualTourist")
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    let backgroundContext: NSManagedObjectContext!
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
        
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores {
            storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.configureContexts()
            completion?()
        }
    }
    
}
