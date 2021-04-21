//
//  TabsCollectionViewController.swift
//  Acme
//
//  Created by Jorge Alvarez on 4/18/21.
//

import UIKit

class TabsCollectionViewController: UICollectionViewController {
    
    // MARK: - Properties
    
    /// Bookmark that's passed in when coming from BrowserViewController
    var bookmark: Bookmark?
    
    /// Controls which types of web pages to display
    var bookmarksController: BookmarksController?
        
    /// Dismisses page
    var doneButton: UIBarButtonItem!
    
    /// Tells BrowserViewController when a url has been selected
    var newPageDelegate: NewPageDelegate?
    
    /// Opens up a new tab
    var newTabButton: UIBarButtonItem!

    /// Identifier for custom collection view cells. "TabCollectionViewCell"
    private let reuseIdentifier = "TabCollectionViewCell"
    
    // MARK: - View Life Cycle
    
    /// Sets up tool bar and its buttons
    private func setupToolBar() {
        
        // Tool Bar
        navigationController?.isToolbarHidden = false
        navigationController?.toolbar.barTintColor = .systemGray6
        
        // New Tab Button
        newTabButton = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(openNewTabTapped))
        newTabButton.tintColor = .customTintColor
        
        // Done Button
        doneButton = UIBarButtonItem(title: "Done",
                                     style: .plain,
                                     target: self,
                                     action: #selector(doneTapped))
        doneButton.tintColor = .customTintColor
        
        // Spacer
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

        toolbarItems = [newTabButton, space, doneButton]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .systemGray6
        navigationController?.isNavigationBarHidden = true
        collectionView.register(TabCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        setupToolBar()
    }

    // MARK: - Actions
    
    /// DIsmisses screen
    @objc private func doneTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    /// Opens new tab by notifying BrowserViewController to load a new page and dismisses screen
    @objc private func openNewTabTapped() {
        guard let bookmarksController = bookmarksController, let bookmark = bookmark else { return }
        openTab(url: .defaultURL)
        bookmarksController.addTab(newTab: bookmark)
        newPageDelegate?.didAddOrDeleteTab()
    }
    
    // MARK: - Helpers
    
    /// Dismisses view controller and opens a new tab or bookmark
    private func openTab(url: URL) {
        newPageDelegate?.didSelectUrl(url: url)
        doneTapped()
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? TabCollectionViewCell else { return UICollectionViewCell() }
    
        cell.tab = bookmarksController?.tabs[indexPath.row]
        cell.cellDeletionDelegate = self
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookmarksController?.tabs.count ?? 0
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let bookmarksController = bookmarksController else { return }
                
        openTab(url: bookmarksController.tabs[indexPath.row].url)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TabsCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 2
        let insets = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: 0)
        let horizontalInsets = insets.left + insets.right
        let itemSpacing = (self.collectionView(collectionView,
                                               layout: collectionViewLayout,
                                               minimumInteritemSpacingForSectionAt: 0)) * (itemsPerRow - 1)
        let width = (collectionView.frame.width - horizontalInsets - itemSpacing) / itemsPerRow

        return CGSize(width: width, height: width)
    }
}

// MARK: - CellDeletionDelegate

extension TabsCollectionViewController: CellDeletionDelegate {
    
    func deleteTabForCell(cell: TabCollectionViewCell, bookmark: Bookmark) {
        
        guard let path = collectionView.indexPath(for: cell), let controller = bookmarksController else { return }
        
        // delete from data source
        controller.deleteTab(row: path.row, bookmark: bookmark)

        // delete from collection view
        collectionView.deleteItems(at: [path])

        // notify browser screen to update its tab count
        newPageDelegate?.didAddOrDeleteTab()
    }
}
