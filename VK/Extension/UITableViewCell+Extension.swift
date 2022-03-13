//
//  UITableViewCell+Extension.swift
//  VK
//
//  Created by Vladlen Sukhov on 13.03.2022.
//

import UIKit

extension UITableViewCell {
    func addTextWithImage(image: UIImage?, text: String) {
        
        self.contentView.subviews.forEach{ $0.removeFromSuperview() }
                
        let photoView = UIImageView(image: image)
             
        let label = UILabel()
        label.backgroundColor = .systemBackground
        label.text = text
        
        self.contentView.addSubview(photoView)
        self.contentView.addSubview(label)
        
        
        let marginGuide = self.contentView.layoutMarginsGuide
        
        
        photoView.translatesAutoresizingMaskIntoConstraints = false
        photoView.centerYAnchor.constraint(equalTo: marginGuide.centerYAnchor).isActive = true
        photoView.leftAnchor.constraint(equalTo: marginGuide.leftAnchor).isActive = true
        photoView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        photoView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: photoView.rightAnchor, constant: 20).isActive = true
        label.rightAnchor.constraint(equalTo: marginGuide.rightAnchor).isActive = true
        
    }
}
