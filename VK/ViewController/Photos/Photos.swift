//
//  FriendPhotos.swift
//  VK
//
//  Created by Vladlen Sukhov on 20.02.2022.
//

import Foundation
import UIKit
import RealmSwift


fileprivate let itemSize = UIScreen.main.bounds.width*0.95

class PhotosViewController: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var ownerId: Int = 0
    
    private var token: NotificationToken?
    private var photos: Results<VKPhoto>!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 5, bottom: 10, right: 5)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .vertical
        collectionView.collectionViewLayout = layout
        
    
        guard let realm = try? Realm() else {
            return
        }
        
        photos = realm.objects(VKPhoto.self).filter("ownerId = %@", ownerId)
        
        if ownerId > 0 {
            let owner = realm.object(ofType: VKUser.self, forPrimaryKey: ownerId)
            navigationItem.title = owner?._name ?? ""
        } else {
            let owner = realm.object(ofType: VKGroup.self, forPrimaryKey: ownerId)
            navigationItem.title = owner?._name ?? ""
        }
        
        
        VK.api.fetchPhotos(id: ownerId)
        
        token = photos.observe{ [weak self] changes in
            switch changes {
                
            case .initial(_):
                self?.collectionView.reloadData()
            case .update(_, deletions: _, insertions: _, modifications: _):
                self?.collectionView.reloadData()
            case .error(let error):
                print(error)
            }
        }

        
    }
    
}

extension PhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let photo = photos[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath)
        
        var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: itemSize, height: itemSize))
        
        if let view = cell.contentView.subviews.first, let placedImageView = view as? UIImageView {
            imageView = placedImageView
        } else {
            imageView.contentMode = .scaleAspectFill
            imageView.image = UIImage(systemName: "photo")!
            cell.contentView.addSubview(imageView)
        }
        
        if let data = photo.data {
            imageView.image = UIImage(data: data)
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
        imageView.backgroundColor = .blue
        
        return cell
    }
    
}
