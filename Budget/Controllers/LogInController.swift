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
    
    var handle: AuthStateDidChangeListenerHandle?
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
        
//        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
//            if Auth.auth().currentUser != nil {
//                // User is signed in.
//                // ...
//                self.performSegue(withIdentifier: "newUser", sender: self)
//            } else {
//                // No user is signed in.
//                // ...
//                
//            }
//            
//        }
    }
    
    
    @IBAction func loginBtt(_ sender: Any) {
        guard let email = emailTxf.text else { return }
        guard let password = passwordTxf.text else { return }
        print(password)
        activity.isHidden = false
        activity.startAnimating()
        loginOutlet.isEnabled = false
        if(email == ""){
            AlertsManager.shared.alertSpecs(withText: "Please enter a valid email", view: self)
            self.dismiss(animated: true, completion: nil)
            self.loginOutlet.isEnabled = true
            self.activity.isHidden = true
            self.activity.stopAnimating()
        }else{
        FirebaseService.shared.logUserIn(withEmail: email, password: password, view: self) { (error) in
            guard let error = error else{
                
                self.dismiss(animated: true, completion: nil)
                self.activity.isHidden = true
                self.activity.stopAnimating()
                self.loginOutlet.isEnabled = true
                return
            }
            AlertsManager.shared.alertSpecs(withText: "Username or password incorrect", view: self)
            print(error)
        }
        }
    }
    
    
    
}


