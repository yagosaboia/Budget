//
//  ViewController.swift
//  Budget
//
//  Created by Yago Saboia Felix Frota on 23/04/19.
//  Copyright © 2019 com.yagoapps. All rights reserved.
//


import UIKit
import Firebase
import FirebaseAuth

class MainController: UIViewController, UISearchBarDelegate{
    
    
    @IBOutlet weak var value: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //authenticateUser()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if Auth.auth().currentUser != nil {
                // User is signed in.
                // ...
                self.loadUserData()
            } else {
                // No user is signed in.
                // ...
            self.performSegue(withIdentifier: "newUser", sender: self)
            }
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    //fix the transition from maincontroller to login controller when user is nil
    func authenticateUser(){
        if Auth.auth().currentUser == nil {
//            DispatchQueue.main.async {
//                let navController = UINavigationController(rootViewController: LogInController())
//                navController.navigationBar.barStyle = .black
//                self.present(navController, animated: true, completion: nil)
//            }
            performSegue(withIdentifier: "login", sender: self)
        } else {
            loadUserData()
        }
    }
    
    @IBAction func logoutBtt(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    
    func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
    }
    
    
}



