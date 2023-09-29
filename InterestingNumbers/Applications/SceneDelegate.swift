//
//  SceneDelegate.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 09.09.2023.
//

import UIKit
import FirebaseCore
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var cancellable = Set<AnyCancellable>()
    let navigationVC = UINavigationController()
    let authorizedService = AuthorizationService.shared
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        FirebaseApp.configure()
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationVC
        window?.makeKeyAndVisible()
        
        sinkToSessionState()
    }
    
    private func sinkToSessionState() {
        authorizedService.$sessionState
            .sink(receiveValue: { state in
                switch state {
                case .loggedIn :
                    self.navigationVC.setViewControllers([ChoiseRequestNumbersViewController()], animated: true)
                case .loggedOut :
                    self.navigationVC.setViewControllers([EnterViewController()], animated: true)
                }
            }).store(in: &cancellable)
        authorizedService.setupFirebaseAuth()
    }
}

