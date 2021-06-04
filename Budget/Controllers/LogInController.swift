//
//  LogInController.swift
//  Budget
//
//  Created by Yago Saboia Felix Frota on 23/04/19.
//  Copyright © 2019 com.yagoapps. All rights reserved.
//

import UIKit
import Firebase

class LogInController: UIViewController{
    
    @IBOutlet weak var emailTxf: UITextField!
    
    @IBOutlet weak var passwordTxf: UITextField!
    @IBOutlet weak var loginOutlet: UIButton!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activity.isHidden = true
        activity.stopAnimating()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    
    @IBAction func loginBtt(_ sender: Any) {
        guard let email = emailTxf.text else { return }
        guard let password = passwordTxf.text else { return }
        print(password)
        startActivity()
        
        FirebaseService.shared.logUserIn(withEmail: email, password: password, view: self) { (error) in
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
                self.stopActivity()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let viewController = storyboard.instantiateViewController(withIdentifier: "mainController") as! MainController
                viewController.modalPresentationStyle = .fullScreen
                let navigationController = UINavigationController.init(rootViewController: viewController)
                UIApplication.shared.windows.first?.rootViewController = navigationController
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
        }
    }
    
    
    func startActivity(){
        loginOutlet.isEnabled = false
        activity.isHidden = false
        activity.startAnimating()
    }
    func stopActivity(){
        self.loginOutlet.isEnabled = true
        self.activity.isHidden = true
        self.activity.stopAnimating()
    }
}


