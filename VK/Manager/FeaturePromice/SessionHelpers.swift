//
//  SessionHelpers.swift
//  VK
//
//  Created by Vladlen Sukhov on 03.03.2022.
//

import Foundation
import Alamofire
import PromiseKit

enum InternalError: LocalizedError {
  case unexpected
}

extension Session {
  func requestJson<T: Codable>(_ urlRequestConvertible: URL) -> Promise<T> {
    return Promise<T> { seal in
      request(urlRequestConvertible).responseDecodable { (response: DataResponse<T, AFError>) in
        guard response.response != nil else {
          if let error = response.error {
            seal.reject(error)
          } else {
            seal.reject(InternalError.unexpected)
          }
          return
        }
        
        switch response.result {
        case let .success(value):
          seal.fulfill(value)
        case let .failure(error):
          seal.reject(error)
        }
      }
      .resume()
    }
  }
}

