//
//  BrowserViewController.swift
//  Acme
//
//  Created by Jorge Alvarez on 3/30/21.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController {
    
    // MARK: - Properties
    
    /// UIBarButtonItem used to go back to previous page
    var backButton: UIBarButtonItem!
    
    /// Bookmark of current webpage. Starts out as Neeva home page
    var bookmark = Bookmark(url: URL(string: "https://neeva.co/")!, urlTitle: "Ad-free, private search - Neeva") {
        didSet {
            // Update tab (if it's in tabs)
            if bookmarksController.tabs.contains(oldValue) {
                bookmarksController.updateTabWith(oldTab: oldValue, updatedTab: bookmark)
            }
            // A tab to tabs if it was empty
            else if bookmarksController.tabs.isEmpty {
                bookmarksController.addTab(newTab: oldValue)
            }
        }
    }
    
    /// UIBarButtonItem used to view and edit bookmarks
    var bookmarksButton: UIBarButtonItem!
    
    /// Controls bookmarks and tabs
    var bookmarksController = BookmarksController()
    
    /// UIBarButtonItem used to go forward in page list
    var forwardButton: UIBarButtonItem!
    
    /// For hiding toolbar when scrolling past a certain point
    var lastOffsetY: CGFloat = 0
        
    /// Holds last search term
    var lastSearch = ""
    
    /// UIBarButtonItem used to open new tab
    var openNewTabButton: UIBarButtonItem!
    
    /// Progress bar that matches webView.estimatedProgress
    var progressView: UIProgressView = {
        let progress = UIProgressView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.trackTintColor = .clear
        progress.progressTintColor = .customTintColor
        progress.progressViewStyle = .bar
        return progress
    }()

    /// UIBarButtonItem used to refresh current page
    var refreshButton: UIBarButtonItem!
    
    /// UISearchBar used to enter desired url
    let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.placeholder = "Search"
        bar.autocapitalizationType = .none
        bar.keyboardType = .webSearch
        bar.layer.cornerRadius = 5
        bar.tintColor = .customTintColor
        return bar
    }()
    
    /// UIBarButtonItem used to switch tabs
    var tabsButton: UIBarButtonItem!
    
    /// WKWebView that displays the contents of a web page
    var webView: WKWebView = {
        let tempWebView = WKWebView()
        tempWebView.translatesAutoresizingMaskIntoConstraints = false
        return tempWebView
    }()
    
    // MARK: - View Life Cycle
    
    /// Adds basic controls to navigation bar
    private func setupNavigationBar() {
        
        // Search Bar
        navigationItem.titleView = searchBar
        searchBar.delegate = self

        if let lastTabOpened = bookmarksController.tabs.first {
            searchBar.text = "\(lastTabOpened.url)"
        } else {
            searchBar.text = "\(bookmark.url)"
        }
        
        // Progress View
        searchBar.addSubview(progressView)
        progressView.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        progressView.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor).isActive = true
        progressView.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor).isActive = true
        
        webView.addObserver(self,
                            forKeyPath: #keyPath(WKWebView.estimatedProgress),
                            options: .new,
                            context: nil)
        
        // Refresh Button
        refreshButton = UIBarButtonItem(title: "",
                                        style: .plain,
                                        target: self,
                                        action: #selector(reloadWebView))
        refreshButton.tintColor = .customTintColor
        navigationItem.leftBarButtonItem = refreshButton
        navigationItem.leftBarButtonItem?.image = UIImage(systemName: "arrow.clockwise")
        
        navigationController?.isToolbarHidden = false
        webView.scrollView.delegate = self
    }
    
    /// Adds basic controls to toolbar
    private func setupToolbar() {
        
        // Back
        backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(goBack))
        backButton.tintColor = .customTintColor
        
        // Forward
        forwardButton = UIBarButtonItem(image: UIImage(systemName: "chevron.right"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(goForward))
        forwardButton.tintColor = .customTintColor
        
        // Open New Tab
        openNewTabButton = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(openNewTab))
        openNewTabButton.tintColor = .customTintColor
        
        // Bookmarks
        bookmarksButton = UIBarButtonItem(image: UIImage(systemName: "book"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(viewBookmarks))
        bookmarksButton.tintColor = .customTintColor
        
        // Tabs
        tabsButton = UIBarButtonItem(image: UIImage(systemName: "square.on.square"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(switchTabs))
        tabsButton.tintColor = .customTintColor
        
        // Spacer
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

        toolbarItems = [backButton, space, forwardButton, space, openNewTabButton, space, bookmarksButton, space, tabsButton]
    }
    
    /// Adds webView as the main view and configures it
    private func setupWebView() {
        view.addSubview(webView)
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.keyboardDismissMode = .onDrag
    }
    
    /// Updates direction buttons and sets bookmark to webView.url and webView.title
    func updateViews() {
        forwardButton.isEnabled = webView.canGoForward
        backButton.isEnabled = webView.canGoBack
        guard let url = webView.url, let urlTitle = webView.title else { return }
        bookmark = Bookmark(url: url, urlTitle: urlTitle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupNavigationBar()
        setupToolbar()
        
        if let lastTabOpened = bookmarksController.tabs.first {
            webView.load(URLRequest(url: lastTabOpened.url))
        } else {
            webView.load(URLRequest(url: bookmark.url))
        }
    }
    
    // MARK: - Helpers
        
    /// Takes in an invalid search and just Googles it
    private func fallBackSearch(searchTerm: String) {
        let cleanTerm = searchTerm.replacingOccurrences(of: " ", with: "+")
        guard let googleSearchUrl = URL(string: "https://www.google.com/search?q=\(cleanTerm)") else {
            print("invalid search, exitting")
            webView.stopLoading()
            return
        }
        webView.load(URLRequest(url: googleSearchUrl))
    }
    
    /// Goes back to previous page and updates search text
    @objc func goBack() {
        webView.stopLoading()
        webView.goBack()
        if let webTitle = webView.url {
            searchBar.text = "\(webTitle)"
        }
    }
    
    /// Goes to next page and updates search text
    @objc func goForward() {
        webView.stopLoading()
        webView.goForward()
        if let webTitle = webView.url {
            searchBar.text = "\(webTitle)"
        }
    }
    
    /// Updates progressView based on webView.estimatedProgress
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    /// Adds current page to list of saved bookmarks
    @objc func openNewTab() {
        bookmarksController.addTab(newTab: bookmark)
        performSearch(searchTerm: "\(URL.defaultURL)")
        backButton.isEnabled = false
    }
        
    /// Called when tapping go in searchBar or when selecting a bookmark/tab
    func performSearch(searchTerm: String) {
        
        webView.stopLoading()
        searchBar.resignFirstResponder()
        searchBar.text = searchTerm
        
        // Try to go to url directly. Else, try googling the search term
        if searchTerm.contains("https") {
            lastSearch = searchTerm
            webView.load(URLRequest(url: URL(string: searchTerm) ?? .defaultURL))
            return
        }
        
        if let directUrl = URL(string: "https://www.\(searchTerm).com") {
            lastSearch = searchTerm
            webView.load(URLRequest(url: directUrl))
            return
        } else {
            fallBackSearch(searchTerm: searchTerm)
            return
        }
    }
    
    /// Presents BookmarksTableViewController and tells it which data source it should display. false = tabs, true = bookmarks
    private func presentBookmarksOrTabs(bookmarksMode: Bool) {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let navVC = storyboard.instantiateViewController(identifier: "BookmarksNavigationControllerID") as? UINavigationController, let bookmarksVC = navVC.viewControllers.first as? BookmarksTableViewController {
            bookmarksVC.bookmarksController = bookmarksController
            bookmarksVC.bookmarksMode = bookmarksMode
            bookmarksVC.newPageDelegate = self
            bookmarksVC.bookmark = bookmark
            present(navVC, animated: true, completion: nil)
        }
    }
    
    /// Reloads page
    @objc func reloadWebView() {
        webView.reload()
    }
    
    /// Sets progressView back to 0 with a delay
    private func resetProgressView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.progressView.progress = 0
        }
    }
    
    /// Presents Tabs section
    @objc func switchTabs() {
        presentBookmarksOrTabs(bookmarksMode: false)
    }
    
    /// Presents Bookmarks section
    @objc func viewBookmarks() {
        presentBookmarksOrTabs(bookmarksMode: true)
    }
}

// MARK: - UISearchBarDelegate

extension BrowserViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        performSearch(searchTerm: searchTerm)
    }
}

// MARK: - WKNavigationDelegate

extension BrowserViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("error, \(error)")
        webView.stopLoading()
        fallBackSearch(searchTerm: lastSearch)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        resetProgressView()
        guard let url = webView.url else { return }
        updateViews()
        
        // don't replace text if user is already typing
        if !searchBar.isFirstResponder {
            searchBar.text = "\(url)"
        }
    }
}

// MARK: - NewPageDelegate

extension BrowserViewController: NewPageDelegate {
    
    /// Load new web page when called
    func didSelectUrl(url: URL) {
        performSearch(searchTerm: "\(url)")
        forwardButton.isEnabled = false
    }
}

// MARK: - UIScrollViewDelegate

extension BrowserViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView){
        
        let hide = scrollView.contentOffset.y > self.lastOffsetY
        navigationController?.setToolbarHidden(hide, animated: true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        lastOffsetY = scrollView.contentOffset.y
    }
}
