//
//  Bookmark.swift
//  Acme
//
//  Created by Jorge Alvarez on 3/30/21.
//

import Foundation

/// Object used to store a bookmark or tab
struct Bookmark: Codable, Equatable {
    
    /// Conform to Equatable. Only checks for matching url and ignore urlTitle
    static func ==(lhs: Bookmark, rhs: Bookmark) -> Bool {
        return lhs.url == rhs.url
    }
    
    /// The saved webpage's url
    let url: URL
    
    /// Web page human readable title
    let urlTitle: String
}
