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
    
    
    
    @IBAction func loginBtt(_ sender: Any) {
        guard let email = emailTxf.text else { return }
        guard let password = passwordTxf.text else { return }
        print(password)
        activity.isHidden = false
        activity.startAnimating()
        loginOutlet.isEnabled = false
        
        FirebaseService.shared.logUserIn(withEmail: email, password: password, view: self) { (error) in
            guard let error = error else{
                
                self.dismiss(animated: true, completion: nil)
                self.activity.isHidden = true
                self.activity.stopAnimating()
                self.loginOutlet.isEnabled = true
                return
            }
            AlertsManager.shared.alertSpecs(withText: "Sign up was not successful", view: self)
            print(error)
        }
    }
    
    
    
}


