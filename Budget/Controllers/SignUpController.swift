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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    func createUser(withEmail email : String, password : String){
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            
            if let error = error {
                print("failed to sign up user with error: ", error.localizedDescription)
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            let values = ["email" : email]
            
            Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: { (error, ref) in
                
                if let error = error {
                    print("failed to update database values with error: ", error.localizedDescription)
                    return
                }
                
                print("Sucessfully signed up")
                
            })
        }
    }
    
    
    
    @IBAction func returnBtt(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBtt(_ sender: Any) {
        guard let email = emailTxf.text else { return }
        guard let password = passwordTxf.text else { return }
        print(password)
        if(email == ""){
            alertSpecs(withText: "Please enter a valid email")
        }
        else if(password.count <= 6){
            alertSpecs(withText: "Please enter a password with at least 6 digits")
        }else{
        
        createUser(withEmail: email, password: password)

        self.dismiss(animated: true, completion: nil)
        }
    }
    
    func alertSpecs(withText text : String){
        let alert = UIAlertController(title: text, message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
