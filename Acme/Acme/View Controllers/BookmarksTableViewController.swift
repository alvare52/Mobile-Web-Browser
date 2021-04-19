//
//  BookmarksTableViewController.swift
//  Acme
//
//  Created by Jorge Alvarez on 3/30/21.
//

import UIKit

protocol NewPageDelegate {
    /// Tells BrowswerViewController to open this url
    func didSelectUrl(url: URL)
    
    /// Tells BrowserViewController to update its tabButton image
    func didAddOrDeleteTab()
}

class BookmarksTableViewController: UITableViewController {

    // MARK: - Properties
    
    /// Add icon used to add a bookmark or new tab
    var addButton: UIBarButtonItem!
    
    /// Bookmark that's passed in when coming from BrowserViewController
    var bookmark: Bookmark?
    
    /// Controls which types of web pages to display
    var bookmarksController: BookmarksController?
    
    /// Tells tableview what type of web pages to display. False by default (using tabs)
    /// Isn't an enum because there can only be 2 states
    var bookmarksMode = false {
        didSet {
            updateViews()
        }
    }
    
    /// Tells BrowserViewController when a url has been selected
    var newPageDelegate: NewPageDelegate?
    
    // MARK: - View Life Cycle
    
    /// Sets up Add and Done button in navigation bar
    private func setupNavBar() {
        
        // Add
        addButton = UIBarButtonItem(title: "",
                                    style: .plain,
                                    target: self,
                                    action: #selector(addButtonTapped))
        addButton.image = UIImage(systemName: "plus")
        addButton.tintColor = .customTintColor
        navigationItem.leftBarButtonItem = addButton
        
        // Done
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(doneTapped))
        navigationItem.rightBarButtonItem?.tintColor = .customTintColor
    }
    
    private func updateViews() {
        guard isViewLoaded else { return }
        if let count = bookmarksController?.bookmarks.count {
            title = bookmarksMode ? "Bookmarks - \(count)" : "Tabs"
        } else {
            title = bookmarksMode ? "Bookmarks" : "Tabs"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        updateViews()
    }
    
    // MARK: - Actions
    
    /// Creates new bookmark or tab
    @objc func addButtonTapped() {
        guard let bookmarksController = bookmarksController, let bookmark = bookmark else { return }
        
        // Add new bookmark
        if bookmarksMode {
            bookmarksController.addBookmark(newBookmark: bookmark)
            tableView.reloadData()
            updateViews()
        }
        
        // Open new tab
        else {
            openTabOrBookmark(url: .defaultURL)
            bookmarksController.addTab(newTab: bookmark)
            newPageDelegate?.didAddOrDeleteTab()
        }
    }
    
    /// Dismisses view controller
    @objc func doneTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    /// Dismisses view controller and opens a new tab or bookmark
    private func openTabOrBookmark(url: URL) {
        newPageDelegate?.didSelectUrl(url: url)
        doneTapped()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookmarkCell", for: indexPath)

        guard let bookmarksController = bookmarksController else { return cell }
        
        // Bookmarks
        if bookmarksMode {
            let bookmark = bookmarksController.bookmarks[indexPath.row]
            cell.imageView?.tintColor = .customTintColor
            cell.textLabel?.text = "\(bookmark.urlTitle)"
            cell.imageView?.image = UIImage(systemName: "book")
            return cell
        }
        
        // Tabs
        else {
            let tab = bookmarksController.tabs[indexPath.row]
            cell.imageView?.tintColor = .customTintColor
            cell.textLabel?.text = "\(tab.urlTitle)"
            cell.imageView?.image = UIImage(systemName: "square.on.square")
            return cell
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
                
        if editingStyle == .delete {
            
            if bookmarksMode {
                bookmarksController?.deleteBookmark(row: indexPath.row)
                updateViews()
            } else {
//                bookmarksController?.deleteTab(row: indexPath.row)
            }

            tableView.deleteRows(at: [indexPath], with: .fade)
            newPageDelegate?.didAddOrDeleteTab()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let bookmarksController = bookmarksController else { return }
        
        let url = bookmarksMode ? bookmarksController.bookmarks[indexPath.row].url : bookmarksController.tabs[indexPath.row].url
        
        openTabOrBookmark(url: url)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if bookmarksMode {
            return bookmarksController?.bookmarks.count ?? 0
        }
        
        return bookmarksController?.tabs.count ?? 0
    }
}
