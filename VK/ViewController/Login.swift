//
//  LoginViewController.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 12.02.2022.
//

import UIKit
import WebKit

class LoginViewController: UIViewController {
    
    var delegate: UpdateDataOnLogin?
    
    @IBOutlet weak var webView: WKWebView! {
        didSet{ webView.navigationDelegate = self }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        WebCacheCleaner.clear()
        isModalInPresentation = true
        
        var urlComponents = URLComponents()
                urlComponents.scheme = "https"
                urlComponents.host = "oauth.vk.com"
                urlComponents.path = "/authorize"
                urlComponents.queryItems = [
                    URLQueryItem(name: "client_id", value: "8082169"),
                    URLQueryItem(name: "display", value: "mobile"),
                    URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
                    URLQueryItem(name: "scope", value: "friends,photos,audio,video,stories,pages,status,wall,groups,email,offline"),
                    URLQueryItem(name: "response_type", value: "token")
                ]
                
            let request = URLRequest(url: urlComponents.url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10)
                
            webView.load(request)
    }
    
}


extension LoginViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let url = navigationResponse.response.url, url.path == "/blank.html", let fragment = url.fragment  else {
            decisionHandler(.allow)
            return
        }
        
        let params = fragment
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { result, param in
                var dict = result
                let key = param[0]
                let value = param[1]
                dict[key] = value
                return dict
            }
        
        if let token = params["access_token"] {
            AppSettings.token = token
        }
        
        if let userId = params["user_id"] {
            AppSettings.userId = userId
        }
        
        decisionHandler(.cancel)
        
        delegate?.load()
        dismiss(animated: true)
        
    }
    
}


fileprivate final class WebCacheCleaner {

    class func clear() {
        URLCache.shared.removeAllCachedResponses()

        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        print("[WebCacheCleaner] All cookies deleted")

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("[WebCacheCleaner] Record \(record) deleted")
            }
        }
    }

}

