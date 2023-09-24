//
//  SceneDelegate.swift
//  InterestingNumbers
//
//  Created by Olga Sabadina on 09.09.2023.
//

import UIKit
import FirebaseCore
//import FirebaseFirestore
import Combine
//import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var cancellable = Set<AnyCancellable>()
    let authorizedService = AuthorizationService.shared
    let navigationVC = UINavigationController()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        FirebaseApp.configure()
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationVC
        window?.makeKeyAndVisible()
        
        authorizedService.$sessionState
            .sink(receiveValue: { state in
                switch state {
                case .loggedIn :
                    print("log in")
                    self.navigationVC.setViewControllers([ChoiseNumbersViewController()], animated: true)
                case .loggedOut :
                    self.navigationVC.setViewControllers([EnterViewController()], animated: true)
                }
            }).store(in: &cancellable)
        authorizedService.setupFirebaseAuth()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
//        authorizedService.removeHandleListener()
    }


}

