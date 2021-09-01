

import UIKit
import Firebase

final class AppController {
  static let shared = AppController()
  // swiftlint:disable:next implicitly_unwrapped_optional
  private var window: UIWindow!
  private var rootViewController: UIViewController? {
    didSet {
      window.rootViewController = rootViewController
    }
  }

  init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleAppState),
      name: .AuthStateDidChange,
      object: nil)
  }

  // MARK: - Helpers
  func configureFirebase() {
    FirebaseApp.configure()
  }


  // MARK: - Notifications
  @objc private func handleAppState() {
    
  }
}
