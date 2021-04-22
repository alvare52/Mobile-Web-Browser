//
//  UIImage+Extension.swift
//  Acme
//
//  Created by Jorge Alvarez on 4/18/21.
//

import Foundation
import UIKit

extension UIImage {
    
    /// Memory cache to store already saved user plant images, clears itself after it has more than 100(?) images
    static var savedTabImages = [String: UIImage]() {
        didSet {
            // clear cache after 100 images are stored
            if savedTabImages.count > 100 {
                savedTabImages.removeAll()
            }
        }
    }
    
    /// Save image to documents directory, and remove old one if it exists and save new one
    /// - Parameter imageName: the name of an image that has been saved
    /// - Parameter image: the UIImage you want to save
    static func saveImage(imageName: String, image: UIImage) {
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else { return }

        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                // remove from savedUserPlantImages
                savedTabImages.removeValue(forKey: imageName)
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }

        }

        do {
            try data.write(to: fileURL)
            // add to cache of user's saved images for fast loading in main tableview
            savedTabImages[imageName] = image
        } catch let error {
            print("error saving file with error", error)
            print("fileURL = \(fileURL)")
        }

    }

    /// Takes in the name of a stored image and returns a UIImage or nil if it can't find one
    static func loadImageFromDiskWith(fileName: String) -> UIImage? {
        
        // First check savedUserPlantImages cache and return early
        if let imageFromCache = savedTabImages[fileName] {
            return imageFromCache
        }
                
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            // put in cache so we can skip this next time
            savedTabImages[fileName] = image
            return image
        }

        return nil
    }
    
    /// Deletes image in directory with given name in file path
    static func deleteImage(_ imageName: String) {
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                // remove from savedUserPlantImages
                savedTabImages.removeValue(forKey: imageName)
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
        }
    }
    
    /// Fetches image at URL passed in and returns a UIImage (returns placeholder image if none exists)
    static func fetchImage(with urlString: URL, completion: @escaping (UIImage?) -> Void = { _ in }) {

        /// If there are any errors fetching an image, this image is returned instead
        let defaultImage = UIImage(systemName: "square.on.square")

        let baseURL = "https://s2.googleusercontent.com/s2/favicons?domain_url="
        guard let url = URL(string: baseURL + urlString.absoluteString) else {
            print("cant make url from passed in string")
            completion(defaultImage)
            return
        }
        
        let http = url
        let urlComponents = URLComponents(url: http, resolvingAgainstBaseURL: false)
        guard let comps = urlComponents else {
            print("cant make urlComponents")
            completion(defaultImage)
            return
        }

        var components = comps
        components.scheme = "https"
        guard let secureUrl = components.url else {
            print("cant make secureUrl from http")
            completion(defaultImage)
            return
        }

        URLSession.shared.dataTask(with: secureUrl) { (data, _, error) in
            if let error = error {
                NSLog("Error fetching image: \(error)")
                return
            }
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(defaultImage)
                return
            }
            let imageToReturn = UIImage(data: data)
            completion(imageToReturn)
        }.resume()
    }
}
