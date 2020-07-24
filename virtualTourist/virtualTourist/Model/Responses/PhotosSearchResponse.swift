//
//  PhotosSearchResponse.swift
//  virtualTourist
//
//  Created by Oleh Titov on 22.07.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation

struct PhotosSearchResponse: Codable {
    let photos: Photos
    let stat: String
}

struct Photos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [Photo]
}

struct Photo: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    // Create URL for image file
    var imageURL: String? {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
    }
}
