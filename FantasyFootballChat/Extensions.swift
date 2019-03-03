//
//  Extensions.swift
//  FantasyFootballChat
//
//  Created by Андрей Гончаров on 14/03/2018.
//  Copyright © 2018 Goncharov Andrei. All rights reserved.
//

import UIKit
import Firebase

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    // load image using cache with URL
    func loadImageUsingCacheWithURLString(urlString: String) {
        self.image = nil
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) {
            self.image = cachedImage as? UIImage
            return
        }
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if  error != nil {
                print(error!)
                return
                }
            DispatchQueue.main.async() {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                    }
                }
            }).resume()
        }
    }

