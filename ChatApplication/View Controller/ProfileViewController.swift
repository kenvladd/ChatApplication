//
//  ProfileViewController.swift
//  ChatApplication
//
//  Created by OPSolutions on 8/27/21.
//

import UIKit
import FirebaseAuth

class ProfileViewController: ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Profile"
    }
    @IBAction func logOutTapped(_ sender: Any) {
        
        let auth = Auth.auth()

        

        do {

            try auth.signOut()

            let homeViewController = self.storyboard?.instantiateViewController(identifier: "HomeTab") as! TabBarViewController
            
            self.view.window?.rootViewController = homeViewController
            self.view.window?.makeKeyAndVisible()

    
        

        }

        catch {

            print("error in Logout")

        }
        
        
    }
}
