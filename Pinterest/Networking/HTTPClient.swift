//
//  HTTPClient.swift
//  Networking
//
//  Created by arafat on 9/21/19.
//  Copyright © 2019 Pinterest. All rights reserved.
//

import Foundation

public final class HTTPClient {
    public static let baseUrl = "http://pastebin.com/raw"
    public enum Result<Value> {
        case success(Value)
        case failure(Error)
    }
    public typealias JSON = [String: Any]
    public typealias HTTPHeaders = [String: String]

    public enum RequestMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

    private static func sendRequest(_ url: String,
                                    method: RequestMethod,
                                    headers: HTTPHeaders? = nil,
                                    body: JSON? = nil,
                                    completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let url = URL(string: url)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue

        if let headers = headers {
            urlRequest.allHTTPHeaderFields = headers
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if let body = body {
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
                completionHandler(data, response, error)
            }
        }
        task.resume()
    }

    public static func request<T: Decodable>(for: T.Type = T.self,
                                             url: Endpoint,
                                             method: RequestMethod,
                                             headers: HTTPHeaders? = nil,
                                             body: JSON? = nil,
                                             completion: @escaping (Result<T>) -> Void) {

        if let resource = Cache.shared.load(url.path),
            let data = resource.value {
            do {
                let decoder = JSONDecoder()
                try completion(.success(decoder.decode(T.self, from: data)))
            } catch let decodingError {
                completion(.failure(decodingError))
            }
        } else {
            return sendRequest(url.path, method: method, headers: headers, body:body) { data, response, error in
                guard let data = data else {
                    return completion(.failure(error ?? NSError(domain: "SomeDomain", code: -1, userInfo: nil)))
                }
                Cache.shared.save(url.path,
                                  data: data,
                                  expiryDate: .inSeconds(1800))
                do {
                    let decoder = JSONDecoder()
                    try completion(.success(decoder.decode(T.self, from: data)))
                } catch let decodingError {
                    completion(.failure(decodingError))
                }
            }
        }

    }

    public static func request<T: Decodable>(for: [T].Type = [T].self,
                                             url: Endpoint,
                                             method: RequestMethod,
                                             headers: HTTPHeaders? = nil,
                                             body: JSON? = nil,
                                             completion: @escaping (Result<[T]>) -> Void) {

        if let resource = Cache.shared.load(url.path),
            let data = resource.value {
            do {
                let decoder = JSONDecoder()
                try completion(.success(decoder.decode([T].self, from: data)))
            } catch let decodingError {
                completion(.failure(decodingError))
            }
        } else {

            return sendRequest(url.path, method: method, headers: headers, body:body) { data, response, error in
                guard let data = data else {
                    return completion(.failure(error ?? NSError(domain: "SomeDomain", code: -1, userInfo: nil)))
                }
                Cache.shared.save(url.path,
                                  data: data,
                                  expiryDate: .inSeconds(1800))
                do {

                    let decoder = JSONDecoder()
                    try completion(.success(decoder.decode([T].self, from: data)))
                } catch let decodingError {
                    completion(.failure(decodingError))
                }
            }
        }

    }
}
