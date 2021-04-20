//
//  TabCollectionViewCell.swift
//  Acme
//
//  Created by Jorge Alvarez on 4/18/21.
//

import UIKit

protocol CellDeletionDelegate {
    
    /// Tells TabCollectionViewController to delete cell at given tab
    func deleteTabForCell(cell: TabCollectionViewCell, bookmark: Bookmark)
}

class TabCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    /// Used to tell TabCollectionViewController to delete cell
    var cellDeletionDelegate: CellDeletionDelegate?
    
    /// Acts as "container" so imageView doesn't can fill up whole cell
    var customView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    var deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .white
        return button
    }()
    
    var deleteButtonContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    var faviconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    var faviconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = false
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "safari")
        imageView.backgroundColor = .white
        return imageView
    }()
    
    /// Holds  tab object that's passed in
    var tab: Bookmark? {
        didSet {
            updateViews()
        }
    }
        
    /// UIImageView that displays a screenshot of tab
    var tabScreenShotImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    /// UILabel that displays tab title
    var tabTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tab"
        label.backgroundColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    // MARK: - View Life Cycle
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    /// Layouts UI
    private func setupSubviews() {
        
        clipsToBounds = true
        layer.cornerRadius = 5
        
        // Custom View
        addSubview(customView)
        customView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        customView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        customView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        customView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        // Favicon Container
        customView.addSubview(faviconContainerView)
        faviconContainerView.topAnchor.constraint(equalTo: customView.topAnchor).isActive = true
        faviconContainerView.leadingAnchor.constraint(equalTo: customView.leadingAnchor).isActive = true
        faviconContainerView.heightAnchor.constraint(equalTo: customView.heightAnchor, multiplier: 0.1).isActive = true
        faviconContainerView.widthAnchor.constraint(equalTo: faviconContainerView.heightAnchor).isActive = true
        
        // Tab Title Label
        customView.addSubview(tabTitleLabel)
        tabTitleLabel.topAnchor.constraint(equalTo: customView.topAnchor).isActive = true
        tabTitleLabel.leadingAnchor.constraint(equalTo: faviconContainerView.trailingAnchor).isActive = true
        tabTitleLabel.heightAnchor.constraint(equalTo: customView.heightAnchor, multiplier: 0.1).isActive = true
        tabTitleLabel.widthAnchor.constraint(equalTo: customView.widthAnchor, multiplier: 0.8).isActive = true
        
        // Delete Button Container
        customView.addSubview(deleteButtonContainerView)
        deleteButtonContainerView.topAnchor.constraint(equalTo: customView.topAnchor).isActive = true
        deleteButtonContainerView.leadingAnchor.constraint(equalTo: tabTitleLabel.trailingAnchor).isActive = true
        deleteButtonContainerView.heightAnchor.constraint(equalTo: customView.heightAnchor, multiplier: 0.1).isActive = true
        deleteButtonContainerView.widthAnchor.constraint(equalTo: deleteButtonContainerView.heightAnchor).isActive = true
        
        // Favicon Image View
        customView.addSubview(faviconImageView)
        faviconImageView.centerYAnchor.constraint(equalTo: faviconContainerView.centerYAnchor).isActive = true
        faviconImageView.centerXAnchor.constraint(equalTo: faviconContainerView.centerXAnchor).isActive = true
        faviconImageView.heightAnchor.constraint(equalTo: faviconContainerView.heightAnchor, multiplier: 0.7).isActive = true
        faviconImageView.widthAnchor.constraint(equalTo: faviconImageView.heightAnchor).isActive = true
        
        // Delete Button
        customView.addSubview(deleteButton)
        deleteButton.heightAnchor.constraint(equalTo: deleteButtonContainerView.heightAnchor, multiplier: 0.6).isActive = true
        deleteButton.centerYAnchor.constraint(equalTo: deleteButtonContainerView.centerYAnchor).isActive = true
        deleteButton.centerXAnchor.constraint(equalTo: deleteButtonContainerView.centerXAnchor).isActive = true
        deleteButton.widthAnchor.constraint(equalTo: deleteButton.heightAnchor).isActive = true
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        // Tab Screenshot Image View
        customView.addSubview(tabScreenShotImageView)
        tabScreenShotImageView.topAnchor.constraint(equalTo: tabTitleLabel.bottomAnchor).isActive = true
        tabScreenShotImageView.bottomAnchor.constraint(equalTo: customView.bottomAnchor).isActive = true
        tabScreenShotImageView.leadingAnchor.constraint(equalTo: customView.leadingAnchor).isActive = true
        tabScreenShotImageView.trailingAnchor.constraint(equalTo: customView.trailingAnchor).isActive = true
    }
    
    /// Updates the cell to display correct label, favicon, and snapshot
    private func updateViews() {
        
        guard let tab = tab else { return }
        
        // Tab Label
        tabTitleLabel.text = tab.urlTitle
        
        // Tab Snapshot
        let image = UIImage.loadImageFromDiskWith(fileName: "\(tab.urlTitle)")
        tabScreenShotImageView.image = image
        
        // Tab Icon
        let name = "favicon-" + tab.url.absoluteString.replacingOccurrences(of: "/", with: "-")
        let favicon = UIImage.loadImageFromDiskWith(fileName: name) ?? UIImage(systemName: "safari")
        faviconImageView.image = favicon
    }
        
    // MARK: - Actions
    
    /// Tells TabsCollectionViewController to delete cell that matches tab
    @objc private func deleteTapped() {

        guard let tab = tab else { return }
        cellDeletionDelegate?.deleteTabForCell(cell: self, bookmark: tab)
    }
}
