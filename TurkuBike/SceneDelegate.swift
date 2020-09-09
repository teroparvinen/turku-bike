//
// The scene delegate creates the application window and the top level navigation and view controllers.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }

		window = UIWindow(frame: UIScreen.main.bounds)

		let navigationController = UINavigationController(rootViewController: RackTableViewController())
		navigationController.navigationBar.prefersLargeTitles = true
		window?.rootViewController = navigationController

		window?.makeKeyAndVisible()
		window?.windowScene = windowScene
	}

}

