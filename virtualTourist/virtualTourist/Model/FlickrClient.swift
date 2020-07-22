//
//  FlickrClient.swift
//  virtualTourist
//
//  Created by Oleh Titov on 22.07.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation

class FlickrClient {
    
    enum Endpoints {
        
        static let base = "https://www.flickr.com/services/rest/?method=flickr.photos.search&"
        
        case getPhotosForLocation(Double, Double, Int)
        
        var stringValue: String {
            switch self {
            case .getPhotosForLocation(let lat, let lon, let page): return Endpoints.base + "api_key=\(ApiKey.key)" + "&format=json" + "&lat=\(lat)" + "&lon=\(lon)" + "&radius=7" + "&page=\(page)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
    }
    
}
