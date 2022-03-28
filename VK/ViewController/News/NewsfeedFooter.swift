//
//  NewsfeedFooter.swift
//  VK
//
//  Created by Vladlen Sukhov on 18.02.2022.
//

import UIKit

class NewsfeedFooter: UITableViewHeaderFooterView {
    
    @IBOutlet weak var heartCount: UILabel!
    @IBOutlet weak var chatCount: UILabel!
    @IBOutlet weak var viewCount: UILabel!
    
    var url = ""
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    
    @IBAction func tapOnHeart(_ sender: Any) {
        print("ok")
    }
    
    @IBAction func tapOnChat(_ sender: Any) {
        print("ok2")
    }
    
    @IBAction func openLink() {
        if !url.isEmpty, let url = URL(string: url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}

