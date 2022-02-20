//
//  NewsfeedPhotosCell.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 17.02.2022.
//

import UIKit

class NewsfeedPhotosCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    weak var item: VKNews? = nil

    
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
        item?.images.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.className, for: indexPath)
        

        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "photo")!
        cell.contentView.addSubview(imageView)
        
        guard let item = item else {
            return cell
        }
        
        imageView.image = item.images[indexPath.row]
        
        return cell
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        return CGSize(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.height/2)
//    }
    
}

