//
//  TabCollectionViewCell.swift
//  Acme
//
//  Created by Jorge Alvarez on 4/18/21.
//

import UIKit

class TabCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    /// Acts as "container" so imageView doesn't can fill up whole cell
    var customView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        imageView.image = UIImage(named: "AcmeIcon1024x1024")
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
        label.backgroundColor = .orange//.white
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    // MARK: - View Life Cycle
 
    override init(frame: CGRect) {
        print("cell with frame")
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        print("cell with coder")
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
        setupSubviews()
    }
    
    /// Layout UI
    private func setupSubviews() {
        
        clipsToBounds = true
        layer.cornerRadius = 5
        
        // Custom View
        addSubview(customView)
        customView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        customView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        customView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        customView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        // Tab Title Label
        customView.addSubview(tabTitleLabel)
        tabTitleLabel.topAnchor.constraint(equalTo: customView.topAnchor).isActive = true
        tabTitleLabel.leadingAnchor.constraint(equalTo: customView.leadingAnchor).isActive = true
        tabTitleLabel.trailingAnchor.constraint(equalTo: customView.trailingAnchor).isActive = true
        tabTitleLabel.heightAnchor.constraint(equalTo: customView.heightAnchor, multiplier: 0.1).isActive = true
        
        // Image View
        customView.addSubview(tabScreenShotImageView)
        tabScreenShotImageView.topAnchor.constraint(equalTo: tabTitleLabel.bottomAnchor).isActive = true
        tabScreenShotImageView.bottomAnchor.constraint(equalTo: customView.bottomAnchor).isActive = true
        tabScreenShotImageView.leadingAnchor.constraint(equalTo: customView.leadingAnchor).isActive = true
        tabScreenShotImageView.trailingAnchor.constraint(equalTo: customView.trailingAnchor).isActive = true
    }
    
    private func updateViews() {
        print("updateViews")
        guard let tab = tab else { return }
        tabTitleLabel.text = tab.urlTitle
    }
}
