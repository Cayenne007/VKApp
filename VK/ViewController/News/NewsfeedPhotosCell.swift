//
//  NewsfeedPhotosCell.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 17.02.2022.
//

import UIKit
import RealmSwift

class NewsfeedPhotosCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var photoUrls: [String] = []
    private var photoService: PhotoService!
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        photoService = PhotoService(container: collectionView)
    }
    
}


extension NewsfeedPhotosCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photoUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath) as! NewsfeedPhotoCollectionCell
        let url = photoUrls[indexPath.row]
        
        cell.imageView.image = photoService.photo(at: indexPath, url: url)
        
        return cell
    }
    
    
    
    
}


class NewsfeedPhotoCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}

