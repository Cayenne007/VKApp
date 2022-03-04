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
    
    var newsfeedId: Int? = nil
    private var item: VKNews? {
        let realm = try! Realm()
        return realm.object(ofType: VKNews.self, forPrimaryKey: newsfeedId)
    }
    
    private var photoService: PhotoService!

    
    private func setup() {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.className)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 5, bottom: 10, right: 5)
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal
        layout.collectionView?.showsHorizontalScrollIndicator = false
        layout.collectionView?.showsVerticalScrollIndicator = false
        collectionView.collectionViewLayout = layout
        
        photoService = PhotoService(container: collectionView)
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
 
    }
    
}


extension NewsfeedPhotosCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        item?.photoUrls.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.className, for: indexPath)
        
        var imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        
        if let view = cell.contentView.subviews.first, let placedImageView = view as? UIImageView {
            imageView = placedImageView
        } else {
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.image = UIImage(systemName: "photo")!
            cell.contentView.addSubview(imageView)
        }
        
        guard let item = item else {
            return cell
        }
        
        if item.photoUrls.count > indexPath.row {
            imageView.image = photoService.photo(at: indexPath, url: item.photoUrls[indexPath.row])
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
        
        return cell
    }
    
}

