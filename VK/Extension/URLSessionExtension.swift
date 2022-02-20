//
//  URLSessionExtension.swift
//  VK
//
//  Created by Vladlen Sukhov on 20.02.2022.
//

import Foundation

extension URLSession {

    func request<T: Decodable>(_ url: URL, decode decodable: T.Type, result: @escaping (Result<T, Error>) -> Void) {

        URLSession.shared.dataTask(with: url) { (data, response, error) in

            if let error = NetworkError(data: data, response: response, error: error) {                
                result(.failure(error))
                return
            }

            do {
                let object = try JSONDecoder().decode(decodable, from: data!)
                result(.success(object))
            } catch {
                result(.failure(error))
            }

        }.resume()

    }
    
    func requestJsonResponseObjects<T: Decodable>(_ url: URL, decode decodable: T.Type, result: @escaping (Result<[T], Error>) -> Void) {

        URLSession.shared.dataTask(with: url) { (data, response, error) in

            if let error = NetworkError(data: data, response: response, error: error) {
                result(.failure(error))
                return
            }

            do {
                let json = try JSONDecoder().decode([String : [T]].self, from: data!)
                if let objects = json["response"] {
                    result(.success(objects))
                } else {
                    print("ошибка декодирования запроса response")
                }
            } catch {
                result(.failure(error))
            }

        }.resume()

    }
    
    func requestJsonResponseItems<T: Decodable>(_ url: URL, decode decodable: T.Type, result: @escaping (Result<[T], Error>) -> Void) {

        URLSession.shared.dataTask(with: url) { (data, response, error) in

            if let error = NetworkError(data: data, response: response, error: error) {
                result(.failure(error))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as? [String : [String : Any]],
                   let items = json["response"]?["items"] as? [T] {
                    
                    result(.success(items))
                    
                } else {
                    print("ошибка декодирования идентификаторов")
                }
            } catch {
                result(.failure(error))
            }

        }.resume()

    }
    
    func request(_ url: URL, result: @escaping (Result<Data, Error>) -> Void) {

        URLSession.shared.dataTask(with: url) { (data, response, error) in

            if let error = NetworkError(data: data, response: response, error: error) {
                result(.failure(error))
                return
            }

            result(.success(data!))

        }.resume()

    }

}

fileprivate enum NetworkError: Error {
    case transportError(Error)
    case serverError(statusCode: Int)
    case noData
    case decodingError(Error)
    case encodingError(Error)
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
