//
//  BookmarksController.swift
//  Acme
//
//  Created by Jorge Alvarez on 3/30/21.
//

import Foundation

class BookmarksController {
    
    // MARK: - Properties
            
    /// Holds stored bookmarks
    var bookmarks: [Bookmark] = []
    
    /// URL where saved bookmarks are stored (../bookmarks.plist)
    var bookmarksFileURL: URL? {
        
        let fileManager = FileManager.default
        guard let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {return nil}
        let itemsURL = documentsDir.appendingPathComponent("bookmarks.plist")
        return itemsURL
    }
    
    /// Holds tabs stored as Bookmarks
    var tabs: [Bookmark] = []
    
    /// URL where saved tabs are stored (../tabs.plist)
    var tabsFileURL: URL? {
        
        let fileManager = FileManager.default
        guard let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {return nil}
        let itemsURL = documentsDir.appendingPathComponent("tabs.plist")
        return itemsURL
    }
    
    // MARK: - Initializers
    
    init() {
        loadBookmarksFromPersistentStore()
        loadTabsFromPersistentStore()
    }
        
    // MARK: - Persistence
    
    /// Loads saved bookmarks and sets bookmarks array to file's contents
    private func loadBookmarksFromPersistentStore() {

        guard let fileURL = bookmarksFileURL else { return }

        do {
            let itemsData = try Data(contentsOf: fileURL)
            let decoder = PropertyListDecoder()
            let itemsArray = try decoder.decode([Bookmark].self, from: itemsData)
            self.bookmarks = itemsArray
        } catch {
            print("Error loading items from plist: \(error)")
        }
    }
    
    /// Loads saved tabs and sets tabs array to file's contents
    private func loadTabsFromPersistentStore() {
        
        guard let fileURL = tabsFileURL else { return }

        do {
            let itemsData = try Data(contentsOf: fileURL)
            let decoder = PropertyListDecoder()
            let itemsArray = try decoder.decode([Bookmark].self, from: itemsData)
            self.tabs = itemsArray
        } catch {
            print("Error loading items from plist: \(error)")
        }
    }
    
    // Saves to plist instead of using Core Data because that's how Safari does it
    /// Saves bookmarks to bookmarksFileURL
    private func saveBookmarksToPersistentStore() {

        guard let fileURL = bookmarksFileURL else { return }

        do {
            let encoder = PropertyListEncoder()
            let itemsData = try encoder.encode(bookmarks)
            try itemsData.write(to: fileURL)
        } catch {
            print("Error saving items: \(error)")
        }
    }
    
    /// Saves tabs to tabsFileURL
    private func saveTabsToPersistentStore() {
        
        guard let fileURL = tabsFileURL else { return }

        do {
            let encoder = PropertyListEncoder()
            let itemsData = try encoder.encode(tabs)
            try itemsData.write(to: fileURL)
        } catch {
            print("Error saving items: \(error)")
        }
    }
    
    // MARK: - CRUD
    
    /// Adds bookmark to bookmakrs array and saves
    func addBookmark(newBookmark: Bookmark) {
        bookmarks.append(newBookmark)
        saveBookmarksToPersistentStore()
    }
    
    /// Adds tab to tabs array and saves
    func addTab(newTab: Bookmark) {
        tabs.append(newTab)
        saveTabsToPersistentStore()
    }
    
    /// Removes bookmark at given row and saves
    func deleteBookmark(row: Int) {
        bookmarks.remove(at: row)
        saveBookmarksToPersistentStore()
    }
        
    /// Removes tab at given row and saves
    func deleteTab(row: Int) {
        tabs.remove(at: row)
        saveTabsToPersistentStore()
    }
    
    /// Updates a saved tab with one given. Returns if tab isn't in tabs or if updated version is the same as previous
    func updateTabWith(oldTab: Bookmark, updatedTab: Bookmark) {
        guard let index = tabs.firstIndex(of: oldTab), tabs[index] != updatedTab else { return }
        tabs[index] = updatedTab
        saveTabsToPersistentStore()
    }
}
