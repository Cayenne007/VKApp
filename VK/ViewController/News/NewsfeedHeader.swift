//
//  NewsfeedHeader.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 17.02.2022.
//

import UIKit

class NewsfeedHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var logo: UIImageView!
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()

        backView.layer.borderWidth = 1
        backView.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        logo.layer.masksToBounds = false
        logo.layer.cornerRadius = logo.frame.width / 2
        logo.clipsToBounds = true
    }
    
}
