//
//  BaseProtocol.swift
//  Agentdesks
//
//  Created by Ravi on 24/03/18.
//  Copyright © 2018 ThinkAnts. All rights reserved.
//

import UIKit

protocol BaseProtocol {
    func downloadImage(articleImageUrl: String) -> UIImage
}

extension BaseProtocol {
    //Download Image from server and store in cache.
    func downloadImage(articleImageUrl: String) -> UIImage {
        var image = UIImage()
        URLSession.shared.dataTask(with: URL(string: articleImageUrl)!) {(data, response, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Error while Fetching Image")
                return
            }
            image = UIImage(data: data!)!
            imageCache[articleImageUrl] = image
            }.resume()
        
        return image
    }
}
