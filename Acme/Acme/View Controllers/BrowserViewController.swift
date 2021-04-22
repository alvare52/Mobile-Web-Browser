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
    
    /// Bookmark of current webpage. Starts out as Google home page
    var bookmark = Bookmark(url: .defaultURL, urlTitle: "Google") {
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
    
    /// UIBarButtonItem used to display more options
    var moreButton: UIBarButtonItem!
    
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
    
    /// Enum that represents which search engine to use. Default is .Google. didSet will call makeMenuForButton()
    var searchEngine: SearchEngine = .Google {
        didSet {
            print("didSet searchEngine")
            makeMenuForMoreButton()
        }
    }
    
    /// First half of url string that contains selected search engine. Default is https://www.google.com/search?q=
    var searchEngineString = "https://www.google.com/search?q="
    
    /// UIBarButtonItem used to switch tabs
    var tabsButton: UIBarButtonItem!
    
    /// WKWebView that displays the contents of a web page
    var webView: WKWebView = {
        let tempWebView = WKWebView()
        tempWebView.translatesAutoresizingMaskIntoConstraints = false
        return tempWebView
    }()
    
    // MARK: - View Life Cycle
    
    /// Gives moreButton its menu by first checking which search engine option is selected. Selecting menu option will set new value for search engine key
    private func makeMenuForMoreButton() {
        
        let bingImage = searchEngine == .Bing ? UIImage(systemName: "checkmark") : nil
        let duckImage = searchEngine == .DuckDuckGo ? UIImage(systemName: "checkmark") : nil
        let googleImage = searchEngine == .Google ? UIImage(systemName: "checkmark") : nil
        let yahooImage = searchEngine == .Yahoo ? UIImage(systemName: "checkmark") : nil
        
        let menu = UIMenu(title: "Search Engine", children: [
            
            UIAction(title: "Bing", image: bingImage) { action in
                print("tapped Bing option")
                self.searchEngine = .Bing
                self.searchEngineString = "https://www.bing.com/search?q="
            },
            UIAction(title: "DuckDuckGo", image: duckImage) { action in
                print("tapped DDG option")
                self.searchEngine = .DuckDuckGo
                self.searchEngineString = "https://duckduckgo.com/?q="
            },
            UIAction(title: "Google", image: googleImage) { action in
                print("tapped Google option")
                self.searchEngine = .Google
                self.searchEngineString = "https://www.google.com/search?q="
            },
            UIAction(title: "Yahoo", image: yahooImage) { action in
                print("tapped Yahoo option")
                self.searchEngine = .Yahoo
                self.searchEngineString = "https://search.yahoo.com/search?p="
            },
            
        ])
        // save selected search engine
        UserDefaults.standard.setValue(self.searchEngine.rawValue, forKey: .searchEngineString)
        moreButton.menu = menu
    }
    
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
        navigationItem.rightBarButtonItem = refreshButton
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: "arrow.clockwise")
        
        navigationController?.isToolbarHidden = false
        navigationController?.toolbar.isTranslucent = false
        webView.scrollView.delegate = self
        
        // More Button
        moreButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"))
        moreButton.tintColor = .customTintColor
        setupSearchEnginePreference()
        navigationItem.leftBarButtonItem = moreButton
    }
        
    /// Sets search engine menu options and internal searchEngineString for searches that don't contain complete urls
    private func setupSearchEnginePreference() {
        
        let searchEngineRawValue = UserDefaults.standard.integer(forKey: .searchEngineString)
        searchEngine = SearchEngine(rawValue: searchEngineRawValue) ?? .Google
        
        switch searchEngineRawValue {
        case 1:
            searchEngineString = "https://www.bing.com/search?q="
        case 2:
            searchEngineString = "https://duckduckgo.com/?q="
        case 3:
            searchEngineString = "https://search.yahoo.com/search?p="
        default:
            searchEngineString = "https://www.google.com/search?q="
        }
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
        tabsButton = UIBarButtonItem(image: UIImage(systemName: "1.square"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(switchTabs))
        tabsButton.tintColor = .customTintColor
        updateTabsButton()
        
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
        
        webView.takeSnapshot(with: nil) { (image, error) in
            if let error = error {
                print("error taking snapshot, \(error)")
                return
            }
            if let snapshotImage = image {
                UIImage.saveImage(imageName: "\(urlTitle)", image: snapshotImage)
            }
        }
                
        UIImage.fetchImage(with: url) { (image) in
            
            DispatchQueue.main.async {
                if let unwrappedImage = image {
                    let name = "favicon-" + url.absoluteString.replacingOccurrences(of: "/", with: "-")
                    UIImage.saveImage(imageName: name, image: unwrappedImage)
                }
            }
        }
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
        
    /// Takes in an invalid search and performs a search using selected search engine + search term
    private func fallBackSearch(searchTerm: String) {

        let cleanTerm = searchTerm.replacingOccurrences(of: " ", with: "+")

        guard let searchUrl = URL(string: searchEngineString + cleanTerm) else {
            print("invalid search, exitting")
            webView.stopLoading()
            return
        }

        webView.load(URLRequest(url: searchUrl))
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
        updateTabsButton()
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
            print("directly going to url \(URL(string: searchTerm) ?? .defaultURL)")
            return
        }
        
        if let directUrl = URL(string: "https://www.\(searchTerm).com") {
            lastSearch = searchTerm
            webView.load(URLRequest(url: directUrl))
            print("indirectly going to url \(directUrl)")
            return
        } else {
            fallBackSearch(searchTerm: searchTerm)
            return
        }
    }
    
    /// Presents BookmarksTableViewController with a regular modal segue
    private func presentBookmarksTableViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let navVC = storyboard.instantiateViewController(identifier: "BookmarksNavigationControllerID") as? UINavigationController, let bookmarksVC = navVC.viewControllers.first as? BookmarksTableViewController {
            bookmarksVC.bookmarksController = bookmarksController
            bookmarksVC.newPageDelegate = self
            bookmarksVC.bookmark = bookmark
            present(navVC, animated: true, completion: nil)
        }
    }
    
    /// Presents TabsCollectionViewController with a full screen modal segue
    private func presentTabsCollectionViewController() {
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let navVC = storyboard.instantiateViewController(identifier: "TabsNavigationControllerID") as? UINavigationController, let tabsVC = navVC.viewControllers.first as? TabsCollectionViewController {
            tabsVC.bookmarksController = bookmarksController
            tabsVC.newPageDelegate = self
            tabsVC.bookmark = bookmark
            navVC.modalPresentationStyle = .fullScreen
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
        presentTabsCollectionViewController()
    }
    
    /// Updates tabsButton image to reflect how many tabs are open
    private func updateTabsButton() {
        let count = bookmarksController.tabs.count
        switch count {
        case 0:
            tabsButton.image = UIImage(systemName: "1.square")
        case 1...50:
            tabsButton.image = UIImage(systemName: "\(count).square")
        default:
            tabsButton.image = UIImage(systemName: "square.on.square")
        }
    }
    
    /// Presents Bookmarks section
    @objc func viewBookmarks() {
        presentBookmarksTableViewController()
    }
}

// MARK: - UISearchBarDelegate

extension BrowserViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        performSearch(searchTerm: searchTerm)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("did begin editing")
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("did end editing")
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel button clicked")
        searchBar.resignFirstResponder()
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
    
    /// Updates tabsButton to reflect how many tabs are open
    func didAddOrDeleteTab() {
        updateTabsButton()
    }
    
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
