//
//  PhotolistAPIManager.swift
//  PhotoApp
//
//  Created by Vignesh Radhakrishnan on 02/06/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import Foundation

struct Server {
    static let baseurl = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3e7cc266ae2b0e0d78e279ce8e361736&format=json&nojsoncallback=1&safe_search=1&text=%@&page=%d"
    struct ImageDownloadPath {
        static var ImagePath = "https://farm%d.staticflickr.com/%@/%@_%@.jpg"
    }
}
protocol PhotoListAPI {
    func getPhotoList(searchTerm : String,pageNo : String,completion: @escaping ((Result<Photos, Error>) -> Void))
}

struct PhotoListAPIManager: PhotoListAPI {
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func getPhotoList(searchTerm : String,pageNo : String,completion: @escaping ((Result<Photos, Error>) -> Void)) {
        
        let requestURL =  String(format:  Server .baseurl,searchTerm,pageNo)
        networkManager.request(requestInfo: RequestInfo(path: requestURL, parameters: nil, method: RequestInfo.HTTPMethod.get)) { (result) in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(Response.self, from: data)
                    if let photos = response.photos {
                        completion(.success(photos))
                    }
                } catch {
                    print(error)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
