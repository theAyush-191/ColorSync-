//
//  ViewController.swift
//  ColorSync
//
//  Created by Ayush Singh on 30/07/25.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        
        guard let email=emailField.text,!email.isEmpty, let password=passwordField.text,!password.isEmpty else {
            showAlert(title: "Missing Information", message: "Please enter both email and password.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                           switch AuthErrorCode(rawValue: error.code) {
                           case .userNotFound:
                               self.showAlert(title: "Error", message: "No account found for this email.")
                           case .wrongPassword:
                               self.showAlert(title: "Error", message: "Incorrect password.")
                           case .invalidEmail:
                               self.showAlert(title: "Error", message: "Invalid email address.")
                           default:
                               self.showAlert(title: "Error", message: error.localizedDescription)
                           }
                           return
                       }
            self.loginSuccess()
        }
        
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
        guard let email = emailField.text, !email.isEmpty , let password = passwordField.text, !password.isEmpty else {
            showAlert(title: "Missing Information", message: "Please enter both email and password.")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                        switch AuthErrorCode(rawValue: error.code) {
                        case .emailAlreadyInUse:
                            self.showAlert(title: "Error", message: "This email is already registered.")
                        case .invalidEmail:
                            self.showAlert(title: "Error", message: "Invalid email address.")
                        case .weakPassword:
                            self.showAlert(title: "Error", message: "Password must be at least 6 characters.")
                        default:
                            self.showAlert(title: "Error", message: error.localizedDescription)
                        }
                        return
                    }
            self.loginSuccess()
        }
        
    }
    
    private func loginSuccess(){
        
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        
        let storyboard=UIStoryboard(name: "Main", bundle: nil)
        let navController=storyboard.instantiateViewController(withIdentifier: "MainNavController") as! UINavigationController
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    func showAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
    }
    
    
}

