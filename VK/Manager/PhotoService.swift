//
//  PhotoService.swift
//  VK
//
//  Created by Vladlen Sukhov on 03.03.2022.
//

import Foundation
import Alamofire
import UIKit


class PhotoService {
    
    private let cacheLifeTime: TimeInterval = 30 * 24 * 60 * 60
    private var images: [String: UIImage?] = [:]
    private let container: DataReloadable
    
    private static let pathName: String = {
        let pathName = "images"
        
        guard let docsDirectory = FileManager.documentsDirectory else { return pathName}
        let url = docsDirectory.appendingPathComponent(pathName, isDirectory: true)
        
        if !url.isFileExists() {
            try? FileManager.default.createDirectory(at: url,
                                                     withIntermediateDirectories: true,
                                                     attributes: nil)
        }
        
        return pathName
    }()
    
    
    
    func getFilePath(_ url: String) -> String? {
        
        guard let docsDirectory = FileManager.documentsDirectory else { return nil}
        
        let hashName = url.split(separator: "?").first
        if let hashName = hashName?.split(separator: "/").last {
            return docsDirectory.appendingPathComponent("\(PhotoService.pathName)/\(hashName)").path
        } else {
            return docsDirectory.appendingPathComponent("\(PhotoService.pathName)/default").path
        }
        
    }
    
    private func saveImageToCache(_ url: String, image: Data?) {
        
        guard let fileName = getFilePath(url),
              let image = image else { return }
        FileManager.default.createFile(atPath: fileName, contents: image, attributes: nil)
        
    }
    
    private func getImageFromCache(_ url: String) -> UIImage? {
        
        guard let fileName = getFilePath(url),
              let info = try? FileManager.default.attributesOfItem(atPath: fileName),
              let modificationDate = info[.modificationDate] as? Date else {
                  return nil
              }
        let lifeTime = Date().timeIntervalSince(modificationDate)
        
        guard lifeTime <= cacheLifeTime,
              let image = UIImage(contentsOfFile: fileName) else { return nil }
        
        DispatchQueue.main.async {
            self.images[url] = image
        }
        
        return image
        
    }
    
    private func loadPhoto(at indexPath: IndexPath, url: String) {
        
        AF.request(url).responseData(queue: .global()) { [weak self] response in
            guard let data = response.data,
            let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async{
                self?.images[url] = image
            }
            
            self?.saveImageToCache(url, image: data)
            
            DispatchQueue.main.async {
                self?.container.reloadRow(at: indexPath)
            }
        }
        
    }
    
    func photo(at indexPath: IndexPath, url: String) -> UIImage? {
        
        var image: UIImage?
        if let photo = images[url] {
            image = photo
        } else if let photo = getImageFromCache(url) {
            image = photo
        } else {
            loadPhoto(at: indexPath, url: url)
        }
        return image
        
    }
    
    
    init(container: UITableView) {
        self.container = Table(container)
    }
    
    init(container: UICollectionView) {
        self.container = Collection(container)
    }
    
    
    
}


fileprivate protocol DataReloadable {
    func reloadRow(at indexPath: IndexPath)
}




extension PhotoService {
    
    private class Table: DataReloadable {
        let table: UITableView
        
        init(_ table: UITableView) {
            self.table = table
        }
        
        func reloadRow(at indexPath: IndexPath) {
            table.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    private class Collection: DataReloadable {
        let collection: UICollectionView
        
        init(_ collection: UICollectionView) {
            self.collection = collection
        }
        
        func reloadRow(at indexPath: IndexPath) {
            collection.reloadItems(at: [indexPath])
        }
    }
    
}
