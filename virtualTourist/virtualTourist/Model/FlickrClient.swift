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
        
        case getPhotosForLocation(Double, Double, Int, Int)
        
        var stringValue: String {
            switch self {
            case .getPhotosForLocation(let lat, let lon, let radius, let page): return Endpoints.base + "api_key=\(FlickrApiKey.key)" + "&format=json" + "&lat=\(lat)" + "&lon=\(lon)" + "&radius=\(radius)" + "&page=\(page)" + "&per_page=10" + "&nojsoncallback=1"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
    }
    
    class func getListOfPhotosForLocation(lat: Double, lon: Double, radius: Int, page: Int, completion: @escaping ([Photo], Error?) -> Void) {
        taskForGetRequest(url: Endpoints.getPhotosForLocation(lat, lon, radius, page).url, response: PhotosSearchResponse.self) { (response, error) in
            if let response = response {
                completion(response.photos.photo, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    class func downloadImage(path: URL, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: path) { data, response, error in
            completion(data, error)
        }
        task.resume()
    }
    
    class func taskForGetRequest<ResponseType: Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                //print(String(data: data, encoding: .utf8)!)
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
}
