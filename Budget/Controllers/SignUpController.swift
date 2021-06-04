//
//  SignUpController.swift
//  Budget
//
//  Created by Yago Saboia Felix Frota on 24/04/19.
//  Copyright © 2019 com.yagoapps. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController {
    
    
    
    @IBOutlet weak var emailTxf: UITextField!
    
    @IBOutlet weak var passwordTxf: UITextField!
    
    @IBOutlet weak var doneOutlet: UIBarButtonItem!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activity.isHidden = true
        activity.stopAnimating()
        
        emailTxf.disableAutoFill()
        
        passwordTxf.placeholder = "At least 6 characters long"
        passwordTxf.disableAutoFill()
        // Do any additional setup after loading the view.
    }
    
    
    
    
    
    
    @IBAction func returnBtt(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBtt(_ sender: Any) {
        guard let email = emailTxf.text else { return }
        guard let password = passwordTxf.text else { return }
        startActivity()
        if(email == ""){
            AlertsManager.shared.simpleAlert(withText: "Please enter a valid email", toView: self)
            stopActivity()
        }
        else if(password.count < 6){
            AlertsManager.shared.simpleAlert(withText: "Please enter a password with at least 6 digits", toView: self)
            stopActivity()
        }else{
            
            FirebaseService.shared.createUser(withEmail: email, password: password) { (error) in
                if let error = error{
                    if let errCode = AuthErrorCode(rawValue: error._code) {
                        
                        switch errCode {
                        case .invalidEmail:
                            AlertsManager.shared.simpleAlert(withText: "Invalid email", toView: self)
                            print("invalid email")
                        case .emailAlreadyInUse:
                            AlertsManager.shared.simpleAlert(withText: "Email already in use", toView: self)
                            print("in use")
                        default:
                            AlertsManager.shared.simpleAlert(withText: "Something went wrong, try again later", toView: self)
                            print("Create User Error: \(error)")
                        }
                        self.stopActivity()
                        return
                    }
                    
                }else{
                    self.dismiss(animated: true, completion: nil)
                    self.stopActivity()
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    let viewController = storyboard.instantiateViewController(withIdentifier: "mainController") as! MainController
                    viewController.modalPresentationStyle = .overFullScreen
                    let navigationController = UINavigationController.init(rootViewController: viewController)
                    UIApplication.shared.windows.first?.rootViewController = navigationController
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                }
            }
        }
    }
    
    
    func startActivity(){
        doneOutlet.isEnabled = false
        activity.isHidden = false
        activity.startAnimating()
    }
    func stopActivity(){
        self.doneOutlet.isEnabled = true
        self.activity.isHidden = true
        self.activity.stopAnimating()
    }
    
}
