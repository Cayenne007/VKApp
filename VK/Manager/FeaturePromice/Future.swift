////
////  Future.swift
////  VK
////
////  Created by Vladlen Sukhov on 28.02.2022.
////
//
//import Foundation
//import SwiftUI
//
//class Future<T> {
//    
//    private var callbacks: [(Result<T, Error>) -> ()]?
//    fileprivate var result: Result<T, Error>? {
//        didSet {
//            guard let result = result else { return }
//            callbacks?.forEach{$0(result)}
//        }
//    }
//    
//    func add(callback: @escaping (Result<T, Error>) -> ()) {
//        callbacks?.append(callback)
//        result.map(callback)
//    }
//    
//    
//}
//
//extension Future {
//    func map<NewType>(with closure: @escaping (T) throws -> NewType) -> Future<NewType> {
//        let promise = Promise<NewType>()
//        
//        add { result in
//            switch result {
//            case .success(let value):
//                do {
//                    let mappedValue = try closure(value)
//                    promise.fullfill(with: mappedValue)
//                } catch {
//                    promise.reject(with: error)
//                }
//            case .failure(let error):
//                promise.reject(with: error)
//            }
//        }
//        
//        return promise
//    }
//    
//    func valueOnly(with closure: @escaping (T) -> ()) -> Future<T> {
//        add { result in
//            guard let value = try? result.get() else { return }
//            closure(value)
//        }
//        
//        return self
//    }
//    
//    func errorOnly(closure: @escaping (Error) -> ()) -> Future<T> {
//        
//        add { result in
//            switch result {
//            case .failure(let error):
//                closure(error)
//            default:
//                break
//            }
//        }
//        
//        return self
//        
//    }
//    
//    func final(execQueue: DispatchQueue = .main, closure: @escaping () -> ()) -> Future<T> {
//        add { _ in
//            execQueue.async {
//                closure()
//            }
//        }
//        return self
//    }
//    
//    func mapToVoid() {}
//    
//}
//
//extension Future {
//    func flatMap<NewType>(with closure: @escaping (T) throws -> Future<NewType>) -> Future<NewType> {
//        
//        let promise = Promise<NewType>()
//        add { result in
//            switch result {
//            case .success(let value):
//                do {
//                    let chainedPromise = try closure(value)
//                    chainedPromise.add { result in
//                        switch result {
//                        case .success(let value):
//                            promise.fullfill(with: value)
//                        case .failure(let error):
//                            promise.reject(with: error)
//                        }
//                    }
//                } catch {
//                    promise.reject(with: error)
//                }
//            case .failure(let error):
//                promise.reject(with: error)
//            }
//            
//        }
//        
//        return promise
//        
//    }
//}
//
//
//class Promise<T>: Future<T> {
//    init(value: T? = nil) {
//        super.init()
//        
//        result = value.map(Result.success)
//    }
//    
//    func fullfill(with value: T) {
//        result = .success(value)
//    }
//    
//    func reject(with error: Error) {
//        result = .failure(error)
//    }
//}
//
//fileprivate enum JsonErrors: Error {
//    case dataError
//}
