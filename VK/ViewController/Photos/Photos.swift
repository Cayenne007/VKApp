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
    
    private var photoService: PhotoService!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoService = PhotoService(container: collectionView)
    
        guard let realm = try? Realm() else {
            return
        }
        
        photos = realm.objects(VKPhoto.self).filter("ownerId = %@", ownerId)
        
        if ownerId > 0 {
            let owner = realm.object(ofType: VKUser.self, forPrimaryKey: ownerId)
            navigationItem.title = owner?.name ?? ""
        } else {
            let owner = realm.object(ofType: VKGroup.self, forPrimaryKey: ownerId)
            navigationItem.title = owner?.name ?? ""
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath) as! PhotosViewCollectionCell
                
        cell.imageView.image = photoService.photo(at: indexPath, url: photo.url)
        
        return cell
    }
    
}


class PhotosViewCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}
