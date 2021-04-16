//
//  BrowserView.swift
//  Acme
//
//  Created by Jorge Alvarez on 3/30/21.
//

import UIKit

//class BrowserView: UIView {
//
//    // TODO: activate constraints in array instead of individually
//    // TODO: add commentation
//
//    let urlTextfield: UITextField = {
//        let textfield = UITextField()
//        textfield.translatesAutoresizingMaskIntoConstraints = false
//        textfield.text = "www.wikipedia.com"
//        textfield.backgroundColor = .lightGray
//        textfield.font = .systemFont(ofSize: 14, weight: .semibold)
//        return textfield
//    }()
//
//    let toolBar: UIToolbar = {
//        let toolbar = UIToolbar()
//        toolbar.translatesAutoresizingMaskIntoConstraints = false
//        toolbar.backgroundColor = .yellow
//        return toolbar
//    }()
//
//    let navBar: UINavigationBar = {
//        let nav = UINavigationBar()
//        nav.translatesAutoresizingMaskIntoConstraints = false
//        nav.backgroundColor = .blue
//        return nav
//    }()
//
//    let standardMargin: CGFloat = 10
//
//    // uses this one
//    override init(frame: CGRect) {
//        print("frame")
//        super.init(frame: frame)
//        setupSubviews()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        print("coder")
//        setupSubviews()
//    }
//
//    private func setupSubviews() {
////        addSubview(urlTextfield)
////        urlTextfield.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,constant: standardMargin).isActive = true
////        urlTextfield.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: standardMargin).isActive = true
////        urlTextfield.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -standardMargin).isActive = true
////        urlTextfield.heightAnchor.constraint(equalToConstant: 40).isActive = true
//
////        addSubview(navBar)
////        navBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
////        navBar.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
////        navBar.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
////
////        navBar.addSubview(urlTextfield)
////        urlTextfield.topAnchor.constraint(equalTo: navBar.topAnchor,constant: standardMargin).isActive = true
////        urlTextfield.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: standardMargin).isActive = true
////        urlTextfield.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -standardMargin).isActive = true
////        urlTextfield.heightAnchor.constraint(equalToConstant: 30).isActive = true
////
////        addSubview(toolBar)
////        toolBar.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
////        toolBar.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
////        toolBar.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
//    }
//
//    /*
//    // Only override draw() if you perform custom drawing.
//    // An empty implementation adversely affects performance during animation.
//    override func draw(_ rect: CGRect) {
//        // Drawing code
//    }
//    */
//
//}
