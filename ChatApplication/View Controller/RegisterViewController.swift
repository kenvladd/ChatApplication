//
//  RegisterViewController.swift
//  ChatApplication
//
//  Created by OPSolutions on 8/20/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var brgyTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var zipTextField: UITextField!
    @IBOutlet weak var provinceTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Register"
    }
    
    func transitionToHome() {
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as! HomeViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
    func validateField() -> String? {
        
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            streetTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            brgyTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            cityTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            zipTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            provinceTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            countryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields"
        }
        let cleanedPass = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if RegisterViewController.isPasswordValid(cleanedPass) == false {
            return "Please make sure your password is atleast 8 characters, contains a special character and a number."
        }
        return nil
    }
    
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        let street = self.streetTextField.text
        let brgy = self.brgyTextField.text
        let city = self.cityTextField.text
        let zip = self.zipTextField.text
        let province = self.provinceTextField.text
        let country = self.countryTextField.text
        
        
        let error = validateField()
        
        if error != nil {
            showError(error!)
        }
        else {
            
            let  firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let  lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let  email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let  password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let  address = "\(street ?? "n/a") \(brgy ?? "n/a") \(city ?? "n/a") \(province ?? "n/a") \(country ?? "n/a") \(zip ?? "n/a")"
            
            Auth.auth().createUser(withEmail: email, password: password) { result, err in
                if err != nil {
                    self.showError("Error creating user")
                }
                else{
                    let db = Firestore.firestore()
                    
                    db.collection("use_profile").addDocument(data: [
                    "address": address,
                    "email": email,
                    "firstname":firstName,
                    "lastname": lastName,
                    "password": password,
                    "uid":result!.user.uid
                    ]) { (error) in
                        if error != nil {
                            self.showError("Error saving user Data")
                        }
                    }
                    
                    self.transitionToHome()
                    
                }
            }
        }
    }
    
    @IBAction func locationTapped(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "locationVC") as! LocationViewController
        vc.modalPresentationStyle = .fullScreen
        vc.completionHandlerCountry = { text in self.countryTextField.text = text }
        vc.completionHandlerCity = { text in self.cityTextField.text = text }
        vc.completionHandlerZip = { text in self.zipTextField.text = text }
        vc.completionHandlerStreet = { text in self.streetTextField.text = text }
        
        present(vc, animated: true)
    }
}
struct Constants {
    
    struct Storyboard {
        
       static let homeViewController = "HomeVC"
        
    }
    
}


