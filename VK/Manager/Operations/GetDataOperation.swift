//
//  GetDataOperation.swift
//  VK
//
//  Created by Vladlen Sukhov on 25.02.2022.
//

import Foundation
import Alamofire

class GetDataOperation: AsyncOperation {
    
    private var request: DataRequest
    var data: Data?
    
    override func main() {
        request.responseData(queue: DispatchQueue.global()) { [weak self] response in
            self?.data = response.data
            self?.state = .finished
        }
    }
    
    override func cancel() {
        request.cancel()
        super.cancel()
    }
    
    init(url: URL) {
        request = AF.request(url)
    }
    
}

