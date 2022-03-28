//
//  URLSessionExtension.swift
//  VK
//
//  Created by Vladlen Sukhov on 20.02.2022.
//

import Foundation

extension URLSession {
    
    func json<T: Codable>(_ url: URLS, source: JsonVkObjectSource, decode decodable: T.Type, result: @escaping (Result<T, Error>) -> Void) {

        URLSession.shared.dataTask(with: url.url) { (data, response, error) in

            if let error = NetworkError(data: data, response: response, error: error) {
                result(.failure(error))
                Notifications.send(title: "Загрузка данных", subtitle: "\(error)")
                return
            }

            do {
                switch source {
                case .itself:
                    let object = try JSONDecoder().decode(decodable, from: data!)
                    result(.success(object))
                case .response:
                    let json = try JSONDecoder().decode(JsonVkObjectSource.Response<T>.self, from: data!)
                    result(.success(json.response))
                case .responseItems:
                    let json = try JSONDecoder().decode(JsonVkObjectSource.ResponseWithItems<T>.self, from: data!)
                    result(.success(json.response.items))
                }
            } catch {
                result(.failure(error))
            }

        }.resume()
    }
    
}

enum NetworkError: Error {
    case transportError(Error)
    case serverError(statusCode: Int)
    case noData
    case decodingError(Error)
    case decodingStringError
    case encodingError(Error)
    case urlError
}

extension NetworkError {
    init?(data: Data?, response: URLResponse?, error: Error?) {
        if let error = error {
            self = .transportError(error)
            return
        }
        
        if let response = response as? HTTPURLResponse,
           response.statusCode != 200 {
            self = .serverError(statusCode: response.statusCode)
            return
        }
        
        if data == nil {
            self = .noData
        }
        
        return nil
    }
}


enum JsonVkObjectSource {
    case itself
    case response
    case responseItems
    
    struct Response<T: Codable>: Codable {
        var response: T
    }

    struct ResponseWithItems<T: Codable>: Codable {
        var response: Items<T>
        
        struct Items<T: Codable>: Codable {
            var items: T
        }
    }
    
}
