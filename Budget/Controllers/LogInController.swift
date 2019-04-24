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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func logUserIn(withEmail email : String, password : String){
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if let error = error {
                print("failed to sign in user with error: ", error.localizedDescription)
                return
            }
            guard let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else { return }
            guard let controller = navController.viewControllers[0] as? MainController else { return }
            print("sucessfully logged user in...")
            
            controller.loadUserData()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func loginBtt(_ sender: Any) {
        guard let email = emailTxf.text else { return }
        guard let password = passwordTxf.text else { return }
        print(password)
        
        logUserIn(withEmail: email, password: password)
    }
    
    
    
}


