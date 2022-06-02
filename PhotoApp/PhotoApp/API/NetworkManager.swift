//
//  NetworkManager.swift
//  PhotoApp
//
//  Created by Vignesh Radhakrishnan on 02/06/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import Foundation

struct RequestInfo {
    var path: String
    var parameters: [String: Any]?
    var method: HTTPMethod
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case update = "PUT"
    }
}

protocol NetworkManagerProtocol {
    typealias resultHandler = (Result<Data,Error>) -> Void
    func request(requestInfo: RequestInfo, completion: @escaping (Result<Data, Error>) -> Void)
    func download(requestInfo: RequestInfo, completion: @escaping resultHandler)
}

class NetworkManager : NetworkManagerProtocol {
    
    private var session: URLSession =  URLSession.shared
    
    func request(requestInfo: RequestInfo, completion: @escaping (Result<Data, Error>) -> Void) {
        do {
            let urlRequest = try URLRequest.prepare(fromRequestInfo: requestInfo)
            session.dataTask(with: urlRequest) { (data, response, error) in
                DispatchQueue.main.async {
                    if let data = data {
                        completion(.success(data))
                    } else {
                        if let error = error {
                            completion(.failure(error))
                        }
                    }
                }
            }.resume()
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    
    func download(requestInfo: RequestInfo, completion: @escaping (Result<Data, Error>) -> Void) {
        do {
            let urlRequest = try URLRequest.prepare(fromRequestInfo: requestInfo)
            session.downloadTask(with: urlRequest) { (url, response, error) in
                if let url = url, let data = try? Data.init(contentsOf: url) {
                    DispatchQueue.main.async {
                        completion(.success(data))
                    }
                } else {
                    if let error = error {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
            }.resume()
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
}

extension URLRequest {
    static func prepare(fromRequestInfo info: RequestInfo) throws -> URLRequest {
        guard let url = URL.init(string: info.path), url.isValidURL() else {
            throw NSError.init(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
        }
        switch info.method {
        case .get:
            var queryItems: [URLQueryItem] = []
            if let data = info.parameters as? [String: String] {
                for (key, value) in data {
                    let item = URLQueryItem(name: key, value: value)
                    queryItems.append(item)
                }
            }
            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw NSError.init(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
            }
            if !queryItems.isEmpty {
                urlComponents.queryItems = queryItems
            }
            guard let resultURL = urlComponents.url else {
                throw NSError.init(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
            }
            var urlRequest = URLRequest(url: resultURL)
            urlRequest.httpMethod = info.method.rawValue
            urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
            return urlRequest
        case .post:
            fallthrough
        case .update:
            var urlRequest = URLRequest(url: url)
            if let parameters = info.parameters, let data = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) {
                urlRequest.httpBody = data
            }
            urlRequest.httpMethod = info.method.rawValue
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
            urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
            return urlRequest
        }
        
    }
}

extension URL {
    func isValidURL() -> Bool {
        return !(self.host?.isEmpty ?? true)
    }
}
