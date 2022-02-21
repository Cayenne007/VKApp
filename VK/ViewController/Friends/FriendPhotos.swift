//
//  FriendPhotos.swift
//  VK
//
//  Created by Vladlen Sukhov on 20.02.2022.
//

import Foundation
import UIKit


class FriendPhotoViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var owner: VKAuthor? = nil
    private var photos: [VKPhoto] {
        DB.getPhotos(id: owner?.id)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 5, bottom: 10, right: 5)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.width*0.8)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
        
        VK.api.fetchPhotos(owner: owner) {
            self.collectionView.reloadData()
        }
        
    }
    
}

extension FriendPhotoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let photo = photos[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath)
        
        var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.width*0.8))
        
        if let view = cell.contentView.subviews.first, let placedImageView = view as? UIImageView {
            imageView = placedImageView
        } else {
            imageView.contentMode = .scaleAspectFill
            imageView.image = UIImage(systemName: "photo")!
            cell.contentView.addSubview(imageView)
        }
        
        imageView.image = photo.image
        imageView.backgroundColor = .blue
        
        return cell
    }
    
}
