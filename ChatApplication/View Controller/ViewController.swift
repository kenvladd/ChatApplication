//
//  ViewController.swift
//  ChatApplication
//
//  Created by OPSolutions on 8/20/21.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        validateAuth()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func validateAuth() {

            if FirebaseAuth.Auth.auth().currentUser != nil {

                

                AppSettings.displayName = "VLAD" //seting user defaults using text in text field

                

                let homeViewController = self.storyboard?.instantiateViewController(identifier: "HomeTab")
                self.view.window?.rootViewController = homeViewController
                self.view.window?.makeKeyAndVisible()

            }

        }

}

