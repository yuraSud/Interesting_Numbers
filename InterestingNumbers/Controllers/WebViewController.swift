//
//  ViewController.swift
//  htmlParceTraining
//
//  Created by Yura Sabadin on 09.08.2023.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var url: URL?
    
    private let webView = WKWebView()
    private let addToFavoritesButton = UIButton(type: .system)
    private var htmlStrings = ""
    private var isFavoritesMode = Mode.addToFavorite
    
    private enum Mode {
        case addToFavorite
        case deleteFavorite
        
        mutating func togle() {
            switch self {
            case .addToFavorite : self = .deleteFavorite
            case .deleteFavorite : self = .addToFavorite
            }
        }
    }
    
    //MARK: - Life Cycle:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setWebView()
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.loadHTMLString(htmlStrings, baseURL: nil)
    }
    
    //MARK: - Private Func:
    
    private func setupView() {
        view.backgroundColor = .systemBackground
    }
    
    private func setWebView() {
        
        htmlStrings = getHTMLString()
        
        let pagePrefs = WKWebpagePreferences()
        let config = WKWebViewConfiguration()
        pagePrefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = pagePrefs
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        webView.isOpaque = false
        webView.backgroundColor = .init(named: "webBackground")
        view.addSubview(webView)
    }
    
    private func getHTMLString() -> String {
        var htmlString = ""
        if let htmlPathURL = url {
            do {
                htmlString = try String(contentsOf: htmlPathURL, encoding: .utf8)
            } catch  {
                print("Unable to get the file.")
            }
        } else {
            alertNoFoundFile()
        }
        return htmlString
    }
    
    private func alertNoFoundFile() {
        let alert = UIAlertController(title: "Вибачте", message: "Неможу знайти файл цього розділу", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
}

//MARK: - Set Constraints:

extension WebViewController {
    func setConstraints() {
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: navigationItem.titleView?.bottomAnchor ?? view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

