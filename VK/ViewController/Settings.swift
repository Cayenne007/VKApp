//
//  Settings.swift
//  VK
//
//  Created by Vladlen Sukhov on 04.03.2022.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.title = "Настройки"
        Authorization.logIn()

    }
    
    @IBAction func openDocumentsDirectory(_ sender: UIButton) {
        
        guard let docUrl = FileManager.documentsDirectory else { return }
        let path = docUrl.absoluteString.replacingOccurrences(of: "file://", with: "shareddocuments://")
        UIApplication.shared.open(path.url, options: [:], completionHandler: nil)
        
    }
    
    @IBAction func openURLS(_ sender: UIButton) {
        
        showAlertWithURL([
            "Новости" : .news(),
            "Друзья" : .friends,
            "Группы" : .groups
        ])
        
    }

    private func showAlertWithURL(_ items: [String: URLS]) {
        
        let alert = UIAlertController(title: "Ссылки", message: "Новости, Друзья, Группы", preferredStyle: .alert)
        
        items.forEach{ item in
            alert.addTextField { textField in
                textField.text = URLS.buildUrl(item.value).description
            }
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)

    }
    
    
    
    @IBAction func delRealm(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "База данных Realm", message: "Удалить?", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Да", style: .destructive, handler: { _ in
            
            DB.deleteAll()
            
            guard let docsUrl = FileManager.documentsDirectory,
                  let files = FileManager.default.enumerator(atPath: docsUrl.path) else { return }
            
            files.forEach{fileName in
                guard let fileName = fileName as? String else { return }
                let fileUrl = URL(fileURLWithPath: fileName, relativeTo: docsUrl)
                let absoluteUrl = fileUrl.absoluteURL
                
                try? FileManager.default.removeItem(at: absoluteUrl)
            }
        
            self.dismiss(animated: true) {
                Notifications.postObserverNotification()
            }
        })
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                                   
        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        
    }
    
    
    @IBAction func exportToFirestore(_ sender: Any) {
        CloudDB.vk.importData()
        showAlert(title: "Firestore", subtitle: "Данные отправлены")
        
    }
    
    
}
