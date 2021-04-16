//
//  TabsController.swift
//  Acme
//
//  Created by Jorge Alvarez on 3/30/21.
//

import Foundation

class TabsController {
    
    // MARK: - Properties
        
    /// URL where saved tabs are stored (../tabs.plist)
    var persistentFileURL: URL? {
        
        let fileManager = FileManager.default
        guard let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {return nil}
        let itemsURL = documentsDir.appendingPathComponent("tabs.plist")
        print("persistentFileURL = \(itemsURL)")
        return itemsURL
    }
    
    /// Holds stored urls
    var tabs: [Bookmark] = []
    
    init() {
        loadFromPersistentStore()
    }
    
    /// Saves to plist instead of using Core Data because that's how Safari does it
    func saveToPersistentStore() {
        print("save to store")
        guard let fileURL = persistentFileURL else {return}

        do {
            let encoder = PropertyListEncoder()
            let itemsData = try encoder.encode(tabs)
            try itemsData.write(to: fileURL)
        } catch {
            print("Error saving items: \(error)")
        }
    }

    /// Loads saved urls
    func loadFromPersistentStore() {
        print("load to store")
        guard let fileURL = persistentFileURL else {return}

        do {
            let itemsData = try Data(contentsOf: fileURL)
            let decoder = PropertyListDecoder()
            let itemsArray = try decoder.decode([Bookmark].self, from: itemsData)
            self.tabs = itemsArray
        } catch {
            print("Error loading items from plist: \(error)")
        }
    }
    
    /// Adds tab  to tabs array and saves
    func addTab(newTab: Bookmark) {
        tabs.append(newTab)
        saveToPersistentStore()
    }
    
    /// Removes tab at given row and saves
    func deleteTab(row: Int) {
        print("deleteTab at row \(row)")
        tabs.remove(at: row)
        saveToPersistentStore()
    }
}
