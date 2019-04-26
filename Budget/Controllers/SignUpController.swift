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
        // Do any additional setup after loading the view.
    }
    
    
    
    
    
    
    @IBAction func returnBtt(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBtt(_ sender: Any) {
        guard let email = emailTxf.text else { return }
        guard let password = passwordTxf.text else { return }
        doneOutlet.isEnabled = false
        activity.isHidden = false
        activity.startAnimating()
        if(email == ""){
            AlertsManager.shared.alertSpecs(withText: "Please enter a valid email", view: self)
            self.dismiss(animated: true, completion: nil)
            self.doneOutlet.isEnabled = true
            self.activity.isHidden = true
            self.activity.stopAnimating()
        }
        else if(password.count < 6){
            AlertsManager.shared.alertSpecs(withText: "Please enter a password with at least 6 digits", view: self)
            self.dismiss(animated: true, completion: nil)
            self.doneOutlet.isEnabled = true
            self.activity.isHidden = true
            self.activity.stopAnimating()
        }else{
        
            FirebaseService.shared.createUser(withEmail: email, password: password) { (error) in
                guard let error = error else{
                    self.dismiss(animated: true, completion: nil)
                    self.doneOutlet.isEnabled = true
                    self.activity.isHidden = true
                    self.activity.stopAnimating()
                    return
                }
                AlertsManager.shared.alertSpecs(withText: "Username or password incorrect", view: self)
                self.dismiss(animated: true, completion: nil)
                self.doneOutlet.isEnabled = true
                self.activity.isHidden = true
                self.activity.stopAnimating()
                print(error)
            }
        }
    }

}
