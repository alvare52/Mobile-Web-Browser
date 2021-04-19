//
//  TabsCollectionViewController.swift
//  Acme
//
//  Created by Jorge Alvarez on 4/18/21.
//

import UIKit

private let reuseIdentifier = "Cell"

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
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .systemGray6
        navigationController?.isToolbarHidden = false
        navigationController?.toolbar.barTintColor = .systemGray6
        navigationController?.toolbar.clipsToBounds = true
        navigationController?.isNavigationBarHidden = true
        collectionView.register(TabCollectionViewCell.self, forCellWithReuseIdentifier: "TabCollectionViewCell")
        
        // New Tab Button
        newTabButton = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(openNewTab))
        newTabButton.tintColor = .customTintColor
        
        // Done Button
        doneButton = UIBarButtonItem(title: "Done",
                                     style: .done,
                                     target: self,
                                     action: #selector(doneTapped))
        doneButton.tintColor = .customTintColor
        
        // Spacer
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

        toolbarItems = [space, newTabButton, space, doneButton]
        
        
    }

    /// DIsmisses screen
    @objc private func doneTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    /// DIsmisses screen
    @objc private func openNewTab() {
        guard let bookmarksController = bookmarksController, let bookmark = bookmark else { return }
        openTab(url: .defaultURL)
        bookmarksController.addTab(newTab: bookmark)
        newPageDelegate?.didAddOrDeleteTab()
    }
    
    /// Dismisses view controller and opens a new tab or bookmark
    private func openTab(url: URL) {
        newPageDelegate?.didSelectUrl(url: url)
        doneTapped()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookmarksController?.tabs.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TabCollectionViewCell", for: indexPath) as? TabCollectionViewCell else { return UICollectionViewCell() }
    
        cell.tab = bookmarksController?.tabs[indexPath.row]
        cell.cellDeletionDelegate = self
        cell.indexPath = indexPath
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let bookmarksController = bookmarksController else { return }
                
        openTab(url: bookmarksController.tabs[indexPath.row].url)
    }
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension TabsCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    }

    // MARK: Flow Layout

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
        print("w = \(width)")
        return CGSize(width: width, height: width)
    }
}

extension TabsCollectionViewController: CellDeletionDelegate {
    
    func deleteTabAtIndexPath(indexPath: IndexPath, urlTitle: String) {
        bookmarksController?.deleteTab(row: indexPath.row, urlTitle: urlTitle)
        collectionView.deleteItems(at: [indexPath])
        newPageDelegate?.didAddOrDeleteTab()
    }
}
