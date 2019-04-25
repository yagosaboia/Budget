//
//  FirebaseService.swift
//  Budget
//
//  Created by Yago Saboia Felix Frota on 25/04/19.
//  Copyright © 2019 com.yagoapps. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
class FirebaseService{
    static var shared = FirebaseService()
    private init() {}
    
    func loadExpenses(_ uid: String, completion: @escaping (_ expenses: [Expense]) -> ()) {
        var expenses: [Expense] = []
        
        let expensesRef = Database.database().reference(withPath: "expenses" )
        expensesRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let expenseDict = snap.value as! [String : Any]
                let userID = expenseDict["userID"] as! String
                if uid == userID {
                    let expense = Expense.deserialize(from: expenseDict)
                    expense?.ID = snap.key
                    expenses.append(expense!)
                }
            }
            DispatchQueue.main.async {
                completion(expenses)
            }
        }
    }
    
    func loadRevenues(_ uid: String, completion: @escaping (_ revenues: [Revenue]) -> ()){
        var revenues: [Revenue] = []
        
        let revenuesRef = Database.database().reference(withPath: "revenues" )
        revenuesRef.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let revenueDict = snap.value as! [String : Any]
                let userID = revenueDict["userID"] as! String
                if uid == userID {
                    let revenue = Revenue.deserialize(from: revenueDict)
                    revenue?.ID = snap.key
                    revenues.append(revenue!)
                }
            }
            DispatchQueue.main.async {
                completion(revenues)
            }
        }
    }
    
    func writeExpense(_ uid: String,_ value: String,_ description: String,_ date: String,_ paid : String, completion: @escaping (_ error: Error?) -> ()) {
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let key = ref.childByAutoId().key
        let group = DispatchGroup()
        var errorMessage: Error? = nil
        group.enter()
        ref.child("expenses").child(key!).setValue(["userID" : uid,"value" : value, "description" : description, "date" : date, "paid" : paid]) { error, _ in
            errorMessage = error
            group.leave()
        }
        group.enter()
        ref.child("users").child(uid).child("expenses").child(key!).setValue(true) { error, _ in
            errorMessage = error
            group.leave()
        }

        group.notify(queue: .main) {
            completion(errorMessage)
        }
    }
    func updateExpense(_ id: String,_ uid: String,_ value: String,_ description: String,_ date: String,_ paid : String, completion: @escaping (_ error: Error?) -> ()) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("expenses").child(id).updateChildValues(["value" : value, "description" : description, "date" : date, "paid" : paid]) {error, _ in
            completion(error)
        }
    }
    
    func removeExpense( uid: String,expenseID: String, completion: @escaping (_ error: Error?) -> ()){
        
        let group = DispatchGroup()
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        var errorMessage: Error? = nil
        group.enter()
        
//        let expenseRef = Database.database().reference(withPath: "expenses").child(expenseID)
//        expenseRef.removeValue { error, _ in
//            if let error = error {
//                print(error.localizedDescription)
//                group.leave()
//            }
//        }
        ref.child("expenses").child(expenseID).removeValue() { error, _ in
            errorMessage = error
            group.leave()
        }
        group.enter()
        ref.child("users").child(uid).child("expenses").child(expenseID).removeValue() { error, _ in
            errorMessage = error
            group.leave()
        }
        group.notify(queue: .main) {
            completion(errorMessage)
        }
    }
    func removeRevenue(uid: String, revenueID: String, completion: @escaping (_ error: Error?) -> ()){
        
        let group = DispatchGroup()
        var ref: DatabaseReference!
        ref = Database.database().reference()
        var errorMessage: Error? = nil
        group.enter()
        
        ref.child("revenues").child(revenueID).removeValue() { error, _ in
            errorMessage = error
            group.leave()
        }
        group.enter()
        ref.child("users").child(uid).child("revenues").child(revenueID).removeValue() { error, _ in
            errorMessage = error
            group.leave()
        }
        group.notify(queue: .main) {
            completion(errorMessage)
        }
    }
    func writeRevenue(_ uid: String,_ value: String,_ description: String,_ date: String, completion: @escaping (_ error: Error?) -> ()) {
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let key = ref.childByAutoId().key
        let group = DispatchGroup()
        var errorMessage: Error? = nil
        group.enter()
        ref.child("revenues").child(key!).setValue(["userID" : uid,"value" : value, "description" : description, "date" : date,]) { error, _ in
            errorMessage = error
            group.leave()
        }
        group.enter()
        ref.child("users").child(uid).child("revenues").child(key!).setValue(true) { error, _ in
            errorMessage = error
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(errorMessage)
        }
    }
    func updateRevenue(_ id: String,_ uid: String,_ value: String,_ description: String,_ date: String,  completion: @escaping (_ error: Error?) -> ()) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("revenues").child(id).updateChildValues(["value" : value, "description" : description, "date" : date]) { error, _ in
            completion(error)
        }
    }
    
    func logUserIn(withEmail email : String, password : String,view: UIViewController, completion: @escaping (_ error: Error?) -> ()){
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if let error = error {
                print("failed to sign in user with error: ", error.localizedDescription)
                AlertsManager.shared.alertSpecs(withText: "Username or password incorrect", view: view)
                return
            }
            
            completion(nil)
        }
    }
    
    
    func createUser(withEmail email : String, password : String, completion: @escaping (_ error: Error?) -> ()){
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            
            if let error = error {
                print("failed to sign up user with error: ", error.localizedDescription)
                completion(error)
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
                completion(nil)
                
            })
        }
    }
    
    
}
